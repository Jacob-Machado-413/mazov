_: {
  flake.nixosModules.dev =
    { pkgs, ... }:
    let
      vscodeExtensions = with pkgs.vscode-extensions; [
        anthropic.claude-code
        danielgavin.ols
        jnoortheen.nix-ide
        mkhl.direnv
        ms-dotnettools.vscode-dotnet-runtime
        ms-dotnettools.csharp
        ms-dotnettools.csdevkit
      ];
    in
    {
      environment.systemPackages = with pkgs; [
        claude-code
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
	cloc
      ];

      # Stable path for VS Code's dotnetAcquisitionExtension.existingDotnetPath. C# and Dev Kit request the
      # .NET 10 ASP.NET Core runtime and Dev Kit an SDK, and that path must satisfy every request.
      environment.etc."dotnet-vscode".source = pkgs.dotnetCorePackages.sdk_10_0;

      # Symlinked into the regular extensions dir so Noctalia's theme extension stays writable alongside them.
      systemd.user.tmpfiles.rules = map (
        ext:
        "L+ %h/.vscode/extensions/${ext.vscodeExtUniqueId} - - - - ${ext}/share/vscode/extensions/${ext.vscodeExtUniqueId}"
      ) vscodeExtensions;
    };
}
