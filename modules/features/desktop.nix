{ inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ghostty
      glib # gdbus, needed for ghostty themes
      obsidian
      basalt
      vesktop
      anki
      localsend
      rendercv
      chromium
      kdePackages.ocean-sound-theme
      pantheon.elementary-sound-theme
      inputs.todo-odin.packages.${pkgs.stdenv.hostPlatform.system}.todo
    ];
  };
}
