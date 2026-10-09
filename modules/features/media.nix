_: {
  flake.nixosModules.media = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      audacity
      obs-studio
      spotify
      calibre
    ];
  };
}
