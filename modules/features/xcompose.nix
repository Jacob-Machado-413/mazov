{ self, config, ... }:
let
  # The NixOS module below has its own `config`, which shadows this one.
  inherit (config.mark1) user;
in
{
  # Compose(caps)+space+<key> expands to a stock string.
  flake.nixosModules.xcompose =
    { config, ... }:
    let
      inherit (config.sops) placeholder;
    in
    {
      imports = [ self.nixosModules.secrets ];

      sops.secrets = {
        email = { };
        phone = { };
        address = { };
      };

      # Rendered at activation so the private values never enter the store.
      sops.templates.xcompose = {
        owner = user;
        content = ''
          include "%L"

          <Multi_key> <space> <n> : "Jacob Machado"
          <Multi_key> <space> <e> : "${placeholder.email}"
          <Multi_key> <space> <w> : "jacobmachado.com"
          <Multi_key> <space> <p> : "${placeholder.phone}"
          <Multi_key> <space> <a> : "${placeholder.address}"
          <Multi_key> <space> <l> : "https://www.linkedin.com/in/jacob-machado/"
          <Multi_key> <space> <g> : "https://github.com/Jacob-Machado-413"
        '';
      };

      # libxkbcommon checks XCOMPOSEFILE before ~/.XCompose.
      environment.sessionVariables.XCOMPOSEFILE = config.sops.templates.xcompose.path;

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
