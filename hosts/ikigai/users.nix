{ pkgs, ...}:

{ 
  users.users = {
    lillycham = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" "docker" "podman" ]; # Enable ‘sudo’ for the user, and allow access to docker socket
    };
  };
}
