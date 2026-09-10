#!/usr/bin/env nu

# Prune old NixOS generations, then garbage-collect the store.
#
#   sudo ./clean-nixos.nu            # keep the 3 most recent generations
#   sudo ./clean-nixos.nu --keep 5

const system_profile = "/nix/var/nix/profiles/system"

def main [
  --keep (-k): int = 3   # how many system generations to keep
  --system-only          # leave the calling user's own profiles alone
] {
  if (^id -u | str trim | into int) != 0 {
    print --stderr "clean-nixos.nu must run as root - re-run it with sudo"
    exit 1
  }

  if $keep < 1 {
    print --stderr "--keep needs to be 1 or more"
    exit 1
  }

  print $"Keeping the ($keep) most recent generations.\n\nBefore:"
  ^nix-env --profile $system_profile --list-generations

  ^nix-env --profile $system_profile --delete-generations $"+($keep)"

  if not $system_only {
    prune-user-profiles $keep
  }

  # Plain nix-collect-garbage, never -d: -d deletes *every* old generation and
  # would undo the pruning above.
  print "\nCollecting garbage..."
  ^nix-collect-garbage

  # Deleted generations stay in the boot menu until the loader entries are
  # rewritten. "boot" only touches the bootloader, no services are restarted.
  print "\nRewriting boot entries..."
  ^/run/current-system/bin/switch-to-configuration boot

  print "\nAfter:"
  ^nix-env --profile $system_profile --list-generations
}

# The user's own profiles are separate GC roots, so stale generations there
# pin store paths that pruning the system profile just released.
def prune-user-profiles [keep: int] {
  let user = ($env.SUDO_USER? | default "")
  if ($user | is-empty) { return }

  let home = (^getent passwd $user | str trim | split row ":" | get 5)

  for profile in [
    $"($home)/.local/state/nix/profiles/profile"
    $"($home)/.local/state/nix/profiles/home-manager"
    $"/nix/var/nix/profiles/per-user/($user)/profile"
    $"/nix/var/nix/profiles/per-user/($user)/home-manager"
  ] {
    if ($profile | path exists) {
      print $"\nPruning ($profile)"
      ^sudo -u $user nix-env --profile $profile --delete-generations $"+($keep)"
    }
  }
}
