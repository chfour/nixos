{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  systemd.services."unfuck-touchpad" = rec {
    after = [ "post-resume.target" ];
    wantedBy = after;
    script = "${pkgs.kmod}/bin/modprobe -r psmouse && ${pkgs.kmod}/bin/modprobe psmouse";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false; # do not turn on bluetooth at boot
  };

  boot.extraModprobeConfig = ''
    # https://wiki.archlinux.org/title/Power_management#Audio
    options snd-hda-intel power_save=1
    # https://wiki.archlinux.org/title/Power_management#Intel_wireless_cards_(iwlwifi)
    options iwlwifi power_save=1 uapsd_disable=0
  '';

  services.udev.extraRules = ''
    # powertop wants this among many others
    ACTION=="add",SUBSYSTEM=="pci",KERNEL=="0000:04:00.0",ATTR{power/control}="auto"
  '';

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/46f61b03-25b1-4ca0-9c88-43afa655b053";
    fsType = "ext4";
    options = [ "defaults" "relatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4C67-853B";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/ecaee476-5e34-45a7-9c35-a219272e53e0";
    fsType = "ext4";
    options = [ "defaults" "relatime" ];
  };

  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=777" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/3279a9f7-efc9-4af3-8c94-92c53cb9bf1f"; }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
}
