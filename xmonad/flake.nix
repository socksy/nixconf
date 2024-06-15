{
  nixConfig = {
    extra-substitutors =  [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8ZY7bkq5CX+/rkCWyvRCYg3Fs="];
  };
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;
  inputs.nixpkgs-unstable.url = github:NixOS/nixpkgs;
  #inputs.emacs.url = github:nix-community/emacs-overlay/2e23449;

  outputs = { self, nixpkgs, nixpkgs-unstable, ...}@inputs: 
                                               #emacs, ...}@inputs: 
  {
    nixosConfigurations.benixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [
#        ({ config, pkgs, ... }: 
#        let
#          overlay-unstable = final: prev: { unstable = nixpkgs-unstable.legacyPackages.x86_64-linux; };
#        in
#        { nixpkgs.overlays = [ overlay-unstable ]; 
#        environment.systemPackages = with pkgs; [ unstable.tdesktop ];
#      }
#      )
      ./configuration.nix ];
    };
  };
}
