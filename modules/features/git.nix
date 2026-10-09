_: {
  flake.nixosModules.git = _: {
    programs.git = {
      enable = true;
      config = {
        user.name = "Jacob Machado";
        user.email = "jmachadoat4@gmail.com";
        init.defaultBranch = "main";
      };
    };
  };
}
