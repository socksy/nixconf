{ config, pkgs, ... }:


{
    # Use the gummiboot efi boot loader.
    # n.b. no GRUB settings like everyone tells you to do
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

   # hardware.facetimehd.enable = true;

    #networking.enableB43Firmware = true;
    networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # arch wiki suggests enabling these 
    boot.extraModprobeConfig = ''
    options i915 modeset=1 enable_rc6=1 enable_fbc=1
    '';
   # options snd_hda_intel index=0 model=intel-mac-auto id=PCH
   # options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
   # options hid_apple fnmode=2

   # # Reset XHCI USB devices on suspend/resume, fixes SD Card reader vanishing after suspend
   # #options xhci_hcd quirks=0x80
   # '';
}
