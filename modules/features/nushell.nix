{ ... }: {
  flake.nixosModules.nushell = { pkgs, lib, ... }: {
    programs.nushell = {
      enable = true;
   
      #special starship nushell hack
      autoloads = [
        (pkgs.runCommand "starship-init.nu" { } ''
          mkdir -p $out/share/nushell/vendor/autoload
          ${lib.getExe pkgs.starship} init nu > $out/share/nushell/vendor/autoload/starship-init.nu
        '')

        (pkgs.writeTextDir "share/nushell/vendor/autoload/aliases.nu" ''
          alias la = ls -a
        '')
      ];
    };

    # nushell is the default login shell (set per-user in the host config);
    # bash stays available as a normal fallback.
    environment.shells = [ pkgs.nushell pkgs.bash ];
  };
}
