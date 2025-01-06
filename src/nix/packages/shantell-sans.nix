{
  lib,
  stdenvNoCC,
  fetchzip,
}: let
  name = "shantell-sans";
  version = "1.011";
  sha256 = "1scc91j7q4mv4q4skw2rr99yh4482mjmjqgyajgbq0vn542kh0f6";
in
  stdenvNoCC.mkDerivation {
    pname = name;
    version = "1.011";
    src = fetchzip {
      url = "https://github.com/arrowtype/shantell-sans/releases/download/${version}/Shantell_Sans_${version}.zip";
      hash = "sha256-${sha256}";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/fonts/truetype/${name}
      install -Dm444 *.ttf -t $out/share/fonts/truetype/${name}
      runHook postInstall
    '';
    meta = {
      homepage = "https://github.com/arrowtype/shantell-sans";
      description = "Shantell Sans font";
      longDescription = "Shantell Sans, from Shantell Martin, is a marker-style font built for creative expression, typographic play, and animation.";
      license = [lib.licenses.ofl];
      platforms = lib.platforms.all;
      maintainers = [];
    };
  }
