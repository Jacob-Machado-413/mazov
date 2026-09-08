{ ... }: {
  flake.nixosModules.retroarch = { pkgs, ... }: {
    environment.systemPackages = [
      (pkgs.retroarch.withCores (libretro: with libretro; [
        bsnes
        mame
        mame2016
        ppsspp
        dolphin
        mupen64plus
        melonds
        desmume
        flycast
        genesis-plus-gx
        gambatte
        mgba
        snes9x
        beetle-psx
        beetle-psx-hw
        beetle-pce
        beetle-pce-fast
        beetle-supergrafx
        scummvm
        nestopia
        sameboy
        picodrive
        blastem
        yabause
        mesen
        mesen-s
        parallel-n64
        play
        fbneo
      ]))
      pkgs.retroarch-assets
    ];
  };
}
