{
  description = "Jaid’s NixOS setup";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-latest.url = "github:NixOS/nixpkgs?ref=master";
    nur.url = "github:nix-community/NUR";
    home-manager.url = "github:nix-community/home-manager?ref=release-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    llama-cpp.url = "github:ggerganov/llama.cpp";
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-latest,
    flake-utils,
    llama-cpp,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    nixpkgsAttributes = {
      inherit system;
      config.allowUnfree = true;
      config.cudaSupport = true;
      config.cudaCapabilities = ["8.9"];
    };
    pkgs = import nixpkgs nixpkgsAttributes;
    pkgsUnstable = import nixpkgs-unstable nixpkgsAttributes;
    pkgsLatest = import nixpkgs-latest (nixpkgsAttributes
      // {
        config.packageOverrides = pkgs: {
          llama-cpp = llama-cpp.packages.${system}.cuda;
        };
      });
  in {
    nixosConfigurations.tower = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        home-manager.nixosModules.home-manager
        ./src/homes/tower/jaid.nix
        ./src/common.nix
        ./src/locales/en-de.nix
        ./src/users/jaid.nix
        ./src/machines/tower/configuration.nix
        ./src/machines/tower/hardware-configuration.nix
        ./src/software/gnome.nix
        ./src/software/desktop-apps.nix
        {
          environment.systemPackages = [
            pkgsUnstable.ghostty
            (pkgsUnstable.ollama.override {
              acceleration = "cuda";
            })
            (pkgsLatest.llama-cpp.overrideAttrs (finalAttributes: previousAttributes: {
              pname = "${previousAttributes.pname}-jaid";
              meta.description = "${previousAttributes.meta.description} (optimized for AMD Zen 2 and Nvidia GeForce RTX 4070)";
              cmakeFlags =
                previousAttributes.cmakeFlags
                ++ [
                  (pkgs.lib.cmakeBool "GGML_NATIVE" true)
                  (pkgs.lib.cmakeBool "CMAKE_POSITION_INDEPENDENT_CODE" true)
                  (pkgs.lib.cmakeFeature "CMAKE_CUDA_FLAGS" "-t6")
                  (pkgs.lib.cmakeBool "GGML_CUDA_F16" true)
                  (pkgs.lib.cmakeBool "GGML_CUDA_FA_ALL_QUANTS" true)
                  (pkgs.lib.cmakeBool "GGML_CUDA_NO_PEER_COPY" true)
                  (pkgs.lib.cmakeBool "GGML_CUDA" true)
                  (pkgs.lib.cmakeFeature "GGML_SYCL_TARGET" "NVIDIA")
                  (pkgs.lib.cmakeFeature "CMAKE_CUDA_ARCHITECTURES" "89")
                  (pkgs.lib.cmakeFeature "GGML_RPC" "ON")
                ];
              env = rec {
                CFLAGS = "-O3";
                CXXFLAGS = CFLAGS;
                NIX_CFLAGS_COMPILE = (previousAttributes.env.NIX_CFLAGS_COMPILE or "") + " " + CFLAGS;
                NIX_CXXFLAGS_COMPILE = (previousAttributes.env.NIX_CXXFLAGS_COMPILE or "") + " " + CXXFLAGS;
              };
            }))
          ];
        }
        {
          networking.enableIPv6 = false;
          boot.kernelParams = ["ipv6.disable=1"];
          boot.kernel.sysctl."net.ipv6.conf.all.disable_ipv6" = 1;
          boot.kernel.sysctl."net.ipv6.conf.default.disable_ipv6" = 1;
          boot.kernel.sysctl."net.ipv6.conf.eno1.disable_ipv6" = 1;
        }
      ];
      specialArgs = {inherit inputs;};
    };
  };
}
