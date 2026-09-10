{ inputs, ... }: {
  flake.nixosModules.steam = { pkgs, ... }: {
    # Millennium (steambrew.app) - Steam client theming/plugins. 
    # used for noctalia autotheming of steam
    nixpkgs.overlays = [ inputs.millennium.overlays.default ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      package = pkgs.millennium-steam;
    };

    hardware.steam-hardware.enable = true;
  };
}
