{
  description = "Jaid’s NixOS setup";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-latest.url = "github:NixOS/nixpkgs?ref=master";
    home-manager.url = "github:nix-community/home-manager?ref=release-26.05";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };
  outputs = inputs: let
    makeMachine = {
      id,
      system ? "x86_64-linux",
      cudaComputeCapability ? "8.9",
      cpuArch ? "znver2",
      gpuVendor ? "nvidia",
      isVm ? false,
      modules ? [],
    }: let
      nixpkgsAttributes = {
        inherit system;
        config = {
          allowUnfree = true;
          nvidia.acceptLicense = true;
        };
      };
      nixpkgsPersonalAttributes = {
        inherit system;
        config = {
          allowUnfree = true;
          nvidia.acceptLicense = true;
          cudaSupport = gpuVendor == "nvidia";
          cudnnSupport = gpuVendor == "nvidia";
          cudaForwardCompat = false;
          cudaEnableForwardCompat = false;
          cudaCapabilities = [cudaComputeCapability];
          rocmSupport = gpuVendor == "amd";
          packageOverrides = pkgs: {
            shantell-sans = pkgs.callPackage ./src/nix/packages/shantell-sans.nix {};
            geologica = pkgs.callPackage ./src/nix/packages/geologica.nix {};
          };
        };
      };
      personalizePackage = package:
        package.overrideAttrs (old: {
          env = (old.env or {}) // {
            NIX_CFLAGS_COMPILE = inputs.nixpkgs.lib.concatStringsSep " " (builtins.filter (flag: flag != "") [
              (old.env.NIX_CFLAGS_COMPILE or "")
              "-march=${cpuArch}"
              "-mtune=${cpuArch}"
            ]);
          };
          requiredSystemFeatures = inputs.nixpkgs.lib.unique ((old.requiredSystemFeatures or []) ++ ["gccarch-${cpuArch}"]);
        });
      personalizeNodejs = packageSet:
        (personalizePackage packageSet.nodejs-slim_latest).overrideAttrs (old: {
          buildInputs = builtins.filter (package: inputs.nixpkgs.lib.getName package != "lief") old.buildInputs;
          configureFlags =
            builtins.filter (flag: !(inputs.nixpkgs.lib.hasPrefix "--shared-lief" flag)) old.configureFlags
            ++ [
              "--experimental-enable-pointer-compression"
              "--without-amaro"
              "--without-lief"
            ];
          postInstall = builtins.replaceStrings
            [(builtins.unsafeDiscardStringContext "${inputs.nixpkgs.lib.getDev packageSet.lief}/include/* ")]
            [""]
            (builtins.unsafeDiscardStringContext old.postInstall);
        });
      personalPackageFactories = {
        nodejs_latest = packageSet:
          packageSet.nodejs_latest.override {
            nodejs-slim = personalizeNodejs packageSet;
          };
      };
      makePersonalPackageSet = packageSet:
        packageSet
        // inputs.nixpkgs.lib.mapAttrs (_: factory: factory packageSet) personalPackageFactories;
      pkgs = import inputs.nixpkgs nixpkgsAttributes;
      pkgsUnstable = import inputs.nixpkgs-unstable nixpkgsAttributes;
      pkgsLatest = import inputs.nixpkgs-latest nixpkgsAttributes;
      pkgsPersonal = makePersonalPackageSet (import inputs.nixpkgs nixpkgsPersonalAttributes);
      pkgsUnstablePersonal = makePersonalPackageSet (import inputs.nixpkgs-unstable nixpkgsPersonalAttributes);
      pkgsLatestPersonal = makePersonalPackageSet pkgsLatest;
      specialArgs = {
        inherit pkgsUnstable;
        inherit pkgsLatest;
        inherit pkgsPersonal;
        inherit pkgsUnstablePersonal;
        inherit pkgsLatestPersonal;
      };
    in
      inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          [
            inputs.nixpkgs.nixosModules.readOnlyPkgs
            {
              nixpkgs.pkgs = pkgs;
            }
            {
              system.systemBuilderCommands =
                builtins.trace
                  "Building ${id} (${system}, ${cpuArch}, ${cudaComputeCapability})"
                  "";
            }
          ]
          ++ modules
          ++ [
            {
              networking.hostName = id;
              environment.sessionVariables.HOSTNAME = id;
              nix.settings.system-features = ["gccarch-${cpuArch}"];
            }
            inputs.home-manager.nixosModules.home-manager
            ./src/home-manager/homes/linux/jaid.nix
            ./src/home-manager/homes/${id}/jaid.nix
            ./src/nixos/common.nix
            ./src/nixos/locales/en-de.nix
            ./src/nixos/users/jaid.nix
            ./src/nix/config.nix
            ./src/nixos/modules/xnview.nix
            ./src/nixos/modules/qemu.nix
            ./src/nixos/modules/gnome-wayland
            ./src/nixos/modules/eza.nix
            ./src/nixos/modules/lan-dns.nix
            ./src/nixos/modules/performance
            ./src/nixos/machines/${id}/configuration.nix
          ]
          ++ (
            if isVm
            then [
            ]
            else [
              ./src/nixos/machines/${id}/hardware-configuration.nix
            ]
          );
      };
  in {
    nixosConfigurations = {
      tower = makeMachine {
        id = "tower";
      };
      tower-vm = makeMachine {
        id = "tower-vm";
        isVm = true;
      };
      nas = makeMachine {
        id = "nas";
        cpuArch = "alderlake";
        modules = [
          inputs.vscode-server.nixosModules.default
        ];
      };
      cx = makeMachine {
        id = "cx";
        modules = [
          inputs.vscode-server.nixosModules.default
        ];
      };
      hive = makeMachine {
        id = "hive";
        cpuArch = "znver2";
        gpuVendor = "amd";
        modules = [
          inputs.vscode-server.nixosModules.default
        ];
      };
    };
  };
}
