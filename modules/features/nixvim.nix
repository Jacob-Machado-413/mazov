{ self, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      nixvim = inputs.nixvim.lib.evalNixvim {
        modules = [
          {
            # Reuse the flake's single nixpkgs instance.
            nixpkgs.pkgs = pkgs;

            viAlias = true;
            vimAlias = true;

            plugins.treesitter = {
              enable = true;
              settings.highlight.enable = true;
            };

            plugins.lsp = {
              enable = true;
              servers = {
                nixd.enable = true;
                rust_analyzer = {
                  enable = true;
                  # Toolchains come from devShells.
                  installCargo = false;
                  installRustc = false;
                };
                csharp_ls.enable = true;
                sqls.enable = true;
                ols.enable = true;
                basedpyright.enable = true;
              };
            };
          }
        ];
      };
    in
    {
      packages.nixvim = nixvim.config.build.package;
      checks.nixvim = nixvim.config.build.test;
    };

  flake.nixosModules.nixvim =
    { pkgs, ... }:
    {
      environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.nixvim ];
    };
}
