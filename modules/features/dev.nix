_: {
  flake.nixosModules.dev = { pkgs, lib, ... }:
    let
      vscodeExtensions = with pkgs.vscode-extensions; [
        anthropic.claude-code
        danielgavin.ols
        jnoortheen.nix-ide
        mkhl.direnv
      ];
    in
    {
      environment.systemPackages = with pkgs; [
        claude-code
        vscodium
        vscode
        jujutsu
        lazygit
        gh
        gdb
        tokei
        statix
        deadnix
        odin
        ols
        python3
        godot
      ];

      # Symlinked into the regular extensions dir so Noctalia's theme extension stays writable alongside them.
      systemd.user.tmpfiles.rules = map (ext:
        "L+ %h/.vscode/extensions/${ext.vscodeExtUniqueId} - - - - ${ext}/share/vscode/extensions/${ext.vscodeExtUniqueId}"
      ) vscodeExtensions;
    };
}
