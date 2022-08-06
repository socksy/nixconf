{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
  inputs.nixpkgs-unstable.url = github:NixOS/nixpkgs;
  inputs.emacs.url = github:nix-community/emacs-overlay;

  outputs = { self, nixpkgs, nixpkgs-unstable, emacs, ...}@inputs: 
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
