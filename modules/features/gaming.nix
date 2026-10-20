{ inputs, ... }:
{
  flake.nixosModules.gaming =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        prismlauncher
        wine
        bottles
        # Taken from the flake's own packages, which allow its insecure electron_40.
        inputs.grimoire.packages.${stdenv.hostPlatform.system}.default
      ];
    };
}
