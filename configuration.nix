  { config, lib, pkgs, ... }:

  {

    imports = [
      ./hardware-configuration.nix
    ];

    time.timeZone = "Europe/Berlin";

    i18n.defaultLocale = "en_US.UTF-8";

    console.keyMap = "de";

    services.xserver.xkb = {
      layout = "de";
    };

programs.zsh = {
  enable = true;

  shellAliases = {
    ll = "ls -lah";
  };

  oh-my-zsh = {
    enable = true;
    plugins = [ "git" ];
    theme = "robbyrussell";
  };
};

    users.users.t = {
      isNormalUser = true;
      shell = pkgs.zsh;


      extraGroups = [
        "wheel"
        "networkmanager"
        "libvirtd"
        "kvm"
      ];
    };

    networking.networkmanager.enable = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    security.polkit.enable = true;
    
    hardware.bluetooth.enable = true;


    systemd.user.services.polkit-gnome-agent = {
      description = "Polkit Authentication Agent";

      serviceConfig = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 2;
      };

      wantedBy = [ "default.target" ];
    };

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    nixpkgs.config.allowUnfree = true;

    system.stateVersion = "25.11";
    

    environment.systemPackages = with pkgs; [
      kitty
      adwaita-icon-theme
      quickshell
      hyprpaper
      hyprpicker
      thunar

      (stdenvNoCC.mkDerivation {
        pname = "qylock-themes";
        version = "1.0";

        src = ./HyprlandApps/qylock/themes;

        installPhase = ''
          mkdir -p $out/share/sddm/themes
          cp -r ./* $out/share/sddm/themes/
        '';
      })

      git
      curl
      wget
      fastfetch
      python3
      bluetuith
      brightnessctl
      net-tools
      exploitdb
      arp-scan
      nmap
      nodejs
      wl-clipboard
      sl

      qt6.qtmultimedia
      qt6.qtbase
      qt6.qt5compat
      swtpm

      virt-viewer
      libguestfs
      looking-glass-client

      chromium
      zapzap
      telegram-desktop
      spotify
      timeshift
    ];
    
    environment.variables = {
      QML2_IMPORT_PATH = "/run/current-system/sw/lib/qt-6/qml";
      QML_IMPORT_PATH = "/run/current-system/sw/lib/qt-6/qml";
    };

    services.displayManager.sddm = {
      enable = true;
      theme = "pixel-night-city";

      wayland = {
        enable = true;
        compositor = "kwin";
      };

      extraPackages = with pkgs; [
        qt6.qtmultimedia
        qt6.qt5compat
      ];

      settings = {
        Theme = {
          CursorTheme = "Adwaita";
          CursorSize = 24;
        };
      };
    };

    programs.vscode = {
  enable = true;

  extensions = with pkgs.vscode-extensions; [
    bbenoist.nix
    ms-python.python
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      publisher = "bbenoist";
      name = "QML";
      version = "1.0.0";       
      sha256 = "sha256-tphnVlD5LA6Au+WDrLZkAxnMJeTCd3UTyTN1Jelditk=";
    }
  ];
};

    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';


      
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

  programs.virt-manager.enable = true;

  }
