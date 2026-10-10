{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    noctalia.url = "github:noctalia-dev/noctalia";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";

    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
    noctalia-greeter.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    dev-templates.url = "github:the-nix-way/dev-templates";
    dev-templates.inputs.nixpkgs.follows = "nixpkgs";

    todo-odin.url = "github:Jacob-Machado-413/todo-odin";
    todo-odin.inputs.nixpkgs.follows = "nixpkgs";

    # Not in nixpkgs
    # Pinned: HEAD bumps millennium-src without updating the bun deps FOD hash
    millennium.url = "github:SteamClientHomebrew/Millennium/41f7356df31043e8c1429382dda95445530da987?dir=packages/nix";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
