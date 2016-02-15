{ config, pkgs, ... }:


{
    # Use the gummiboot efi boot loader.
    # n.b. no GRUB settings like everyone tells you to do
    boot.loader.gummiboot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.enableB43Firmware = true;
    networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    #to get the sound card to work
    boot.extraModprobeConfig = ''
    options snd_hda_intel index=0 model=intel-mac-auto id=PCH
    options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
    options hid_apple fnmode=2
    '';

    # this is seemingly a requirement for wifi to work
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # wifi driver (make sure nixpkgs.config.allowUnfree)
    boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
}