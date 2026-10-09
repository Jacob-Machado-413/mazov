_: {
  perSystem =
    { pkgs, ... }:
    {
      # `nix flake check` fails on unformatted files, statix lints, or dead code.
      checks.lint =
        pkgs.runCommand "lint"
          {
            nativeBuildInputs = [
              pkgs.nixfmt
              pkgs.statix
              pkgs.deadnix
            ];
          }
          ''
            cd ${../.}
            find . -name '*.nix' -exec nixfmt --check {} +
            statix check .
            deadnix --fail .
            touch $out
          '';
    };
}
