{ ... }: {
  flake.nixosModules.gnome = { pkgs, ... }: {
    services.gnome.core-os-services.enable = true;
    services.gnome.core-apps.enable = true;

    # core-shell (gnome-shell/mutter/gnome-session) stays off - niri is the actual
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
