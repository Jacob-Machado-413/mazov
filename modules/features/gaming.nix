_: {
  flake.nixosModules.gaming = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      prismlauncher
      wine
      bottles
    ];
  };
}
