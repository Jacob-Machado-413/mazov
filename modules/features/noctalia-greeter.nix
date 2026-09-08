{ inputs, ... }: {
  flake.nixosModules.noctaliaGreeter = {
    imports = [ inputs.noctalia-greeter.nixosModules.default ];

    programs.noctalia-greeter = {
      enable = true;
      settings = {
        # Mirrors the output layout in niri.nix (DP-2 right of HDMI-A-1);

        output.layout = "HDMI-A-1:0,0; DP-2:1920,-80";


        appearance.scheme = "Synced";
      };

      passwordless-sync-users = [ "phyllistine" ];
    };
  };
}
