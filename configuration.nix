# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./packages.nix
      ./macbookpro.nix
      ./xstuff.nix
    ];

  hardware.bluetooth.enable = true;

  networking.hostName = "benixos"; # Define your hostname.
  networking.enableB43Firmware = true;
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.


  fileSystems."/".options = "defaults,noatime";
  fileSystems."/home".options = "defaults,noatime";

  time.timeZone = "Europe/Berlin";


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # run updatedb every night so locate works  
  services.locate.enable = true;

  # puts browser profiles into RAM, preventing a lot of read/write to USB
  services.psd.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.ben = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/ben";
    shell = "${pkgs.zsh}/bin/zsh";
    description = "Ben Lovell";
    extraGroups = ["wheel" "video" "audio" "vboxusers"];
  };

  #virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.host.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";
}
