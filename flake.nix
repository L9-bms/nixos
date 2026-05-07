{
  description = "dendritic homelab configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    secrets = {
      url = "git+ssh://git@github.com/L9-bms/nixos-secrets.git?shallow=1";
      flake = false;
    };

    deploy-rs.url = "github:serokell/deploy-rs";
    sops-nix.url = "github:Mic92/sops-nix";
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    prism-tower.url = "github:L9-bms/prism-tower";
    picolimbo.url = "github:wongcallum/PicoLimbo/nix";

    home-manager.url = "github:nix-community/home-manager";
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia-qs.url = "github:noctalia-dev/noctalia-qs";
    yazi.url = "github:sxyazi/yazi";

    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";
    prism-tower.inputs.nixpkgs.follows = "nixpkgs";
    picolimbo.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
    noctalia.inputs.nixpkgs.follows = "nixpkgs-unstable";
    noctalia.inputs.noctalia-qs.follows = "noctalia-qs";
    noctalia-qs.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        (inputs.import-tree [
          ./modules
          ./hosts
        ])
      ];
    };
}
