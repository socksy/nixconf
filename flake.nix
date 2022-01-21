{
  inputs.nixpkgs.url = github:NixOS/nixos-21.11;
  inputs.nixpkgs_unstable.url = github:NixOS/nixpkgs;

  outputs = { self, nixpkgs, nixpkgs_unstable, ...}@attrs: {
    nixosConfigurations.benixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./configuration.nix ];
    };
  };
}
