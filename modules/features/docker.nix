{ ... }: {
  flake.nixosModules.docker = { pkgs, ... }: {
    virtualisation.docker.enable = true;
    environment.systemPackages = [ pkgs.lazydocker ];
  };
}
