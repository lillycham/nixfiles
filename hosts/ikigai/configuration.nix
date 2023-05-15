# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./systemd/code-server.nix
      ./networking.nix
      ./users.nix
      ./services.nix
    ];
  
  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    plymouth.enable = false;
    kernelParams = [ "quiet" ];
    supportedFilesystems = [ "zfs" "ntfs" ];
  };

  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
    };
  };
  
  nix = {
    gc = {
      automatic = false;
      dates = "daily";
    };
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = false;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      alacritty
      arion
      clang_14
      docker-client
      docker-compose
      egl-wayland
      killall
      kitty
      musl
      openjdk17
      oath-toolkit
      tor-browser-bundle-bin
      swtpm
    ];
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  # Set your time zone.
  time.timeZone = "GB";
  nixpkgs.config.allowUnfree = true;
  
  programs = {
    fish.enable = true;
    steam = {
      package = (pkgs.steam.override { extraProfile = "export DBUS_SYSTEM_BUS_ADDRESS="; });
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    # ssh.askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";
  };

  hardware = {
    opengl.enable = true;
    pulseaudio.enable = false;
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      modesetting.enable = true;
    };
    enableAllFirmware = true;
  };
  
  services.printing.enable = false;
  
  virtualisation = {
    docker.enable = true;
    libvirtd = {
        enable = true;
        qemu.ovmf.enable = true;
        qemu.swtpm.enable = true;
        qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
  };
  
  swapDevices = [ { device = "/dev/disk/by-uuid/a5259e30-40cc-47e3-afaa-dd3459883c29"; } ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}

