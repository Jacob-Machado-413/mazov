{ ... }: {
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts.packages = [ pkgs.fira-code ];
  };
}
