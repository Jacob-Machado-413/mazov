_: {
  flake.nixosModules.tuigreet =
    { config, pkgs, ... }:
    {
      services.greetd = {
        enable = true;
        settings.default_session.command = builtins.concatStringsSep " " [
          (pkgs.lib.getExe pkgs.tuigreet)
          "--time"
          "--remember"
          "--remember-user-session"
          "--asterisks"
          "--background matrix"
          "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
        ];
      };

      # --remember* writes here as the greeter user.
      systemd.tmpfiles.rules = [ "d /var/cache/tuigreet 0755 greeter greeter -" ];
    };
}
