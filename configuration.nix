{ config, lib, pkgs, ... }:

{
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
  keyMap = "de";
  font = "Lat2-Terminus16";
  };

  services.xserver.xkb = {
    layout = "de";
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;

    shellAliases = {
      ll = "ls -lah";
      pkmn = "python3 /etc/nixos/Apps/pokemonscript/pokemon-colorscripts.py --random";
      pwr = "cat /sys/class/power_supply/BAT1/capacity";
      wintonix = "sudo scp -r twin@192.168.122.4:/C:/Users/shared ~/";
      nixtowin = "sudo scp -r ~/shared twin@192.168.122.4:/C:/Users/";
      pipes = "pipes.sh -f 100 -r 0 -B -c 1 -c 2 -c 3 -c 4 -c 5 -c 6 -c 7";
      wp = "awtwall";
    };

    interactiveShellInit = ''
      if [ -f /etc/nixos/Apps/pokemonscript/pokemon-colorscripts.py ]; then
        python3 /etc/nixos/Apps/pokemonscript/pokemon-colorscripts.py --random
      fi
    '';

    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  users.users.t = {
    isNormalUser = true;
    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  boot.loader.systemd-boot.enable = true;   
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  security.polkit.enable = true;

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

    hyprpaper
    hyprlock
    hyprpicker
    thunar
      tumbler
      ffmpegthumbnailer
    kitty
    rofi
    waybar
    mission-center 

    git
    gh
    curl
    wget
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
    bluetui
    cmake
    bettercap
    bc
    playerctl
    lazygit

    sl
    asciiquarium
    pipes
    cowsay
    fortune
    cmatrix
    nyancat
    genact
    fastfetch

    chromium
    zapzap
    telegram-desktop
    spotify
    discord
  ];

    programs.hyprlock.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs.uwsm}/bin/uwsm start -e -D Hyprland hyprland.desktop";
        user = "t";
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

  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

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

    "802-1x" = {
      eap = "peap";
      identity = "NikolenkoL672";
      phase2-auth = "mschapv2";
      ca-cert = "/etc/NetworkManager/certs/musterschule-DC01-CA.pem";
    };
  };
}
