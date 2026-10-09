{ inputs, ... }: {
  config = {
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    perSystem = { system, pkgs, ... }: {
      formatter = pkgs.nixfmt-tree;

      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };
  };
}
