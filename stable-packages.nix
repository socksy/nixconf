{ config, pkgs, ... }:
let stable = import <stable> { };
in {
  environment.systemPackages = [
    #put stable packages here
    # stable.haskellPackages.xmonad 
    # stable.haskellPackages.yeganesh 
  ];
}

