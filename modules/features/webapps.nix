{ ... }: {
  #ai worked on this part more than the others, inshallah it works
  flake.nixosModules.webapps = { pkgs, ... }:
    let
      launch = pkgs.writeShellApplication {
        name = "webapp-launch";
        runtimeInputs = [ pkgs.chromium ];
        text = ''
          if [ $# -lt 2 ]; then
            echo "usage: webapp-launch <id> <url>" >&2
            exit 1
          fi
          id="$1"
          url="$2"
          shift 2

          # Each app gets its own profile so it runs as an independent chromium
          # instance. On the shared default profile the launch is handed to the
          # already-running browser's singleton, which swallows it and opens
          # nothing. The cost is a separate cookie jar per app.
          exec chromium \
            --user-data-dir="''${XDG_DATA_HOME:-$HOME/.local/share}/webapps/$id" \
            --app="$url" \
            "$@"
        '';
      };

      install = pkgs.writeShellApplication {
        name = "webapp-install";
        text = ''
          if [ $# -lt 2 ]; then
            echo "usage: webapp-install <name> <url> [icon]" >&2
            exit 1
          fi
          name="$1"
          url="$2"
          icon="''${3:-applications-internet}"

          id=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' \
            | sed 's/[^a-z0-9]\+/-/g; s/^-//; s/-$//')

          # chromium ignores --class on wayland and derives the app-id from the
          # URL as chrome-<host>_<path>-Default, with anything outside
          # [A-Za-z0-9.-] replaced by "_". StartupWMClass has to match it for
          # the launcher to tie the window to this entry.
          rest="''${url#*://}"
          rest="''${rest%%\?*}"
          hostport="''${rest%%/*}"
          path="''${rest#"$hostport"}"
          host="''${hostport%%:*}"
          [ -n "$path" ] || path=/
          wmclass="chrome-$(printf '%s' "''${host}_''${path}" \
            | sed 's/[^A-Za-z0-9.-]/_/g')-Default"

          dir="''${XDG_DATA_HOME:-$HOME/.local/share}/applications"
          mkdir -p "$dir"
          printf '%s\n' \
            '[Desktop Entry]' \
            'Type=Application' \
            "Name=$name" \
            "Exec=webapp-launch $id $url" \
            "Icon=$icon" \
            "StartupWMClass=$wmclass" \
            'Categories=Network' \
            'Terminal=false' \
            >"$dir/$id.desktop"

          echo "wrote $dir/$id.desktop (app-id $wmclass)"
        '';
      };
    in
    {
      environment.systemPackages = [ launch install ];
    };
}
