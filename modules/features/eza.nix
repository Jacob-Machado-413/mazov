{ ... }: {
  flake.nixosModules.eza = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.eza ];

    # Only alias bash's ls - nushell has its own builtin ls and isn't
    # affected by this.
    programs.bash.shellAliases.ls = "eza";
  };
}
