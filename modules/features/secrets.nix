{ inputs, config, ... }:
let
  # The NixOS module below has its own `config`, which shadows this one.
  inherit (config.mark1) user;
in
{
  # Values live encrypted in /secrets.yaml; edit with `sops secrets.yaml`.
  flake.nixosModules.secrets =
    { pkgs, ... }:
    let
      sshKey = "/home/${user}/.ssh/id_ed25519";
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ../../secrets.yaml;
        # No openssh host keys on this machine, so decrypt with the user's key.
        age.sshKeyPaths = [ sshKey ];
      };

      environment.systemPackages = [
        pkgs.sops
        pkgs.ssh-to-age
      ];

      # sops' native SSH support only matches ssh-ed25519 recipients, not the
      # ssh-to-age-derived age1 recipient in .sops.yaml.
      environment.sessionVariables.SOPS_AGE_KEY_CMD = "ssh-to-age -private-key -i ${sshKey}";
    };
}
