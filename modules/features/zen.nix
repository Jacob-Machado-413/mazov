{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    # Prefs the Transparent Zen mod needs; pref() (not lockPref) keeps them
    packages.myZen = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      extraPrefs = ''
        pref("browser.tabs.allow_transparent_browser", true);
        pref("zen.widget.linux.transparency", true);
        pref("zen.theme.gradient.show-custom-colors", true);
        pref("zen.view.grey-out-inactive-windows", false);
        pref("widget.transparent-windows", true);
      '';
    };
  };
}
