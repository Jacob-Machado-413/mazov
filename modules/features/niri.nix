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
      # columns: Obsidian and Discord share one "apps" workspace (as separate
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

      discordToggle = mkAppWorkspaceToggle {
        appId = "discord";
        spawnCmd = lib.getExe pkgs.discord;
        extraInputs = [ pkgs.discord ];
      };
    in
    {
      packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        settings = {
          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          input.keyboard.xkb.layout = "us";
          # Focus the window under the cursor on hover instead of requiring
          # a click; max-scroll-amount=0% keeps it from auto-scrolling the
          # view to bring partially off-screen columns into focus.
          input.focus-follows-mouse = _: { props = { max-scroll-amount = "0%"; }; };

          cursor.xcursor-size = 20;
          cursor.xcursor-theme = "Adwaita";

          layout.gaps = 4;
          layout.default-column-width.proportion = 1.0;

          # AOC 27B2 is physically on the right, Sceptre F24 on the left;
          # niri's connector-discovery order had them backwards.
          # AOC's stand also sits ~1in (~80px at its 0.315mm/px pitch) taller
          # than the Sceptre's, so it needs a negative y to line up the seam.
          outputs = {
            "DP-2".position = _: { props = { x = 1920; y = -80; }; };
            "HDMI-A-1".position = _: { props = { x = 0; y = 0; }; };
          };

          # Pin the apps workspace to the Sceptre (left monitor, HDMI-A-1).
          workspaces."${appsWorkspace}".open-on-output = "HDMI-A-1";

          window-rules = [
            {
              matches = [ { app-id = "^md\\.Obsidian$"; } ];
              open-on-workspace = appsWorkspace;
            }
            {
              matches = [ { app-id = "^discord$"; } ];
              open-on-workspace = appsWorkspace;
            }
          ];

          binds = {
            "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;
            "Mod+Q".close-window = [];
            "Mod+O".spawn-sh = lib.getExe obsidianToggle;
            "Mod+Shift+O".spawn-sh = lib.getExe discordToggle;
            "Mod+Space".spawn-sh = "${lib.getExe inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default} msg panel-toggle launcher";

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
          } // workspaceBinds;
        };
      };
    };
}