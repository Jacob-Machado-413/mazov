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
      odin
      ols
      dotnet-sdk_10
      python3
      rustc
      cargo
      godot
    ];
  };
}
