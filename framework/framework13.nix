{ config, pkgs, lib, ... }:

{ # Use the gummiboot efi boot loader.
  # n.b. no GRUB settings like everyone tells you to do
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.grub.device = "nodev";
  #boot.loader.grub.efiSupport = true;
  #boot.blacklistedKernelModules = [ "psmouse" ];
  boot.initrd.luks.devices."luks-d1e77924-0945-457d-b924-fe614e87069a".device = "/dev/disk/by-uuid/d1e77924-0945-457d-b924-fe614e87069a";
  networking.hostName = "fenixos";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # bigger font
  console.font = "latarcyrheb-sun32";


  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/5cfb3057-bf4b-46ca-898d-6c983efb4bfa";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-09c590c1-f506-403f-a4a0-06f74159b421".device = "/dev/disk/by-uuid/09c590c1-f506-403f-a4a0-06f74159b421";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/828A-B27E";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/c2531040-4949-4002-ab68-2a2186a36d4f"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}