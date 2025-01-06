{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "shantell-sans";
  version = "1.011";
  src = fetchzip {
    url = "https://github.com/arrowtype/shantell-sans/releases/download/${version}/Shantell_Sans_${version}.zip";
    hash = "sha256-xgE4BSl2A7yeVP5hWWUViBDoU8pZ8KkJJrsSfGRIjOk=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/truetype/${pname}
    install -Dm444 Desktop/*.ttf -t $out/share/fonts/truetype/${pname}
    runHook postInstall
  '';
  meta = {
    homepage = "https://github.com/arrowtype/shantell-sans";
    description = "Shantell Sans comic font";
    longDescription = "Shantell Sans, from Shantell Martin, is a marker-style font built for creative expression, typographic play, and animation.";
    license = [lib.licenses.ofl];
    platforms = lib.platforms.all;
    maintainers = [];
  };
}
