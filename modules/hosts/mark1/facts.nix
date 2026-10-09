{ lib, ... }: {
  # Host values that both NixOS modules and perSystem packages (myNiri) read.
  options.mark1 = {
    user = lib.mkOption { type = lib.types.str; };
    monitors = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.x = lib.mkOption { type = lib.types.int; };
          options.y = lib.mkOption { type = lib.types.int; };
        }
      );
    };
  };

  config.mark1 = {
    user = "phyllistine";

    # AOC 27B2 is physically on the right, Sceptre F24 on the left
    monitors = {
      "HDMI-A-1" = {
        x = 0;
        y = 0;
      };
      "DP-2" = {
        x = 1920;
        y = -80;
      };
    };
  };
}
