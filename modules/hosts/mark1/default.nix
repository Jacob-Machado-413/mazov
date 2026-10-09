{
  self,
  inputs,
  withSystem,
  ...
}:
{
  flake.nixosConfigurations.mark1 = withSystem "x86_64-linux" (
    { pkgs, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.pkgs = pkgs; }
        self.nixosModules.mark1Configuration
      ];
    }
  );
}
