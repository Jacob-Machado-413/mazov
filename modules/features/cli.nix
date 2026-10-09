{ ... }: {
  flake.nixosModules.cli = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      btop
      fzf
      ripgrep
      fd
      tldr
      yazi
      zellij
      fastfetch
      unimatrix
      nix-search-tv
      openssh
      ffmpeg
      imagemagick
      tesseract
      yt-dlp
    ];
  };
}
