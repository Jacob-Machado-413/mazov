{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };

    # niri's own cursor.xcursor-theme/size (below) only covers native Wayland
    # clients. XWayland apps (Steam, Proton games) read XCURSOR_THEME/SIZE
    environment.sessionVariables = {
      XCURSOR_THEME = "Bibata-Modern-Ice";
      XCURSOR_SIZE = "20";
    };
    environment.systemPackages = [ pkgs.bibata-cursors pkgs.adwaita-icon-theme ];
  };

  perSystem = { pkgs, lib, ... }:
    let
      noctaliaExe = lib.getExe inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      ghosttyExe = lib.getExe pkgs.ghostty;

      noctalia = cmd: "${noctaliaExe} msg ${cmd}";
      inTerminal = cmd: "${ghosttyExe} -e ${cmd}";

      # Ported from omarchy: SUPER+1..9,0 focuses workspace 1..10;
      # SUPER+SHIFT+1..9,0 moves the focused window there too.
      workspaceBinds = lib.listToAttrs (
        lib.concatMap
          (n:
            let
              key = if n == 10 then "0" else toString n;
            in
            [
              { name = "Mod+${key}"; value.focus-workspace = n; }
              { name = "Mod+Shift+${key}"; value.move-window-to-workspace = n; }
            ])
          (lib.range 1 10)
      );

      #mimicing omarchy/hyprland 'scratchpad' with a named workspace. its 80% as good
      appsWorkspace = "apps";
      mkAppWorkspaceToggle = { appId, spawnCmd, extraInputs ? [ ] }:
        pkgs.writeShellApplication {
          name = "niri-toggle-${appId}";
          runtimeInputs = [ pkgs.niri pkgs.jq ] ++ extraInputs;
          text = ''
            app_id="${appId}"
            ws_name="${appsWorkspace}"

            current_app_id=$(niri msg -j windows | jq -r '.[] | select(.is_focused) | .app_id // empty')
            if [ "$current_app_id" = "$app_id" ]; then
              niri msg action focus-workspace-previous
              exit 0
            fi

            target_id=$(niri msg -j windows | jq -r --arg id "$app_id" '[.[] | select(.app_id == $id)] | .[0].id // empty')
            if [ -n "$target_id" ]; then
              niri msg action focus-window --id "$target_id"
            else
              ${spawnCmd} &
              niri msg action focus-workspace "$ws_name"
            fi
          '';
        };

      obsidianToggle = mkAppWorkspaceToggle {
        appId = "md.Obsidian";
        spawnCmd = lib.getExe pkgs.obsidian;
        extraInputs = [ pkgs.obsidian ];
      };

      vesktopToggle = mkAppWorkspaceToggle {
        appId = "vesktop";
        spawnCmd = lib.getExe pkgs.vesktop;
        extraInputs = [ pkgs.vesktop ];
      };

      coreBinds = {
        "Mod+Return".spawn-sh = ghosttyExe;
        "Mod+Q".close-window = [];

        "Print".screenshot = [];
        "Mod+O".spawn-sh = lib.getExe obsidianToggle;
        "Mod+Shift+O".spawn-sh = lib.getExe vesktopToggle;
        "Mod+Space".spawn-sh = noctalia "panel-toggle launcher";
        "Mod+F".fullscreen-window = [];

        # Focus window/column (omarchy: SUPER + arrows)
        "Mod+Left".focus-column-left = [];
        "Mod+Right".focus-column-right = [];
        "Mod+Up".focus-window-up = [];
        "Mod+Down".focus-window-down = [];

        # Move/swap window/column (omarchy: SUPER+SHIFT + arrows)
        "Mod+Shift+Left".move-column-left = [];
        "Mod+Shift+Right".move-column-right = [];
        "Mod+Shift+Up".move-window-up = [];
        "Mod+Shift+Down".move-window-down = [];

        # Workspace cycling (omarchy: SUPER+TAB / SUPER+SHIFT+TAB / SUPER+CTRL+TAB)
        "Mod+Tab".focus-workspace-down = [];
        "Mod+Shift+Tab".focus-workspace-up = [];
        "Mod+Ctrl+Tab".focus-workspace-previous = [];

        # Resize focused window/column (omarchy: SUPER+MINUS shrinks, SUPER+EQUAL grows)
        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";

        # Scroll across the row of columns (omarchy: SUPER + scroll)
        "Mod+WheelScrollDown".focus-column-right = [];
        "Mod+WheelScrollUp".focus-column-left = [];
      };

      windowBinds = {
        "Mod+T".toggle-window-floating = [];
        "Mod+Alt+F".maximize-column = [];
        "Mod+Ctrl+F".toggle-windowed-fullscreen = [];

        # niri's tabbed columns stand in for omarchy's window groups.
        "Mod+G".toggle-column-tabbed-display = [];
        "Mod+Alt+Left".consume-or-expel-window-left = [];
        "Mod+Alt+Right".consume-or-expel-window-right = [];

        # noctalia's window-switcher stays unbound; it suits umbriel, not niri.
        "Alt+Tab".toggle-overview = [];
        "Ctrl+Alt+Tab".focus-monitor-next = [];
        "Ctrl+Alt+Shift+Tab".focus-monitor-previous = [];
        "Mod+Alt+Shift+Left".move-workspace-to-monitor-left = [];
        "Mod+Alt+Shift+Right".move-workspace-to-monitor-right = [];

        # Print alone opens the interactive region UI; these skip the picker.
        "Ctrl+Print".screenshot-screen = [];
        "Alt+Print".screenshot-window = [];
      };

      systemBinds = {
        "Mod+Ctrl+V".spawn-sh = noctalia "panel-toggle clipboard";
        "Mod+Ctrl+E".spawn-sh = noctalia "panel-toggle launcher /emo";
        "Mod+Ctrl+L".spawn-sh = noctalia "session lock";
        "Mod+Escape".spawn-sh = noctalia "panel-toggle session";
        "Mod+Shift+Space".spawn-sh = noctalia "bar-toggle";

        "Mod+Ctrl+A".spawn-sh = noctalia "panel-open control-center audio";
        "Mod+Ctrl+B".spawn-sh = noctalia "panel-open control-center bluetooth";
        "Mod+Ctrl+W".spawn-sh = noctalia "panel-open control-center network";
        "Mod+Ctrl+D".spawn-sh = noctalia "panel-open control-center monitor";

        "Mod+Ctrl+N".spawn-sh = noctalia "nightlight-toggle";
        "Mod+Ctrl+I".spawn-sh = noctalia "caffeine-toggle";
        "Mod+Ctrl+Space".spawn-sh = noctalia "wallpaper-next";

        "Mod+Comma".spawn-sh = noctalia "notification-clear-active";
        "Mod+Shift+Comma".spawn-sh = noctalia "notification-clear-history";
        "Mod+Alt+Comma".spawn-sh = noctalia "notification-invoke-latest";
        "Mod+Ctrl+Comma".spawn-sh = noctalia "notification-dnd-toggle";
      };

      appBinds = {
        "Mod+Shift+B".spawn-sh = lib.getExe inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
        "Mod+Shift+N".spawn-sh = lib.getExe pkgs.vscodium;
        "Mod+Shift+F".spawn-sh = lib.getExe pkgs.nautilus;
        "Mod+Ctrl+T".spawn-sh = inTerminal (lib.getExe pkgs.btop);
        "Mod+Shift+M".spawn-sh = inTerminal (lib.getExe pkgs.spotify-player);
        "Mod+Shift+Ctrl+A".spawn-sh = inTerminal (lib.getExe pkgs.claude-code);
        "XF86Calculator".spawn-sh = lib.getExe pkgs.gnome-calculator;
      };

      mediaActions = {
        "XF86AudioRaiseVolume".spawn-sh = noctalia "volume-up";
        "XF86AudioLowerVolume".spawn-sh = noctalia "volume-down";
        "XF86AudioMute".spawn-sh = noctalia "volume-mute";

        #MY keyboard does not actually have these, but keep.
        "XF86AudioMicMute".spawn-sh = noctalia "mic-mute";
        "XF86AudioPlay".spawn-sh = noctalia "media toggle";
        "XF86AudioNext".spawn-sh = noctalia "media next";
        "XF86AudioPrev".spawn-sh = noctalia "media previous";
        "XF86MonBrightnessUp".spawn-sh = noctalia "brightness-up";
        "XF86MonBrightnessDown".spawn-sh = noctalia "brightness-down";
      };

      lockedBinds = lib.mapAttrs
        (_: action: _: {
          props.allow-when-locked = true;
          content = action;
        })
        mediaActions;

      plainBinds = coreBinds // workspaceBinds // windowBinds // systemBinds // appBinds // mediaActions;

      # shortcut label overrides
      bindLabelOverrides = {
        "Mod+Return" = "open a terminal";
        "Mod+O" = "toggle obsidian";
        "Mod+Shift+O" = "toggle vesktop";
        "Mod+Space" = "open launcher";
        "Mod+Shift+B" = "browser";
        "Mod+Shift+N" = "editor";
        "Mod+Shift+F" = "file manager";
      };

      # Store paths swamp the cheat sheet; only the program name is useful.
      stripStorePaths = cmd:
        lib.concatStringsSep " " (
          map (tok: if lib.hasPrefix builtins.storeDir tok then baseNameOf tok else tok)
            (lib.splitString " " cmd)
        );

      formatBindValue = v:
        if v == [ ] then ""
        else if builtins.isString v then " (${v})"
        else if builtins.isInt v then " (${toString v})"
        else "";

      describeBind = key: actionAttrs:
        let
          actionName = builtins.head (builtins.attrNames actionAttrs);
          actionValue = actionAttrs.${actionName};
        in
        bindLabelOverrides.${key} or (
          if actionName == "spawn-sh"
          then stripStorePaths actionValue
          else "${lib.replaceStrings [ "-" ] [ " " ] actionName}${formatBindValue actionValue}"
        );

      hotkeyListText = lib.concatLines (
        lib.mapAttrsToList (key: actionAttrs: "${key}: ${describeBind key actionAttrs}")
          plainBinds
      );

      showHotkeys = pkgs.writeShellApplication {
        name = "niri-show-hotkeys";
        runtimeInputs = [ inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default ];
        text = ''
          cat <<'EOF' | noctalia dmenu --prompt "Keybindings" >/dev/null
          ${hotkeyListText}
          EOF
        '';
      };
    in
    {
      packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        settings = {
          # Pinned to 0.8.1: 0.8.2 breaks Steam's dropdown/context menus (see
          # the flake input comment for the underlying bug).
          xwayland-satellite.path = lib.getExe inputs.nixpkgs-xwayland-satellite-081.legacyPackages.${pkgs.stdenv.hostPlatform.system}.xwayland-satellite;

          screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

          # Ask CSD-capable apps (mostly GTK) to drop their own titlebar/chrome
          prefer-no-csd = true;

          input.keyboard.xkb.layout = "us";
          # Focus the window under the cursor on hover; max-scroll-amount=0%
          # stops it from auto-scrolling to bring off-screen columns into focus.
          input.focus-follows-mouse = _: { props = { max-scroll-amount = "0%"; }; };

          # trip into that corner; Alt+Tab covers it instead.
          gestures.hot-corners.off = _: { };

          cursor.xcursor-size = 20;
          cursor.xcursor-theme = "Bibata-Modern-Ice";

          layout.gaps = 4;
          layout.default-column-width.proportion = 1.0;

          # AOC 27B2 is physically on the right, Sceptre F24 on the left;
          outputs = {
            "DP-2".position = _: { props = { x = 1920; y = -80; }; };
            "HDMI-A-1".position = _: { props = { x = 0; y = 0; }; };
          };

          # Pin the apps workspace to the Sceptre (left monitor, HDMI-A-1).
          workspaces."${appsWorkspace}".open-on-output = "HDMI-A-1";

          window-rules = [
            {
              # No matches = applies to every window; enforces a small
              matches = [ ];
              geometry-corner-radius = 4;
              clip-to-geometry = true;
            }
            {
              matches = [ { app-id = "^md\\.Obsidian$"; } ];
              open-on-workspace = appsWorkspace;
            }
            {
              # Vesktop's .desktop entry lists StartupWMClass=Vesktop, but
              matches = [ { app-id = "^[Vv]esktop$"; } ];
              open-on-workspace = appsWorkspace;
            }
            {
              matches = [ { app-id = "^org\\.gnome\\.Calculator$"; } ];
              open-floating = true;
              default-column-width.fixed = 400;
              default-window-height.fixed = 600;
            }
            {
              # Zen's PiP player sets this exact title; floating keeps it off
              # the scrolling row, where default-column-width would stretch it
              # to the full screen.
              matches = [ { app-id = "^zen-beta$"; title = "^Picture-in-Picture$"; } ];
              open-floating = true;
            }
          ];

          binds = plainBinds // lockedBinds // {
            "Mod+K".spawn-sh = lib.getExe showHotkeys;
          };
        };
      };
    };
}