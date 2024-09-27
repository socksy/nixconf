{
  nixConfig = {
    extra-substitutors = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8ZY7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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
  inputs.bens-ags = {
    url = "github:socksy/bens-ags";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-stable,
      hyprland,
      bens-ags,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "ben";
      overlay-unstable = final: prev: { unstable = nixpkgs-unstable.legacyPackages.${prev.system}; };
      overlay-stable = final: prev: { stable = nixpkgs-stable.legacyPackages.${prev.system}; };
      overlay-force-newer-blueman = final: prev: {
        blueman = nixpkgs-unstable.legacyPackages.${prev.system}.blueman;
      };
    in
    {
      nixosConfigurations.fenixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit system username inputs;
        };
        modules = [
          (
            { config, pkgs, ... }:
            {
              nixpkgs.overlays = [
                overlay-unstable
                overlay-stable
                overlay-force-newer-blueman
              ];
            }
          )
          inputs.xremap-flake.nixosModules.default
          inputs.nix-index-database.nixosModules.nix-index
          #inputs.nixos-hardware.nixosModules.framework-13-7040-amd
          { programs.nix-index-database.comma.enable = true; }
          ./configuration.nix
        ];
      };
    };
}
