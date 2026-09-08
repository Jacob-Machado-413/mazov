{ ... }: {
  flake.nixosModules.nushell = { pkgs, lib, ... }: {
    programs.nushell = {
      enable = true;
      # Starship has no native nushell integration (unlike bash/zsh/fish), so
      # its init script is baked in as a vendor autoload script instead -
      # this is the officially documented way to wire the two together.
      autoloads = [
        (pkgs.runCommand "starship-init.nu" { } ''
          mkdir -p $out/share/nushell/vendor/autoload
          ${lib.getExe pkgs.starship} init nu > $out/share/nushell/vendor/autoload/starship.nu
        '')
      ];
    };

    # nushell is the default login shell (set per-user in the host config);
    # bash stays available as a normal fallback.
    environment.shells = [ pkgs.nushell pkgs.bash ];
  };
}
