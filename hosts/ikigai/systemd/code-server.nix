{ pkgs, ... }:
{
  systemd.services = {
    code-server = {
      description = "Visual Studio Code Webserver Daemon";
      after = [ "nginx.service" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.code-server}/bin/code-server --bind-addr 100.98.33.42:8080";
        Restart = "always";
        User = "code-server";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
