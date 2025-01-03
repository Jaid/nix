{ pkgs, pkgsLatest, ... }:
{
  environment.systemPackages = [
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
