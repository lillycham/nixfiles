{ pkgs, ... }:
{
  services = {
    xserver = {
      enable = true;

      xkbOptions = "caps:ctrl_modifier";
      
      desktopManager = {
        plasma5.enable = true;
      };
      
      displayManager = {
        sddm.enable = true;
      };
      
      videoDrivers = [ "nvidia" ];
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
      banner = ''
      STOP! This system is for AUTHORIZED users ONLY.
      ALL activity is logged.
      Any unauthorized access will be result in termination with extreme prejudice.
      '';
      forwardX11 = false;
    };

    tailscale.enable = true;

    zfs = {
      autoSnapshot = {
        enable = true;
        frequent = 8;
        monthly = 1;
      };
      trim.enable = true;
    };
  };
}
