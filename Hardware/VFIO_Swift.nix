{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "vfio-pci.ids=10de:25ac,10de:2291"
    "kvmfr.static_size_mb=64"
  ];

  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
    "kvmfr"
  ];

  boot.extraModulePackages = [
    config.boot.kernelPackages.kvmfr
  ];

  services.udev.packages = lib.singleton (pkgs.writeTextFile {
    name = "kvmfr";

    text = ''
      SUBSYSTEM=="kvmfr", KERNEL=="kvmfr0", GROUP="kvm", MODE="0660", TAG+="uaccess", RUN+="${pkgs.coreutils}/bin/ln -sf /dev/kvmfr0 /dev/shm/looking-glass"
    '';

    destination = "/etc/udev/rules.d/70-kvmfr.rules";
  });
}