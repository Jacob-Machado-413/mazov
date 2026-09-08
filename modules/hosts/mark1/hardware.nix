{self,inputs,...}: {

  flake.nixosModules.mark1Hardware= { config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  # nvidia/nvidia_modeset/nvidia_drm aren't X-gated here like the NixOS nvidia
  # module's own list - services.xserver.enable is false (niri is Wayland-only),
  # so without this they'd depend on udev autoloading them correctly.
  boot.kernelModules = [ "kvm-amd" "nvidia" "nvidia_modeset" "nvidia_drm" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/0c67362e-45de-4b67-8500-a0016e7a183d";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A519-59A4";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/680ba7f1-77e4-450f-b76d-415988bbbf1f"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # GTX 1080 Ti is Pascal, which newer driver branches (595.x+) dropped -
    # legacy_580 is the last branch that still supports Maxwell/Pascal/Volta.
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    # Required (no default) on driver >=560; open kernel modules only support
    # Turing and later, which this Pascal-era card predates.
    open = false;
  };
};
}
