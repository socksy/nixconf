{ config, pkgs, ... }:

{
  # Use the gummiboot efi boot loader.
  # n.b. no GRUB settings like everyone tells you to do
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.blacklistedKernelModules = [ "psmouse" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # bigger font
  console.font = "latarcyrheb-sun32";

  # hardware.facetimehd.enable = true;

  #networking.enableB43Firmware = true;
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  #networking.wireless.interfaces = ["wlp58s0"];

  # arch wiki suggests enabling these for intel chipset
  # lol swapping the opt and command on mac keyboard, because we swap it back again in dkeys to make linux keyboards feel like mac ones
  boot.extraModprobeConfig = ''
    options hid_apple swap_opt_cmd=1
  '';
  boot.kernel.sysctl = { "kernel.sysrq" = 1; };
  boot.kernelParams = [ "i915.enable_fbc=1" "i915.enable_psr=2" ];

  # much better youtube performance, but broken rn
  environment.variables = { MESA_LOADER_DRIVER_OVERRIDE = "iris"; };
  #hardware.opengl.package = (pkgs.mesa.override {
  #  galliumDrivers = ["nouveau" "virgl" "swrast" "iris" ];
  #}).drivers;
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];

  # options snd_hda_intel index=0 model=intel-mac-auto id=PCH
  # options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
  # options hid_apple fnmode=2

  # # Reset XHCI USB devices on suspend/resume, fixes SD Card reader vanishing after suspend
  # #options xhci_hcd quirks=0x80
  # '';
}
