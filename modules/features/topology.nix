{ inputs, ... }:
{
  # `nix build .#topology.x86_64-linux.config.output` renders the diagrams.
  imports = [ inputs.nix-topology.flakeModule ];

  flake.nixosModules.topology = {
    imports = [ inputs.nix-topology.nixosModules.default ];
  };
}
