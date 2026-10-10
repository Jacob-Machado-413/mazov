_: {
  flake.nixosModules.dev = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      claude-code
      vscodium
      vscode
      jujutsu
      lazygit
      gh
      gdb
      tokei
      statix
      deadnix
      odin
      ols
      python3
      godot
    ];
  };
}
