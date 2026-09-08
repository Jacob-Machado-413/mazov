{ inputs, ... }: {
  flake.nixosModules.noctaliaGreeter = {
    imports = [ inputs.noctalia-greeter.nixosModules.default ];

    programs.noctalia-greeter = {
      enable = true;
      settings = {
        # Mirrors the output layout in niri.nix (DP-2 right of HDMI-A-1);
        # the greeter runs its own compositor so it doesn't inherit niri's
        # arrangement automatically.
        output.layout = "HDMI-A-1:0,0; DP-2:1920,-80";

        # Follows noctalia's live theme/wallpaper instead of a fixed copy -
        # actually populating it still needs Sync Now (or Auto-Sync Greeter)
        # from Noctalia's own settings; that's runtime state, not nix-managed.
        appearance.scheme = "Synced";
      };

      # Without this, every sync needs an admin password prompt.
      passwordless-sync-users = [ "phyllistine" ];
    };
  };
}
