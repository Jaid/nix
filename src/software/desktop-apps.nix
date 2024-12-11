{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.vscode
    # pkgs.ghostty # BLOCKEDBY https://mitchellh.com/writing/ghostty-is-coming - not open-source yet
  ];
}
