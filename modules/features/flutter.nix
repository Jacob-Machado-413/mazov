{ ... }: {
  flake.nixosModules.flutter = { pkgs, lib, ... }: {
    # The nixpkgs wrapper already carries the linux desktop toolchain (clang,
    # cmake, ninja, pkg-config, gtk3), so only the web target needs wiring.
    environment.systemPackages = [ pkgs.flutter ];

    environment.sessionVariables.CHROME_EXECUTABLE = lib.getExe pkgs.chromium;
  };
}
