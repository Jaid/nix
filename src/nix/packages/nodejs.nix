{
  cpuArch,
  lib,
  lief,
  nodejs_latest,
  nodejs-slim_latest,
}: let
  nodejsSlim = nodejs-slim_latest.overrideAttrs (old: {
    buildInputs = builtins.filter (package: lib.getName package != "lief") old.buildInputs;
    configureFlags =
      builtins.filter (flag: !(lib.hasPrefix "--shared-lief" flag)) old.configureFlags
      ++ [
        "--experimental-enable-pointer-compression"
        "--without-amaro"
        "--without-lief"
      ];
    env = (old.env or {}) // {
      NIX_CFLAGS_COMPILE = lib.concatStringsSep " " (builtins.filter (flag: flag != "") [
        (old.env.NIX_CFLAGS_COMPILE or "")
        "-march=${cpuArch}"
        "-mtune=${cpuArch}"
      ]);
    };
    postInstall = builtins.replaceStrings
      [(builtins.unsafeDiscardStringContext "${lib.getDev lief}/include/* ")]
      [""]
      (builtins.unsafeDiscardStringContext old.postInstall);
    requiredSystemFeatures = lib.unique ((old.requiredSystemFeatures or []) ++ ["gccarch-${cpuArch}"]);
  });
in
  nodejs_latest.override {
    nodejs-slim = nodejsSlim;
  }
