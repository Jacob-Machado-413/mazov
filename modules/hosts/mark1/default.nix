{self,inputs,...}: {
  flake.nixosConfigurations.mark1 =inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.mark1Configuration
    ];
  };
}
