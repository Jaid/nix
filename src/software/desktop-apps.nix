{pkgs, ...}: {
  imports = [
    ./xnview.nix
  ];
  environment.systemPackages = let
    thorium = pkgs.callPackage ../packages/thorium.nix {};
  in
    [
      thorium
      pkgs.vscode
    ];
}
