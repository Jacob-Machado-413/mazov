{ ... }: {
  flake.nixosModules.gnome = { pkgs, ... }: {
    services.gnome.core-os-services.enable = true;
    services.gnome.core-apps.enable = true;

    # core-shell (gnome-shell/mutter/gnome-session) stays off - niri is the actual
    # compositor. gvfs and xdg-user-dirs are gated behind core-shell upstream despite
    # being generically useful, so they're pulled back in standalone: gvfs is what
    # gives nautilus trash/MTP/SMB/NFS mounting, xdg-user-dirs populates the
    # ~/Downloads-etc bookmarks its sidebar expects.
    services.gvfs.enable = true;
    systemd.packages = [ pkgs.xdg-user-dirs pkgs.xdg-user-dirs-gtk ];

    environment.gnome.excludePackages = with pkgs; [
      gnome-music
      gnome-maps
      gnome-text-editor
      gnome-calendar
      gnome-contacts
      gnome-weather
    ];
  };
}
