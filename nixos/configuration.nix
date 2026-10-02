# ==============================================================================
# NixOS System Configuration
# Lenovo ThinkPad P14s Gen 5 AMD (Ryzen 7 PRO / Radeon 780M)
# ==============================================================================

{ config, pkgs, ... }:

{
  # ============================================================================
  # 1. IMPORTS & HARDWARE SCAN
  # ============================================================================
  imports = [
    ./hardware-configuration.nix
    # <nixos-hardware/lenovo/thinkpad/p14s/amd/gen5>
  ];

  # ============================================================================
  # 2. BOOTLOADER & KERNEL
  # ============================================================================
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi.canTouchEfiVariables = true;
  };

  boot.kernelModules = [ "kvm-amd" "tcp_bbr" ];
  boot.kernelParams = [
    "amd_pstate=active"
    "acpi.ec_no_wakeup=1"
  ];
  boot.blacklistedKernelModules = [ "sp5100_tco" ];

  # Network Kernel Optimizations (BBR + Low Latency TCP)
  boot.kernel.sysctl = {
    # Google BBR Congestion Control & FQ Pacing
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # Chống tụt tốc độ sau khi kết nối nhàn rỗi (Low Latency)
    "net.ipv4.tcp_slow_start_after_idle" = 0;

    # TCP Fast Open cho cả client và server (giảm 1 RTT)
    "net.ipv4.tcp_fastopen" = 3;

    # Tự động dò MTU tối ưu để tránh phân mảnh gói tin
    "net.ipv4.tcp_mtu_probing" = 1;

    # Tái sử dụng socket TIME_WAIT an toàn
    "net.ipv4.tcp_tw_reuse" = 1;

    # Mở rộng hàng đợi gói tin card mạng (chống drop packet khi tải nặng)
    "net.core.netdev_max_backlog" = 16384;
    "net.core.somaxconn" = 8192;
    "net.ipv4.tcp_max_syn_backlog" = 8192;

    # Bộ đệm TCP tối ưu cho đường truyền băng thông rộng (16MB max)
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";

    # Virtual Memory & ZRAM Tuning (Tối ưu hóa RAM & chống giật bộ nhớ)
    "vm.swappiness" = 180;             # Ưu tiên nén RAM vào ZRAM (zstd) thay vì drop pagecache
    "vm.page-cluster" = 0;             # Đọc 1 trang (4KB)/lần trên ZRAM, loại bỏ độ trễ giật lag
    "vm.vfs_cache_pressure" = 100;     # Mặc định (100) để giải phóng cache file/dentry, giữ RAM luôn nhẹ
    "vm.dirty_ratio" = 10;             # Giới hạn dirty memory tối đa 10% tránh nghẽn I/O ghi đĩa
    "vm.dirty_background_ratio" = 5;   # Bắt đầu ghi nền ra đĩa từ 5% dirty pages
    "vm.watermark_boost_factor" = 0;   # Vô hiệu hóa boost kswapd để chống giật micro-stutter
    "vm.watermark_scale_factor" = 10;  # Mặc định (10) không giữ vùng đệm ảo, giúp Waybar hiện đúng mức ~1GB
  };

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "50%";
    cleanOnBoot = true;
  };

  # ============================================================================
  # 3. NIX PACKAGE MANAGER & FLAKES
  # ============================================================================
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-39.8.10"
    ];
  };

  # ============================================================================
  # 4. HARDWARE OPTIMIZATION & POWER MANAGEMENT (ThinkPad P14s AMD)
  # ============================================================================
  hardware = {
    enableAllFirmware = true;

    cpu.amd.updateMicrocode = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          # Dual mode for BLE mouse (BT5.2) and classic Bluetooth audio (AirPods)
          ControllerMode = "dual";
          Experimental = true;
          FastConnectable = true;
          JustWorksRepairing = "always";
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };
  };

  # SSD TRIM
  services.fstrim.enable = true;

  # Power management
  powerManagement.powertop.enable = false;
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # amd_pstate active: 'powersave' governor allows dynamic EPP hardware scaling
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # balance_performance: xung nhịp tối đa khi tải nặng, mát mẻ khi nhàn rỗi
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Radeon 780M tự động tăng giảm xung theo tải đồ họa thay vì ép chạy max
      RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
      RADEON_DPM_PERF_LEVEL_ON_BAT = "auto";

      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      USB_AUTOSUSPEND = 1;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER_ON_BAT = "Y";

      # Battery health charging thresholds
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Active ThinkPad fan control to maintain cool temperatures (~38°C - 42°C)
  services.thinkfan = {
    enable = true;
    sensors = [
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "k10temp";
        indices = [ 1 ];
      }
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "amdgpu";
        indices = [ 1 ];
      }
    ];
    levels = [
      [ 0  0  38 ]         # < 38°C: Fan OFF (0 RPM)
      [ 1 36  44 ]         # 38°C - 44°C: Level 1 (~1800 RPM, whisper quiet, cools continuously)
      [ 2 42  50 ]         # 44°C - 50°C: Level 2
      [ 3 48  56 ]         # 50°C - 56°C: Level 3
      [ 5 54  65 ]         # 56°C - 65°C: Level 5
      [ 7 62  78 ]         # 65°C - 78°C: Level 7
      [ "level auto" 75 32767 ] # > 78°C: Hand back to BIOS/EC full power
    ];
  };

  # Fan behavior: Active custom cooling on AC; BIOS default (level auto) on Battery
  systemd.services.thinkfan = {
    unitConfig = {
      ConditionACPower = true;
    };
    serviceConfig = {
      ExecStopPost = "${pkgs.bash}/bin/bash -c 'echo \"level auto\" > /proc/acpi/ibm/fan || true'";
    };
  };

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
    SUBSYSTEM=="power_supply", KERNEL=="AC", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl stop thinkfan.service"
    SUBSYSTEM=="power_supply", KERNEL=="AC", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl start thinkfan.service"
  '';

  # ZRAM swap (50% RAM with zstd compression)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # ============================================================================
  # 5. NETWORKING & FIREWALL
  # ============================================================================
  networking = {
    hostName = "nixos";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    networkmanager = {
      enable = true;
      wifi.powersave = false; # Tắt powersave để giảm ping spikes & jitter khi dùng Wi-Fi
    };
    firewall = {
      allowedTCPPorts = [ 53317 5900 3000 ];
      allowedUDPPorts = [ 53317 5900 3000 ];
    };
  };

  # Local DNS Caching & Security (0ms cho các domain đã truy vấn)
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    dnsovertls = "opportunistic";
  };

  # Disable unused modem service
  systemd.services.ModemManager.enable = false;

  # Fast shutdown timeout
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };

  # ============================================================================
  # 6. LOCALIZATION & INPUT METHOD
  # ============================================================================
  time.timeZone = "Asia/Ho_Chi_Minh";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "vi_VN";
      LC_IDENTIFICATION = "vi_VN";
      LC_MEASUREMENT = "vi_VN";
      LC_MONETARY = "vi_VN";
      LC_NAME = "vi_VN";
      LC_NUMERIC = "vi_VN";
      LC_PAPER = "vi_VN";
      LC_TELEPHONE = "vi_VN";
      LC_TIME = "en_US.UTF-8";
    };

    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-bamboo
          fcitx5-gtk
          qt6Packages.fcitx5-unikey
          kdePackages.fcitx5-configtool
        ];
      };
    };
  };

  # ============================================================================
  # 7. FONTS & TYPOGRAPHY
  # ============================================================================
  fonts = {
    packages = with pkgs; [
      nerd-fonts.geist-mono
      nerd-fonts.jetbrains-mono
      geist-font
      inter
      dejavu_fonts
      noto-fonts
      libertinus
      font-awesome

      # Microsoft Office / Word Common Fonts (Times New Roman, Arial, Calibri, Cambria, etc.)
      corefonts
      vista-fonts
      liberation_ttf
      carlito
      caladea
    ];

    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "none";
        lcdfilter = "none";
      };
    };
  };

  # ============================================================================
  # 8. SOUND (PIPEWIRE)
  # ============================================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # ============================================================================
  # 9. GRAPHICAL ENVIRONMENT & DISPLAY MANAGER
  # ============================================================================
  # Pure Wayland minimal setup (No SDDM, No X11 Server - Default TTY login)
  services.xserver.enable = false;
  services.displayManager.sddm.enable = false;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Disable CUPS printing
  services.printing.enable = false;

  # Sway Window Manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Niri Window Manager (Scrollable-tiling Wayland compositor)
  programs.niri.enable = true;

  # XWayland — needed for X11 apps (OnlyOffice, etc.) inside Niri
  programs.xwayland.enable = true;

  # Swaylock PAM authentication
  security.pam.services.swaylock = {};

  # ============================================================================
  # 10. USER ACCOUNTS & DEFAULT SHELL
  # ============================================================================
  users.users."aquistus" = {
    isNormalUser = true;
    description = "Nguyen The";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "uinput"
      "video"
      "docker"
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship.enable = true;

  # ============================================================================
  # 11. CORE SYSTEM PROGRAMS & SERVICES
  # ============================================================================
  # FHS / CLI compatibility
  programs.nix-ld.enable = true;

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Docker virtualization (on-demand to save RAM)
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    autoPrune.enable = true;
  };

  # Firefox with AMD VA-API hardware acceleration & OLED color management
  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "media.hardware-video-decoding.enabled" = true;
      "gfx.webrender.all" = true;
      "browser.tabs.unloadOnLowMemory" = true;
      "widget.use-xdg-desktop-portal.file-picker" = 1;
      "widget.use-xdg-desktop-portal.mime-handler" = 1;
      "gfx.color_management.mode" = 1;
      "gfx.color_management.enablev4" = true;
      "gfx.font_rendering.cleartype_params.subpixel_structure" = 0;
    };
  };

  # ============================================================================
  # 12. ENVIRONMENT VARIABLES
  # ============================================================================
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    XMODIFIERS = "@im=fcitx";
    GTK_MODULES = "appmenu-gtk-module";
    AMD_VULKAN_ICD = "RADV";
  };

  # ============================================================================
  # 13. SYSTEM PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    # --- Terminal & Neovim ---
    foot
    neovim
    ripgrep
    fd
    tree-sitter

    # --- CLI Utilities & Monitoring ---
    fastfetch
    htop
    btop
    bluetuith
    wget
    curl
    unzip
    jq
    yq
    proton-vpn-cli
    wireguard-tools

    # --- Sway / Wayland Desktop Utilities ---
    waybar
    fuzzel
    nnn
    adwaita-icon-theme
    mako
    swaybg
    swayidle
    swaylock-effects
    cliphist
    wl-clipboard
    grim
    slurp
    wlsunset
    pavucontrol
    brightnessctl
    libnotify
    kanshi
    wdisplays
    polkit_gnome
    wtype

    # --- Media, Audio & Document Viewers ---
    zathura
    swayimg
    mpv
    mpd
    rmpc
    mpd-mpris
    yazi
    yt-dlp
    cava
    playerctl
    poppler-utils
    libdbusmenu-gtk3
    goldendict-ng
    sdcv

    # --- Development, Compilers & Tools ---
    gcc
    git
    dotnet-sdk
    jdk21
    maven
    jetbrains.idea
    gdb
    gnumake
    cmake
    pkg-config
    nodejs
    pnpm
    appimage-run
    vulkan-tools
    vscode
    # --- Python Data Stack ---
    (python3.withPackages (ps: with ps; [
      pandas
      numpy
      matplotlib
      requests
      pdfplumber
      pytesseract
      openpyxl
    ]))
    tesseract

    # --- LaTeX & Academic Publishing ---
    tectonic
    texmaker
    (texliveMedium.withPackages (ps: with ps; [
      xargs
      bigfoot
      fontawesome5
      babel-vietnamese
      enumitem
      vntex
      moderncv
      fontspec
      latexmk
      titlesec
      mdframed
      thmtools
      needspace
      zref
    ]))

    # --- DevOps, Cloud & Databases ---
    postgresql
    duckdb
    docker-compose
    lazydocker
    kubectl
    k9s
    kubernetes-helm
    opentofu
    gh

    # --- Desktop Applications ---
    vesktop
    localsend
    onlyoffice-desktopeditors
    xwayland-satellite
    rnote
    kdePackages.kdenlive
    obsidian
    logseq
    brave
    heroic

    # --- Disabled / Bloatware (Keep commented for future reference) ---
    # haruna
    # kitty
    # rofi
    # vscode
    # texstudio
    # dbeaver-bin
    # networkmanagerapplet
    # pamixer
    # sway-contrib.grimshot
    # mangohud
    # xdotool
    # whitesur-icon-theme
    # whitesur-cursors
  ];

  # ============================================================================
  # 14. DISABLED / OPTIONAL BACKGROUND SERVICES
  # ============================================================================
  # services.blueman.enable = true;      # Not needed: dotfiles use bluetooth-scanner (TUI) & bluetoothctl
  # services.fwupd.enable = true;        # Disabled: saves ~50MB RAM & background CPU
  services.cloudflare-warp.enable = true;
  # services.openssh.enable = true;
  # programs.steam.enable = true;
  # ============================================================================
  # 15. HARDWARE / DRAWING TABLET (XP-Pen Deco Fun XS)
  # ============================================================================
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };
  hardware.uinput.enable = true;

  # ============================================================================
  # 16. NIXOS RELEASE STATE VERSION
  # ============================================================================
  system.stateVersion = "26.05";
}
