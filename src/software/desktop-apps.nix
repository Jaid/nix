{ pkgs, ... }: {
  imports = [
    ./xnview.nix
  ];
  environment.systemPackages = let
    thorium = pkgs.callPackage ../packages/thorium.nix {};
  in with pkgs; [
    thorium
    vscode
    keeweb
    # pkgs.discord
    # pkgs.ghostty # BLOCKEDBY https://mitchellh.com/writing/ghostty-is-coming - not open-source yet
    # pkgs.chatterino2
    mpv
    # pkgs.krita
    # pkgs.blender
  ];
}
