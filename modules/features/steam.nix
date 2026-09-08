{ inputs, ... }: {
  flake.nixosModules.steam = { pkgs, ... }: {
    # Millennium (steambrew.app) - Steam client theming/plugins. Not in
    # nixpkgs; the overlay comes from its own flake, per the official
    # NixOS install instructions.
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
