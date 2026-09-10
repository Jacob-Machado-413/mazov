{ ... }: {
  # Compose(caps)+space+<key> expands to a stock string.

  # The sequences themselves live in ~/.XCompose
  #prolly should get more robust secret management
  flake.nixosModules.xcompose = { config, ... }: {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      # niri speaks text-input-v3/input-method-v2, so no GTK_IM_MODULE or
      # QT_IM_MODULE shims are needed.
      fcitx5.waylandFrontend = true;
    };

    # fcitx5 ships only an XDG autostart entry, which niri doesn't run.
    systemd.user.services.fcitx5 = {
      description = "fcitx5 input method";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${config.i18n.inputMethod.package}/bin/fcitx5";
        Restart = "on-failure";
      };
    };
  };
}
