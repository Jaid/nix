{
  _7zip-zstd,
  fetchFromGitHub,
}: let
  version = "26.02-v1.5.7-R2";
in
  _7zip-zstd.overrideAttrs (old: {
    inherit version;
    src = fetchFromGitHub {
      owner = "mcmilk";
      repo = "7-Zip-zstd";
      tag = "v${version}";
      hash = "sha256-0m4Q4920/tIatY28E5d89hYvp6Z0zE2v55rUSwig1+0";
      postFetch = ''
        rm -r $out/CPP/7zip/Compress/Rar*
      '';
    };
    meta = old.meta // {
      changelog = "https://github.com/mcmilk/7-Zip-zstd/releases/tag/v${version}";
    };
  })
