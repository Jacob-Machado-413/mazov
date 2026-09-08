{ inputs, ... }: {
  flake.nixosModules.noctalia = inputs.noctalia.nixosModules.default;
}