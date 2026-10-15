{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      mssql = {
        image = "mcr.microsoft.com/mssql/server:2017-latest";
        ports = [ "127.0.0.1:1433:1433" ];
        environment = {
          ACCEPT_EULA = "Y";
          MSSQL_PID = "Developer";
          MSSQL_MEMORY_LIMIT_MB = "2048";
        };
        environmentFiles = [
          "/var/lib/secrets/mssql.env"
        ];
        volumes = [ "/var/lib/mssql:/var/opt/mssql" ];
        autoStart = true;
      };

      mysql = {
        image = "mysql:8.4";
        ports = [ "127.0.0.1:3306:3306" ];
        environment = {
          MYSQL_DATABASE = "appdb";
          MYSQL_USER = "appuser";
        };
        environmentFiles = [
          "/var/lib/secrets/mysql.env"
        ];
        volumes = [ "/var/lib/mysql:/var/lib/mysql" ];
        autoStart = true;
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/mssql 0750 10001 0 -"
    "d /var/lib/mysql 0750 999 999 -"
    "d /var/lib/secrets 0700 root root -"
  ];

  users.users.t.extraGroups = [ "docker" ];
}

#   sudo install -d -m 700 /var/lib/secrets

#   sudo nano /var/lib/secrets/mysql.env
#   MYSQL_ROOT_PASSWORD=your_strong_root_password
#   MYSQL_PASSWORD=your_strong_app_password

#   sudo nano /var/lib/secrets/mssql.env
#   MSSQL_SA_PASSWORD=your_strong_app_password