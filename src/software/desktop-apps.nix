{pkgs, ...}: {
  imports = [
    ./xnview.nix
  ];
  environment.systemPackages = let
    thorium = pkgs.callPackage ../packages/thorium.nix {};
  in
    with pkgs; [
      thorium
      vscode
      keeweb
      discord
      # ghostty # BLOCKEDBY https://mitchellh.com/writing/ghostty-is-coming - not open-source yet
      # chatterino2
      mpv
      krita
      # blender
    ];
}
