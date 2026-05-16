---
name: dendritic-aspects
description: Design patterns for organizing Nix flake features using the Dendritic Pattern with flake-parts. Covers simple, multi-context, inheritance, conditional, collector, constants, DRY, and factory aspects. Use when structuring flake modules, creating new features, or refactoring a NixOS/darwin/home-manager flake codebase.
---

# Dendritic Aspects

This skill defines design patterns for building features (flakes modules) using the **Dendritic Pattern** + **flake-parts**. A feature is a self-contained capability expressed as one or more `aspects` (modules) within a `class` (e.g. `nixos`, `darwin`, `homeManager`, `generic`).

## Glossary

| Term | Meaning |
|------|---------|
| **aspect** | A module inside a feature — what it *does* |
| **class** | The configuration context — `nixos`, `darwin`, `homeManager`, `generic`, or custom DRY classes |
| **feature** | A named concern; the filename/attribute that groups related aspects |

---

## Pattern: Simple Aspect

**When to use:** A feature used in one or multiple configuration contexts, optional, with no dependencies on other features.

**Structure:** Create one module per target class:

```nix
{
  flake.modules.nixos.basicPackages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ /* ... */ ];
  };

  flake.modules.darwin.basicPackages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ /* ... */ ];
  };

  flake.modules.homeManager.basicPackages = { pkgs, ... }: {
    programs = { /* ... */ };
  };
}
```

**Tip:** Multiple class modules can live in one file if they share partial config; split into per-class files for easier maintenance.

---

## Pattern: Multi Context Aspect

**When to use:** A feature lives in one main context (e.g. `nixos`) but *must* inject configuration into a nested context (e.g. `homeManager`).

**Structure:** Main class module + private auxiliary module. Import the auxiliary module via `home-manager.sharedModules` or `home-manager.users.<user>.imports` inside the main module.

```nix
{ inputs, ... }:
{
  flake.modules.nixos.gnome = {
    home-manager.sharedModules = [
      inputs.self.modules.homeManager.gnome
    ];
    # system-level gnome config
  };

  flake.modules.homeManager.gnome = {
    # home-manager-level gnome config
  };
}
```

**Note:** The auxiliary module can be kept private (internal) or later promoted to public use.

**Warning:** When combining with Inheritance Aspect, avoid adding the same home-manager module multiple times to `sharedModules`.

---

## Pattern: Inheritance Aspect

**When to use:** You want to modify or extend an existing feature.

**Structure:** Create new aspect modules for each class, import the parent aspect, then add/override:

```nix
{ inputs, ... }:
{
  flake.modules.nixos.system-desktop = {
    imports = with inputs.self.modules.nixos; [
      system-cli   # parent
      mail
      browser
      kde
      printing
    ];
  };

  flake.modules.darwin.system-desktop = {
    imports = with inputs.self.modules.darwin; [
      system-cli
      mail
      browser
    ];
  };
}
```

---

## Pattern: Conditional Aspect

**When to use:** Parts of a feature should only apply under certain conditions.

**Structure:** Use `lib.mkMerge` with `lib.mkIf`. **Never use `//`**.

```nix
flake.modules.homeManager.office = { pkgs, lib, ... }:
  lib.mkMerge [
    {
      home.packages = with pkgs; [ notesnook ];
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      home.packages = with pkgs; [ libreoffice-qt6 ];
    })
    (lib.mkIf pkgs.stdenv.isDarwin {
      home.packages = with pkgs; [ libreoffice-bin ];
    })
  ];
```

---

## Pattern: Collector Aspect

**When to use:** A feature's configuration is built up from contributions scattered across other features.

**Structure:** Define the base collector module in one feature. In other features, define additional configuration under the *same aspect name* — the module system merges them automatically.

```nix
# Feature: syncthing (base)
{
  flake.modules.nixos.syncthing = {
    services.syncthing.enable = true;
  };
}

# Feature: homeserver (contributes to collector)
{
  flake.modules.nixos.syncthing = {
    services.syncthing.settings.devices.homeserver = {
      id = "VNV2XTI-...";
    };
  };
}
```

**Tip:** Put collector contributions in a separate file named after the collector aspect within each contributing feature.

---

## Pattern: Constants Aspect

**When to use:** Share values or functions across features regardless of configuration context.

**Structure:** Define options using the `generic` class, import once at a high level (e.g. `system-default`).

```nix
{
  flake.modules.generic.systemConstants = { lib, ... }: {
    options.systemConstants = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
    };
    config.systemConstants = {
      adminEmail = "admin@test.org";
    };
  };
}

# Import in each class's default
{
  flake.modules.nixos.system-default = {
    imports = [ inputs.self.modules.generic.systemConstants ];
  };
}
```

**Access:** Use as a normal option inside any module: `config.systemConstants.adminEmail`.

**Alternative:** If values are only needed within one file, use `let ... in` or define attributes directly on the flake class (`options.<name>` + `inputs.self.<name>`).

---

## Pattern: DRY Aspect

**When to use:** Reuse a value/structure for multiple attribute assignments where a Simple Aspect won't work (e.g. `networking.interfaces.<name>.ipv4.routes`).

**Structure:** Create a custom DRY class (e.g. `networkInterface`) and use `lib.mkMerge`.

```nix
flake.modules.networkInterface.subnet-A = {
  ipv6.routes = [ { address = "..."; prefixLength = 64; via = "..."; } ];
  ipv4.routes = [ { address = "..."; prefixLength = 24; via = "..."; } ];
};

networking.interfaces."enp86s0" = with self.modules.networkInterface;
  lib.mkMerge [
    subnet-A
    subnet-B
    { ipv4.addresses = [ { address = "10.0.0.1"; prefixLength = 16; } ]; }
  ];
```

**Warning:** Always use `lib.mkMerge`, never `//`.

---

## Pattern: Factory Aspect

**When to use:** Generate parameterized features/modules from a template.

**Variant A — Named aspects for multiple classes:**

```nix
{
  config.flake.factory.user = username: isAdmin: {
    darwin."${username}" = { /* ... */ };
    nixos."${username}" = { /* ... */ };
  };
}

# Usage
flake.modules = lib.mkMerge [
  (self.factory.user "bob" true)
  { nixos.bob = { /* extra */ }; }
];
```

**Variant B — Anonymous module for one class:**

```nix
{
  config.flake.factory.mount-cifs-nixos = { host, resource, destination, ... }: {
    fileSystems."${destination}" = { /* ... */ };
  };
}

# Usage in imports
imports = [
  (inputs.self.factory.mount-cifs-nixos {
    host = "home-server.lan";
    resource = "home";
    destination = "/home/users/bob/homeserver";
  })
];
```

**Tips:**
- Use attribute-set parameters for readability when there are many arguments.
- Always use `lib.mkMerge` when combining factory output with customizations.

---

## Workflow: Adding a New Feature

1. **Define requirements** — Which contexts? Any dependencies? Any conditions? Any contributions to a collector?
2. **Map to patterns** — Select the aspect patterns that match.
3. **Implement** — Create the feature module(s) following the pattern steps.

A single feature often combines multiple patterns (e.g. Simple + Multi Context + Inheritance).

---

## Assembling a Host

Hosts are just features. Compose by importing other features:

```nix
flake.modules.nixos."linux-desktop" = {
  imports = with inputs.self.modules.nixos; [
    system-cli
    syncthing
    bob      # multi-context: includes home-manager user config
    alice
  ];
};
```

Then wire to flake outputs:

```nix
flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "linux-desktop";
```

---

## Key Warnings

| Issue | Rule |
|-------|------|
| Merging options | **Always `lib.mkMerge`**, never `//` |
| Option priority | Use `lib.mkDefault` / `lib.mkForce` when needed |
| Multi-context + inheritance | Avoid double-importing home-manager modules into `sharedModules` |
