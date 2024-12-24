{ pkgs, ...}:

{ 
  users.users = {
    lcham = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" "docker" "podman" ]; # Enable ‘sudo’ for the user, and allow access to docker socket
    };
  };
}
