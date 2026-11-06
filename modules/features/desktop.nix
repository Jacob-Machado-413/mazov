{ self, inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      self.packages.${stdenv.hostPlatform.system}.myGhostty
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

  perSystem =
    { pkgs, ... }:
    {
      packages.myGhostty = inputs.wrapper-modules.wrappers.ghostty.wrap {
        inherit pkgs;
        settings = {
          # Noctalia generates this into ~/.config/ghostty/themes.
          theme = "noctalia";
          background-opacity = "0.9";
          confirm-close-surface = false;
          keybind = [ "ctrl+enter=unbind" ];
        };
      };
    };
}
