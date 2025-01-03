{pkgsUnstable, ...}: {
  environment.systemPackages = [
    pkgsUnstable.ghostty
    (pkgsUnstable.ollama.override {
      acceleration = "cuda";
    })
  ];
}
