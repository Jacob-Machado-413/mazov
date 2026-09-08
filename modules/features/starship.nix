{ ... }: {
  flake.nixosModules.starship = { ... }: {
    programs.starship.enable = true;
  };
}
