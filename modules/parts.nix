{ inputs, ... }: {
  config = {
    systems = [ "x86_64-linux" ];

    perSystem = { system, pkgs, ... }: {
      formatter = pkgs.nixfmt-tree;

      # The only nixpkgs instance; hosts receive it through nixpkgs.pkgs.
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ inputs.millennium.overlays.default ];
      };
    };
  };
}
