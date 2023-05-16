{ options, ...}:

{  
  networking = { 
    timeServers = options.networking.timeServers.default ++ [ "0.uk.pool.ntp.org " ];
    useDHCP = false;

    interfaces.enp5s0.useDHCP = true;
    interfaces.wlp4s0.useDHCP = true;
    
    wireless.enable = true;
    
    hostId = "e27b8bb6";
    hostName = "ikigai";

    extraHosts = ''
      127.0.0.1 boba.home.arpa
    '';

    firewall = {
      enable = true;
      allowedTCPPorts = [ 3000 3001 3002 8080 ];
      checkReversePath = "loose";
    };

  };
}
