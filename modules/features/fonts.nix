_: {
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts.packages = [
      pkgs.nerd-fonts.fira-code
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-cjk-serif
      pkgs.noto-fonts-color-emoji
    ];
    fonts.fontconfig.defaultFonts.monospace = [ "FiraCode Nerd Font" ];
  };
}
