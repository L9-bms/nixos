# AGENTS.md

- Do NOT deploy automatically.
- Do not touch the secrets repository or input, just prompt the user to modify them when necessary.
- Do not commit your changes unless explicitly asked.
- Run `nix flake check` after modifying the configuration.
- Run `git add <untracked files>` whenever Nix complains about "path does not exist".
- Use idiomatic Nix, be inspired by nixpkgs.
- Don't grep from the entire /nix/store.
