{ inputs, ... }:
{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem =
    { config, ... }:
    {
      pre-commit = {
        # checks.lint already enforces formatting in CI.
        check.enable = false;
        settings.hooks.nixfmt.enable = true;
      };

      # Entering this shell installs the hook.
      devShells.default = config.pre-commit.devShell;
    };
}
