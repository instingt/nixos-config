# NixOS Configuration

A modular NixOS configuration following KISS and DRY principles, supporting multiple hosts, users, and desktop environments.

## Structure

```
nixos-config/
├── lib/
│   └── users.nix              # User definitions (single source of truth)
├── modules/
│   └── nixos/
│       ├── users.nix          # Generates user accounts & home configs
│       ├── desktop.nix         # Enables graphics stack
│       └── server.nix         # Server optimizations
├── hosts/
│   ├── thinkpad/              # ThinkPad host configuration
│   └── common/                # Shared host configurations
├── home/
│   ├── profiles/              # Reusable Home Manager profiles
│   │   ├── base.nix           # Base config (all users)
│   │   ├── cli.nix            # CLI tools
│   │   └── desktop/
│   │       ├── base.nix       # Desktop base
│   │       └── hyprland.nix   # Hyprland desktop
│   └── features/              # Feature modules
└── flake.nix                  # Flake definition
```

## Adding a New User

Edit `lib/users.nix` and add a user entry:

```nix
newuser = {
  extraGroups = [ "wheel" ];
  shell = pkgs.bash;
  packages = [ "cli" ];
  desktop = "hyprland";
};
```

The `users.nix` module will automatically:
- Create the NixOS user account
- Configure Home Manager
- Apply selected packages and desktop environment

## Adding a New Host

1. Create `hosts/newhost/default.nix`:

```nix
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    # Note: modules/nixos/* are automatically imported via hosts/common/global/default.nix
    # - users.nix: Always imported (handles user accounts)
    # - desktop.nix: Automatically imported if any user has desktop != null
    # - server.nix: Automatically imported if all users have desktop == null
    ../common/global
  ];
  networking.hostName = "newhost";
}
```

2. Add to `flake.nix`:

```nix
newhost = lib.nixosSystem {
  system = "x86_64-linux";
  modules = [ ./hosts/newhost ];
  specialArgs = { inherit inputs outputs; };
};
```

## Adding a Desktop Environment

1. Create `home/profiles/desktop/newde.nix`
2. User selects it: `desktop = "newde"` in `lib/users.nix`

## Package Profiles

Package profiles are in `home/profiles/`. To add a new profile:

1. Create `home/profiles/newprofile.nix`
2. Users can select it: `packages = [ "cli" "newprofile" ]`

## Host-Specific User Configuration

Users can have different configs per host using `hostOverrides`:

```nix
vita = {
  packages = [ "cli" ];
  desktop = "hyprland";
  hostOverrides = {
    laptop = { packages = [ "cli" "dev" "media" ]; };
    server = { desktop = null; packages = [ "cli" ]; };
  };
};
```

## Building

```bash
# Build configuration
nixos-rebuild build --flake .#thinkpad

# Switch to new configuration
sudo nixos-rebuild switch --flake .#thinkpad

# Test configuration without switching
sudo nixos-rebuild test --flake .#thinkpad

# Dry-run to see what would change
sudo nixos-rebuild dry-run --flake .#thinkpad
```

## Common Tasks

### Update Flake Inputs

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs
```

### Rebuild Home Manager Only

```bash
home-manager switch --flake .#vita@thinkpad
```

### Check Configuration Syntax

```bash
# Validate NixOS configuration
nixos-rebuild build --flake .#thinkpad --dry-run

# Validate Home Manager configuration
home-manager switch --flake .#vita@thinkpad --dry-run
```

### Access Development Shell

```bash
# Enter development shell (if configured)
nix develop

# Or use direnv (if configured)
direnv allow
```

## Principles

This configuration follows:

- **KISS (Keep It Simple, Stupid)**: Simple, straightforward module structure
- **DRY (Don't Repeat Yourself)**: Centralized user definitions, reusable profiles
- **Modularity**: Clear separation between hosts, users, and features
- **Single Source of Truth**: User definitions in `lib/users.nix` only

## Troubleshooting

### Build Failures

1. **Check for syntax errors**:
   ```bash
   nix-instantiate --parse -E 'import ./flake.nix'
   ```

2. **Clear Nix store cache**:
   ```bash
   sudo nix-collect-garbage -d
   ```

3. **Update flake lock**:
   ```bash
   nix flake update
   ```

### Home Manager Issues

1. **Check Home Manager logs**:
   ```bash
   journalctl -u home-manager-vita.service
   ```

2. **Rebuild from scratch**:
   ```bash
   rm -rf ~/.config/home-manager
   home-manager switch --flake .#vita@thinkpad
   ```

### Module Not Found Errors

- Ensure `modules/nixos/users.nix` is imported in your host configuration
- Check that profile paths match the file structure in `home/profiles/`
- Verify user definitions in `lib/users.nix` reference valid profiles

### Profile Not Applied

- Check that the profile file exists in `home/profiles/`
- Verify the profile is listed in the user's `packages` array
- Ensure the profile is properly exported in `home/profiles/default.nix` (if using a default.nix)

## Structure Details

- **`lib/users.nix`**: Central user definitions with packages, desktop, and host overrides
- **`modules/nixos/users.nix`**: NixOS module that creates users and configures Home Manager
- **`modules/nixos/desktop.nix`**: Enables graphics stack (X11/Wayland, GPU drivers)
- **`modules/nixos/server.nix`**: Server-specific optimizations (no GUI, minimal packages)
- **`home/profiles/`**: Reusable Home Manager configurations
- **`home/features/`**: Feature modules (CLI tools, desktop apps, etc.)
