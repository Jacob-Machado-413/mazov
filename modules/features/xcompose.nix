_: {
  # Compose(caps)+space+<key> expands to a stock string.

  # The sequences themselves live in ~/.XCompose
  flake.nixosModules.xcompose = { config, ... }: {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
    };

    systemd.user.services.fcitx5 = {
      description = "fcitx5 input method";
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${config.i18n.inputMethod.package}/bin/fcitx5";
        Restart = "on-failure";
      };
    };
  };
}
