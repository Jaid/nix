{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.vscode
    pkgs.keeweb
    pkgs.discord
    # pkgs.ghostty # BLOCKEDBY https://mitchellh.com/writing/ghostty-is-coming - not open-source yet
  ];
}
