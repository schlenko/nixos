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
     syntaxHighlighting.enable = true;
     autosuggestions.enable = true; 



    shellAliases = {
      ll = "ls -lah";
      pkmn="python3 /etc/nixos/Apps/pokemonscript/pokemon-colorscripts.py --random";
      pwr="cat /sys/class/power_supply/BAT1/capacity";
     }; 

     interactiveShellInit = ''
      python3 /etc/nixos/Apps/pokemonscript/pokemon-colorscripts.py --random
     '';

    ohMyZsh = {
     enable = true;
      plugins = [ "git" ];
      theme = "crcandy";
   };
  };  
  swapDevices = [
  {
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }
];
  

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
        adwaita-icon-theme
      quickshell
      hyprpaper
      hyprpicker
      thunar
      kitty

      (stdenvNoCC.mkDerivation {
        pname = "qylock-themes";
        version = "1.0";

        src = ./Apps/qylock/theme;

        installPhase = ''
          mkdir -p $out/share/sddm/themes/current
          cp -r ./* $out/share/sddm/themes/current/
        '';
      })

      git
      gh
      curl
      wget
      fastfetch
      zip
      unzip
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
      btop
      cmake
      bettercap

      qt6.qtmultimedia
      qt6.qtbase
      qt6.qt5compat
      swtpm

      virt-viewer
      libguestfs

      chromium
      zapzap
      telegram-desktop
      spotify
      timeshift
      discord

    ];

    
    environment.variables = {
      QML2_IMPORT_PATH = "/run/current-system/sw/lib/qt-6/qml";
      QML_IMPORT_PATH = "/run/current-system/sw/lib/qt-6/qml";
    };

    services.displayManager.sddm = {
      enable = true;
      theme = "current";

      wayland = {
        enable = true;
        compositor = "kwin";
      };

      extraPackages = with pkgs.kdePackages; [
        qtmultimedia
        qt5compat
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

    systemd.services.wpa_supplicant.environment.OPENSSL_CONF =
    "/etc/NetworkManager/certs/wpa_openssl.cnf";

      environment.etc."NetworkManager/certs/wpa_openssl.cnf".text = ''
    openssl_conf = default_conf

    [default_conf]
    ssl_conf = ssl_sect

    [ssl_sect]
    system_default = system_default_sect

    [system_default_sect]
    MinProtocol = TLSv1
    CipherString = DEFAULT@SECLEVEL=0
  '';

  networking.networkmanager.ensureProfiles.profiles."AP-SuS" = {
  connection = {
    id = "AP-SuS";
    type = "wifi";
  };

  wifi = {
    ssid = "AP-SuS";
  };

  wifi-security = {
    key-mgmt = "wpa-eap";
  };

  zramSwap = {
  enable = true;
  memoryPercent = 50; 
};  

  "802-1x" = {
    eap = "peap";
    identity = "NikolenkoL672";
    phase2-auth = "mschapv2";
    ca-cert = "/etc/NetworkManager/certs/musterschule-DC01-CA.pem";
  };
};

  }
