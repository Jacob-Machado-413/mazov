{ config, ... }:
let
  # The NixOS module below has its own `config`, which shadows this one.
  inherit (config.mark1) monitors primaryMonitor;
in
{
  flake.nixosModules.tuigreet =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      # Boot status lines otherwise keep printing onto the greeter's VT.
      boot = {
        kernelParams = [
          "quiet"
          "udev.log_level=3"
        ];
        consoleLogLevel = 3;
        initrd.verbose = false;
      };

      services.greetd = {
        enable = true;
        settings.default_session.command = builtins.concatStringsSep " " [
          (lib.getExe pkgs.tuigreet)
          "--time"
          "--remember"
          "--remember-user-session"
          "--asterisks"
          "--background matrix"
          "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
        ];
      };

      # The VT spans every display; this sizes it to the primary one only.
      environment.etc."tuigreet/config.toml".source = (pkgs.formats.toml { }).generate "tuigreet.toml" {
        outputs = lib.mapAttrsToList (connector: _: {
          inherit connector;
          primary = connector == primaryMonitor;
          enabled = connector == primaryMonitor;
        }) monitors;
      };

      # --remember* writes here as the greeter user.
      systemd.tmpfiles.rules = [ "d /var/cache/tuigreet 0755 greeter greeter -" ];
    };
}
