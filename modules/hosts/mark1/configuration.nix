{ self, config, ... }:
let
  # The NixOS module below has its own `config`, which shadows this one.
  inherit (config.mark1) user;
in
{
  flake.nixosModules.mark1Configuration =
    { pkgs, ... }:
    {
      imports = [
        self.nixosModules.niri
        self.nixosModules.mark1Hardware
        self.nixosModules.noctalia
        self.nixosModules.noctaliaGreeter
        self.nixosModules.git
        self.nixosModules.steam
        self.nixosModules.nushell
        self.nixosModules.starship
        self.nixosModules.eza
        self.nixosModules.docker
        self.nixosModules.fonts
        self.nixosModules.retroarch
        self.nixosModules.gnome
        self.nixosModules.xcompose
        self.nixosModules.webapps
        self.nixosModules.flutter
        self.nixosModules.vis
        self.nixosModules.zen
        self.nixosModules.dev
        self.nixosModules.cli
        self.nixosModules.gaming
        self.nixosModules.media
        self.nixosModules.desktop
        self.nixosModules.nh
      ];

      programs.noctalia = {
        enable = true;
        systemd.enable = true;
      };

      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        # Dedupes the store on a timer instead of during every build.
        optimise.automatic = true;
        channel.enable = false;
      };

      boot.loader = {
        systemd-boot.enable = true;
        # /boot is a small vfat partition; old kernels/initrds would fill it.
        systemd-boot.configurationLimit = 10;
        efi.canTouchEfiVariables = true;
      };

      networking.hostName = "mark1";
      networking.networkmanager.enable = true;

      time.timeZone = "America/Los_Angeles";
      i18n.defaultLocale = "en_US.UTF-8";

      security.rtkit.enable = true;
      services = {
        printing.enable = true;
        pulseaudio.enable = false;
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };
      };

      users.users.${user} = {
        isNormalUser = true;
        description = "jacob machado";
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
        ];
        shell = pkgs.nushell;
      };

      system.stateVersion = "26.05";
    };
}
