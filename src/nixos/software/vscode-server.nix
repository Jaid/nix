{pkgs, ...}: {
  services.vscode-server.enable = true;
  services.vscode-server.enableFHS = true;
  # nixos-vscode-server still defaults FHS mode to Node 20, which is now marked
  # insecure on nixpkgs 26.05. Current VS Code releases use Node 22.
  services.vscode-server.nodejsPackage = pkgs.nodejs_22;
}
