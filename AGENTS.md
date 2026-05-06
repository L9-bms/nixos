# Instructions for Coding Agents

## Nix Flake Validation

After making any modifications to Nix flake files (flake.nix, modules, configurations, etc.), always validate the flake by running:

```bash
nix flake check
```

This ensures the flake evaluates correctly and catches any syntax or evaluation errors before changes are committed.

## Git Tracking for Nix

After creating new files that are part of the Nix flake (modules, configurations, etc.), always stage them with:

```bash
git add <file>
```

Nix can only see files that are tracked in git. Untracked files will not be included when the flake is evaluated, which can cause missing module errors during `nix flake check` or when building.
