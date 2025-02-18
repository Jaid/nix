# Based on: https://github.com/thomX75/nixos-modules/blob/main/XnViewMP/xnviewmp.nix
{
  pkgs,
  version ? "1.8.6",
  sha256 ? "MJdVKU+Q4sB7B2W84of7aW/wK7g1oQN4E9Ss2v7mnrg=",
  ...
}: let
  icon =
    pkgs.runCommand "xnviewmp-icon" {
      nativeBuildInputs = [pkgs.imagemagick];
      src = pkgs.fetchurl {
        url = "https://www.xnview.com/img/app-xnviewmp-512.webp";
        sha256 = "10zcr396y6fj8wcx40lyl8gglgziaxdin0rp4wb1vca4683knnkd";
      };
    } ''
      mkdir -p $out/share/icons/hicolor/512x512/apps
      convert $src $out/share/icons/hicolor/512x512/apps/xnviewmp.png
    '';
in
  pkgs.appimageTools.wrapType2 {
    name = "xnviewmp-${version}";
    src = pkgs.fetchurl {
      url = "https://download.xnview.com/XnView_MP.glibc2.17-x86_64.AppImage";
      inherit sha256;
    };
    extraPkgs = pkgs: [
      pkgs.qt5.qtbase
    ];
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/xnviewmp.desktop <<EOF
      [Desktop Entry]
      Type=Application
      Name=XnView MP
      Icon=xnviewmp
      Exec=xnviewmp-${version} %F
      Categories=Graphics;
      EOF
      mkdir -p $out/share/icons/hicolor/512x512/apps
      cp ${icon}/share/icons/hicolor/512x512/apps/xnviewmp.png $out/share/icons/hicolor/512x512/apps/
    '';
  }
