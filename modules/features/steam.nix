{ ... }: {
  flake.nixosModules.steam = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      # Millennium (steambrew.app), used for noctalia autotheming of steam
      package = pkgs.millennium-steam;
    };

    hardware.steam-hardware.enable = true;
  };
}
