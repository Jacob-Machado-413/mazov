{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };

    # niri's own cursor.xcursor-theme/size (below) only covers native Wayland
    # clients. XWayland apps (Steam, Proton games) read XCURSOR_THEME/SIZE
    # from the environment instead, so without these they fall back to a
    # mismatched default theme/size (e.g. Steam's two-finger pinch cursor).
    environment.sessionVariables = {
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = "20";
    };
    environment.systemPackages = [ pkgs.adwaita-icon-theme ];
  };

  perSystem = { pkgs, lib, ... }:
    let
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

      # Hyprland "special workspace" equivalent, adapted for niri's scrolling
      # columns: Obsidian and Vesktop share one "apps" workspace (as separate
      # columns you can scroll between) instead of one workspace each, since
      # niri workspaces are per-monitor and juggling two of them was awkward.
      # Each app still gets its own hotkey: it focuses that app's window
      # directly (spawning it into the shared workspace if not running yet),
      # and toggles back to whatever you were on before if that app is
      # already focused.
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
        "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;
        "Mod+Q".close-window = [];

        # clipboard; Ctrl+C copies without saving to disk.
        "Print".screenshot = [];
        "Mod+O".spawn-sh = lib.getExe obsidianToggle;
        "Mod+Shift+O".spawn-sh = lib.getExe vesktopToggle;
        "Mod+Space".spawn-sh = "${lib.getExe inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default} msg panel-toggle launcher";
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

      # shortcut label overrides
      bindLabelOverrides = {
        "Mod+Return" = "open a terminal";
        "Mod+O" = "toggle obsidian";
        "Mod+Shift+O" = "toggle vesktop";
        "Mod+Space" = "open launcher";
      };

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
        bindLabelOverrides.${key} or
          "${lib.replaceStrings [ "-" ] [ " " ] actionName}${formatBindValue actionValue}";

      hotkeyListText = lib.concatLines (
        lib.mapAttrsToList (key: actionAttrs: "${key}: ${describeBind key actionAttrs}")
          (coreBinds // workspaceBinds)
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
          # so windows reclaim that space; closing stays on Mod+Q instead.
          prefer-no-csd = true;

          input.keyboard.xkb.layout = "us";
          # Focus the window under the cursor on hover; max-scroll-amount=0%
          # stops it from auto-scrolling to bring off-screen columns into focus.
          input.focus-follows-mouse = _: { props = { max-scroll-amount = "0%"; }; };

          cursor.xcursor-size = 20;
          cursor.xcursor-theme = "Adwaita";

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
              # corner radius regardless of what each app would draw itself.
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
          ];

          binds = coreBinds // workspaceBinds // {
            "Mod+K".spawn-sh = lib.getExe showHotkeys;
          };
        };
      };
    };
}