_: {
  flake.nixosModules.retroarch = { pkgs, ... }: {
    environment.systemPackages = [
      (pkgs.retroarch.withCores (
        libretro: with libretro; [
          bsnes
          mesen
          sameboy
          mgba
          mupen64plus
          beetle-psx-hw
          beetle-pce
          genesis-plus-gx
          picodrive
          mame
          fbneo
          melonds
          flycast
          yabause
          ppsspp
          dolphin
          play
          scummvm
        ]
      ))
      pkgs.retroarch-assets
    ];
  };
}
