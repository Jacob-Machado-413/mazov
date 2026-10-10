{ inputs, ... }: {
  # `nix flake init -t ~/mazov#<lang>`; flutter is the one dev-templates lacks.
  flake.templates = inputs.dev-templates.templates // {
    flutter = {
      path = ../templates/flutter;
      description = "Flutter development environment";
    };
  };
}
