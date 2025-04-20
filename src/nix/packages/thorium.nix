# Check for updates at https://github.com/Alex313031/thorium/releases
# Based on https://github.com/ethanthoma/nixos-config/blob/cdc15f5ffeb95bcf31345f641a4a0703ac6005f6/host/common/thorium.nix
{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "thorium-browser";
  version = "130.0.6723.174";
  src = pkgs.fetchurl {
    url = "https://github.com/Alex313031/thorium/releases/download/M${version}/thorium-browser_${version}_AVX2.deb";
    hash = "sha256-TeDwx7Bqy0NSaNBMuzCf4O+rgWjB/tmIvDgJQnGVSGY=";
  };
  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.dpkg
    pkgs.wrapGAppsHook
    pkgs.qt6.wrapQtAppsHook
  ];
  buildInputs = [
    pkgs.stdenv.cc.cc.lib
    pkgs.alsa-lib
    pkgs.at-spi2-atk
    pkgs.at-spi2-core
    pkgs.cairo
    pkgs.cups
    pkgs.curl
    pkgs.dbus
    pkgs.expat
    pkgs.ffmpeg
    pkgs.fontconfig
    pkgs.freetype
    pkgs.glib
    pkgs.glibc
    pkgs.gtk3
    pkgs.gtk4
    pkgs.libcanberra
    pkgs.liberation_ttf
    pkgs.libexif
    pkgs.libglvnd
    pkgs.libkrb5
    pkgs.libnotify
    pkgs.libpulseaudio
    pkgs.libu2f-host
    pkgs.libva
    pkgs.libxkbcommon
    pkgs.mesa
    pkgs.nspr
    pkgs.nss
    pkgs.qt6.qtbase
    pkgs.pango
    pkgs.pciutils
    pkgs.pipewire
    pkgs.speechd
    pkgs.udev
    pkgs.unrar
    pkgs.vaapiVdpau
    pkgs.vulkan-loader
    pkgs.wayland
    pkgs.wget
    pkgs.xdg-utils
    pkgs.xfce.exo
    pkgs.xorg.libxcb
    pkgs.xorg.libX11
    pkgs.xorg.libXcursor
    pkgs.xorg.libXcomposite
    pkgs.xorg.libXdamage
    pkgs.xorg.libXext
    pkgs.xorg.libXfixes
    pkgs.xorg.libXi
    pkgs.xorg.libXrandr
    pkgs.xorg.libXrender
    pkgs.xorg.libXtst
    pkgs.xorg.libXxf86vm
  ];
  autoPatchelfIgnoreMissingDeps = [
    "libQt5Widgets.so.5"
    "libQt5Gui.so.5"
    "libQt5Core.so.5"
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/* $out
    cp -r etc $out
    cp -r opt $out
    ln -sf $out/opt/chromium.org/thorium/thorium-browser $out/bin/thorium-browser
    substituteInPlace $out/share/applications/thorium-shell.desktop \
    --replace /usr/bin $out/bin \
    --replace /opt $out/opt
    substituteInPlace $out/share/applications/thorium-browser.desktop \
    --replace /usr/bin $out/bin \
    --replace StartupWMClass=thorium StartupWMClass=thorium-browser \
    --replace Icon=thorium-browser Icon=$out/opt/chromium.org/thorium/product_logo_256.png
    addAutoPatchelfSearchPath $out/chromium.org/thorium
    addAutoPatchelfSearchPath $out/chromium.org/thorium/lib
    substituteInPlace $out/opt/chromium.org/thorium/thorium-browser \
    --replace 'export LD_LIBRARY_PATH' "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${lib.makeLibraryPath buildInputs}:$out/chromium.org/thorium:$out/chromium.org/thorium/lib" \
    --replace /usr $out
    runHook postInstall
  '';
}
