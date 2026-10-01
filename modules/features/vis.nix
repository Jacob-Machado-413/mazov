{ self, ... }: {
  perSystem = { pkgs, lib, ... }: let
    # vis-lspc's tagged releases target the pre-0.9 API; main targets vis >= 0.9.
    visLspc = pkgs.fetchFromGitLab {
      owner = "muhq";
      repo = "vis-lspc";
      rev = "9d0f7a0b82b1983b44636259733d6d2c39497315";
      hash = "sha256-lA9ZzYeq7td5x5mBE8hCc7xzbRNMl8slm0H4o1P9dlc=";
    };

    # Newer than the scintillua vis 0.9 bundles, which has no nix or odin lexer.
    scintillua = pkgs.fetchFromGitHub {
      owner = "orbitalquark";
      repo = "scintillua";
      rev = "cc02363cedcb2b66628d15e79224906ea56f7653";
      hash = "sha256-Zb+Is2gar4czm6bE+NCfdOrHn7Kv4TWtzgUH9GLKK7Y=";
    };

    visPath = pkgs.runCommand "vis-path" { } ''
      cp -r ${./vis} $out
      chmod -R u+w $out
      mkdir -p $out/plugins $out/lexers
      ln -s ${visLspc} $out/plugins/vis-lspc
      ln -s ${scintillua}/lexers/nix.lua $out/lexers/nix.lua
      ln -s ${scintillua}/lexers/odin.lua $out/lexers/odin.lua
    '';

    languageServers = with pkgs; [
      nixd
      rust-analyzer
      csharp-ls
      sqls
      ols
      basedpyright
    ];
  in {
    packages.myVis = pkgs.symlinkJoin {
      name = "vis";
      paths = [ pkgs.vis ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/vis --suffix PATH : ${lib.makeBinPath languageServers}
      '';
      meta.mainProgram = "vis";
    };

    packages.visConfig = visPath;
  };

 
  flake.nixosModules.vis = { pkgs, ... }: let
    packages = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    environment.systemPackages = [ packages.myVis ];
    environment.etc."vis".source = packages.visConfig;
  };
}
