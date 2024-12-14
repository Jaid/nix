{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    fastfetch
    git
    gh
    fd
    sd
    eza
    dysk
    btop
    gdu
    bat
    curl
    wget
    jq
  ];
}
