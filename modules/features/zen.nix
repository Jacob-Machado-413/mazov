{ self, inputs, ... }: {
  perSystem =
    { pkgs, ... }:
    let
      zen = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system};
      wrapZen = import "${inputs.zen-browser}/wrap-zen.nix" pkgs.wrapFirefox;

      # Zen sandboxes mozilla.cfg by default; the stylesheet service needs chrome privileges.
      autoconfig = pkgs.writeText "square-autoconfig.js" ''
        pref("general.config.filename", "square.cfg");
        pref("general.config.obscure_value", 0);
        pref("general.config.sandbox_enabled", false);
      '';

      mozillaCfg = pkgs.writeText "square.cfg" ''
        // First line must be a comment

        // A user sheet's !important beats a page's own !important, and it covers Zen's UI too.
        try {
          Components.classes["@mozilla.org/observer-service;1"]
            .getService(Components.interfaces.nsIObserverService)
            .addObserver({
              observe() {
                const sss = Components.classes["@mozilla.org/content/style-sheet-service;1"]
                  .getService(Components.interfaces.nsIStyleSheetService);
                const uri = Components.classes["@mozilla.org/network/io-service;1"]
                  .getService(Components.interfaces.nsIIOService)
                  .newURI("file://${./square.css}");
                if (!sss.sheetRegistered(uri, sss.USER_SHEET)) {
                  sss.loadAndRegisterSheet(uri, sss.USER_SHEET);
                }
              },
            }, "final-ui-startup");
        } catch (e) {
          Components.utils.reportError(e);
        }

        // Prefs the Transparent Zen mod needs
        pref("browser.tabs.allow_transparent_browser", true);
        pref("zen.widget.linux.transparency", true);
        pref("zen.theme.gradient.show-custom-colors", true);
        pref("zen.view.grey-out-inactive-windows", false);
        pref("widget.transparent-windows", true);
      '';

      # Gecko reads autoconfig next to the unwrapped binary, so wrapFirefox's extraPrefs never load.
      # Named apart from wrapFirefox's autoconfig.js/mozilla.cfg, which it writes through symlinks into here.
      unwrapped = zen.beta-unwrapped.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          for libdir in "$out"/lib/zen-bin-*; do
            chmod -R u+w "$libdir/defaults"
            install -D -m 644 ${autoconfig} "$libdir/defaults/pref/square-autoconfig.js"
            install -m 644 ${mozillaCfg} "$libdir/square.cfg"
          done
        '';
      });
    in
    {
      packages.myZen = wrapZen unwrapped { icon = "zen-browser"; };
    };

  flake.nixosModules.zen = { pkgs, ... }: {
    environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.myZen ];
  };
}
