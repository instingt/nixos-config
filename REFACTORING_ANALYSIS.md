# NixOS Configuration Refactoring Analysis

## 🔴 Critical Issues

### 1. **Bug: Incorrect User Reference in colors.nix**
**Location:** `modules/home-manager/colors.nix:51`

**Issue:** References `gabriel` instead of `vita`:
```nix
nixosConfigs = lib.mapAttrs (_: v: v.config.home-manager.users.gabriel) outputs.nixosConfigurations;
```

**Fix:** Should be:
```nix
nixosConfigs = lib.mapAttrs (_: v: v.config.home-manager.users.vita) outputs.nixosConfigurations;
```

**Impact:** This will cause a runtime error when accessing colors from other hosts.

---

## 🟡 High Priority Refactoring

### 2. **Hardcoded Username Throughout Codebase**
**Locations:**
- `home/global/default.nix:18` - `username = "vita"`
- `hosts/common/users/vita/default.nix:3` - `users.users.vita`
- `hosts/thinkpad/default.nix:29,38` - SSH key paths hardcoded to `/home/vita/.ssh/`
- `home/features/cli/git.nix:6-7` - Git user info hardcoded

**Recommendation:** 
- Create a `lib.users` module that defines users centrally
- Use `config.home.username` consistently instead of hardcoding
- Consider making user configuration data-driven

**Example:**
```nix
# lib/users.nix
{
  vita = {
    name = "Vitaliy Kataev";
    email = "vita@kataev.pro";
    gpgKey = "6664158A96D5F5D9DB8CD5DDBB28505EC0F75404";
  };
}
```

### 3. **SSH Key Management Duplication**
**Location:** `hosts/thinkpad/default.nix:26-42`

**Issue:** SSH key configuration is duplicated and hardcoded. If you add more hosts or keys, this will grow.

**Recommendation:** Create a reusable module:
```nix
# hosts/common/modules/ssh-keys.nix
{ config, lib, ... }:
{
  options.sshKeys = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name = lib.mkOption { type = lib.types.str; };
        key = lib.mkOption { type = lib.types.str; };
        mode = lib.mkOption { type = lib.types.str; default = "0600"; };
      };
    });
  };
  
  config = lib.mkMerge (map (key: {
    sops.secrets."ssh/${key.name}" = {
      sopsFile = ../../common/secrets.yaml;
      key = "vita-${config.networking.hostName}-${key.name}";
      owner = config.home-manager.users.vita.home.username;
      group = "users";
      mode = key.mode;
      path = "${config.home-manager.users.vita.home.homeDirectory}/.ssh/${key.name}";
    };
  }) config.sshKeys);
}
```

### 4. **Package Duplication**
**Locations:**
- `ripgrep` and `fd` appear in both `home/features/cli/default.nix` and `home/features/neovim/default.nix`
- Similar tools duplicated across modules

**Recommendation:** 
- Create a shared package set: `home/packages/default.nix`
- Import common packages from a single source
- Use `lib.unique` to deduplicate if needed

### 5. **Inconsistent Module Import Patterns**
**Locations:**
- `home/thinkpad.nix` uses direct imports
- `hosts/thinkpad/default.nix` uses relative paths
- `home/features/cli/default.nix` uses relative imports
- `home/features/desktop/hyprland/default.nix` uses `../common`

**Recommendation:** Standardize import patterns:
- Use `./` for same-level modules
- Use `../` for parent-level modules
- Consider using `lib.recursiveUpdate` for feature composition

---

## 🟢 Medium Priority Improvements

### 6. **Optional Modules Organization**
**Location:** `hosts/common/optional/`

**Current:** All optional modules are imported directly in `hosts/thinkpad/default.nix`

**Recommendation:** Create a feature flag system:
```nix
# hosts/thinkpad/default.nix
{
  features = {
    docker.enable = true;
    pipewire.enable = true;
    regreet.enable = true;
    quietboot.enable = true;
  };
}
```

Then use conditional imports:
```nix
imports = 
  (lib.optional config.features.docker.enable ../common/optional/docker.nix)
  ++ (lib.optional config.features.pipewire.enable ../common/optional/pipewire.nix)
  # ...
```

### 7. **Type Safety in Modules**
**Locations:** Various module files

**Issue:** Some modules don't define proper option types, making errors harder to catch.

**Recommendation:** Add type definitions to all custom options:
```nix
# Example improvement for monitors.nix
options.monitors = mkOption {
  type = types.listOf (types.submodule { ... });
  default = [];
  description = "Monitor configuration list";
};
```

### 8. **Hardcoded Paths**
**Locations:**
- `home/features/neovim/default.nix:21` - `${config.xdg.configHome}/nvim`
- `hosts/thinkpad/default.nix:32,41` - `/home/vita/.ssh/`

**Recommendation:** Use `config.home.homeDirectory` and `config.xdg.*` consistently instead of hardcoding paths.

### 9. **Magic Strings and Numbers**
**Locations:**
- `home/features/cli/git.nix:10` - GPG key ID as magic string
- `home/features/desktop/hyprland/default.nix:25` - Monitor scale `1.5` hardcoded
- `hosts/common/global/nix.nix:17` - GC retention `7d` hardcoded

**Recommendation:** Extract to configuration options or constants:
```nix
# config.nix or constants.nix
{
  gpgKeyId = "6664158A96D5F5D9DB8CD5DDBB28505EC0F75404";
  monitorScale = 1.5;
  nixGcRetention = "7d";
}
```

### 10. **Inconsistent Naming Conventions**
**Observations:**
- Some files use `default.nix`, others use specific names
- Module names don't always match their purpose clearly

**Recommendation:** 
- Use descriptive names: `ssh-keys.nix` instead of generic `default.nix` where appropriate
- Keep `default.nix` only for aggregating imports

---

## 🔵 Low Priority / Nice-to-Have

### 11. **Documentation**
**Issue:** Missing module-level documentation

**Recommendation:** Add `description` fields to all options and modules:
```nix
{
  meta.description = "Configure SSH keys via SOPS";
  options.sshKeys = mkOption {
    description = "List of SSH keys to deploy";
    # ...
  };
}
```

### 12. **Error Messages**
**Location:** `modules/home-manager/monitors.nix:59`

**Current:** Good assertion, but could be more helpful:
```nix
message = "Exactly one monitor must be set to primary.";
```

**Recommendation:** Include context:
```nix
message = "Exactly one monitor must be set to primary. Found ${toString (lib.length (lib.filter (m: m.primary) config.monitors))} primary monitors.";
```

### 13. **Module Reusability**
**Issue:** Some modules are tightly coupled to specific hosts/users

**Recommendation:** 
- Extract host-specific configs to `hosts/thinkpad/` directory
- Make common modules more generic
- Use `lib.mkIf` for conditional configuration

### 14. **State Version Management**
**Locations:** 
- `hosts/thinkpad/default.nix:23` - `system.stateVersion = "25.11"`
- `home/global/default.nix:20` - `stateVersion = "25.11"`

**Recommendation:** Define once in flake.nix and reference:
```nix
# flake.nix
stateVersion = "25.11";

# Then in modules:
system.stateVersion = inputs.self.stateVersion;
```

### 15. **Package Version Pinning**
**Issue:** No explicit version pinning for some packages

**Recommendation:** Consider using `nixpkgs-stable` input for critical packages where stability matters.

---

## 📊 Summary Statistics

- **Total Files Analyzed:** ~25+ configuration files
- **Critical Bugs:** 1 (gabriel reference)
- **High Priority Issues:** 5
- **Medium Priority:** 5
- **Low Priority:** 5

## 🎯 Recommended Refactoring Order

1. **Fix critical bug** (gabriel → vita)
2. **Extract user configuration** to central module
3. **Create SSH keys module** to reduce duplication
4. **Deduplicate packages** across modules
5. **Standardize import patterns**
6. **Add feature flags** for optional modules
7. **Improve type safety** and documentation

---

## 💡 Additional Suggestions

### Consider Using:
- **lib.mkMerge** for combining configurations
- **lib.recursiveUpdate** for deep merging
- **lib.optionals** for conditional lists
- **lib.mkIf** for conditional configuration blocks
- **lib.types.submodule** for complex nested options

### Testing Strategy:
- Use `nixos-rebuild build-vm` to test changes
- Consider adding `nix flake check` with custom checks
- Use `nix-instantiate --eval` to validate syntax

---

*Generated: $(date)*
*Analyzed: NixOS Configuration Flake*
