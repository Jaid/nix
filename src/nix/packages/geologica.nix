{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "geologica";
  version = "1.010";
  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "geologica";
    rev = "685f38d7c9e86b0c8530204c97ddcaf6558dd17b";
    hash = "sha256-4+taCJjNH9Tzw7NYME56GwpAXOKPR/JNn3ECrb2hOoM=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/truetype/${pname}
    install -Dm444 fonts/variable/*.ttf -t $out/share/fonts/truetype/${pname}
    runHook postInstall
  '';
  meta = {
    homepage = "https://github.com/googlefonts/geologica";
    description = "Geologica variable font";
    longDescription = "Geologica is grounded in the humanist genre, but leans assertively into geometric, constructed letterforms to find its stability. The wide stance, generous spacing, large apertures and even colour makes Geologica a serious text typeface. The stylistic “Sharpness” axis adds a rational interpretation of calligraphic pen strokes – a modernist echo of the roots of writing.";
    license = [lib.licenses.ofl];
    platforms = lib.platforms.all;
    maintainers = [];
  };
}
