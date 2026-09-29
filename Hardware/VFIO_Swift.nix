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

  users.users.t.extraGroups = [
    "libvirtd"
    "kvm"
  ];

  environment.systemPackages = with pkgs; [
    swtpm
    virt-viewer
    libguestfs
  ];

  programs.virt-manager.enable = true;

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;

      verbatimConfig = ''
        namespaces = []
        cgroup_device_acl = [
          "/dev/null",
          "/dev/full",
          "/dev/zero",
          "/dev/random",
          "/dev/urandom",
          "/dev/ptmx",
          "/dev/kvm",
          "/dev/rtc",
          "/dev/hpet",
          "/dev/vfio/vfio",
          "/dev/kvmfr0"
        ]
      '';
    };

    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  systemd.services.libvirt-default-network = {
    description = "Start libvirt default network";
    after = [ "libvirtd.service" ];
    wants = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.libvirt}/bin/virsh net-start default";
      ExecStop = "${pkgs.libvirt}/bin/virsh net-destroy default";
      RemainAfterExit = true;
    };
  };
}