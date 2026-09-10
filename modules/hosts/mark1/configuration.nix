{self,inputs,...}: {

  flake.nixosModules.mark1Configuration = {pkgs,lib,config, ...}: let
    system = pkgs.stdenv.hostPlatform.system;
  in {
  imports =
    [ # Include the results of the hardware scan.
     # ./hardware-configuration.nix
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
     inputs.home-manager.nixosModules.home-manager
    ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };

  # home-manager is here only to deliver LazyVim; everything else on this host
  # stays NixOS-managed.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users."phyllistine" = { ... }: {
      imports = [ inputs.lazyvim.homeManagerModules.default ];
      home.stateVersion = config.system.stateVersion;

      programs.lazyvim = {
        enable = true;

        # installDependencies pulls each extra's tools (rust-analyzer,
        # csharpier, sqlfluff, ...); runtime deps come from this host already.
        extras = {
          ai.claudecode.enable = true;
          # LazyVim turns blink on by default at runtime; declaring it is what
          # puts it in the nix dev path instead of being cloned.
          coding.blink.enable = true;
          coding.yanky.enable = true;
          lang.dotnet = { enable = true; installDependencies = true; };
          lang.nix = { enable = true; installDependencies = true; };
          lang.nushell.enable = true;
          lang.rust = { enable = true; installDependencies = true; };
          lang.sql = { enable = true; installDependencies = true; };
        };
      };
    };
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mark1"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # Use the WirePlumber session manager
    #wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."phyllistine" = {
    isNormalUser = true;
    description = "jacob machado";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.nushell;
    packages = with pkgs; [
    #  thunderbird
      claude-code
      vscodium
      obsidian
      vesktop
      chromium
      btop
      ghostty
      openssh
      prismlauncher
      wine
      bottles
      anki
      jujutsu
      rendercv
      audacity
      odin
      ols
      dotnet-sdk_10
      obs-studio
      spotify-player
      localsend
      fastfetch
      tesseract
      cmatrix
      fzf
      ripgrep
      fd
      tldr
      yazi
      imagemagick
      gdb
      gh
      glib #gdbus, which noctalia's template reload scripts use to tell ghostty to
      godot
      lazygit
      python3
      rustc
      cargo
      yt-dlp
      inputs.zen-browser.packages.${system}.default
    ];
  };

  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

 

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

  };
}
