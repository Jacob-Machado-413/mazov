_: {
  flake.nixosModules.nh = _: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        # --keep is a floor: the newest 3 survive regardless of age
        extraArgs = "--keep 3 --keep-since 7d";
      };
    };
  };
}
