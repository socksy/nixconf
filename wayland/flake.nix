{
  nixConfig = {
    extra-substitutors = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8ZY7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.swaymonad = {
    url = "github:nicolasavru/swaymonad";
    inputs.nixpkgs.follows = "nixpkgs"; # not mandatory but recommended
  };
  inputs.hyprland = {
    url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  inputs.xremap-flake.url = "github:xremap/nix-flake";
  #inputs.emacs.url = github:nix-community/emacs-overlay/2e23449;

  inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      swaymonad,
      hyprland,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      user = "ben";
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
    in
    {
      nixosConfigurations.benixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit system user inputs; };
        modules = [
          (
            { config, pkgs, ... }:
            {
              nixpkgs.overlays = [ overlay-unstable ];
            }
          )
          inputs.xremap-flake.nixosModules.default
          inputs.nix-index-database.nixosModules.nix-index
          { programs.nix-index-database.comma.enable = true; }
          ./configuration.nix
        ];
      };
    };
}
