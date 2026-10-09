{
  inputs,
  config,
  lib,
  ...
}:
{
  flake.nixosModules.noctaliaGreeter = {
    imports = [ inputs.noctalia-greeter.nixosModules.default ];

    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        output.layout = lib.concatStringsSep "; " (
          lib.mapAttrsToList (name: pos: "${name}:${toString pos.x},${toString pos.y}") config.mark1.monitors
        );

        appearance.scheme = "Synced";
      };

      passwordless-sync-users = [ config.mark1.user ];
    };
  };
}
