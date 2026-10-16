
{ ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers = {
    mssql = {
      image = "mcr.microsoft.com/mssql/server:2017-latest";

      autoStart = false;

      ports = [
        "127.0.0.1:1433:1433"
      ];

      volumes = [
        "/var/lib/docker/mssql:/var/opt/mssql"
        "/var/lib/docker/sql_import:/sql_import"
      ];

      environment = {
        ACCEPT_EULA = "Y";
      };

      environmentFiles = [
        "/var/lib/docker/secrets/mssql.env"
      ];
    };

    mysql = {
      image = "mysql:8.4";

      autoStart = false;

      ports = [
        "127.0.0.1:3306:3306"
      ];

      volumes = [
        "/var/lib/docker/mysql:/var/lib/mysql"
        "/var/lib/docker/sql_import:/sql_import"
      ];

      environmentFiles = [
        "/var/lib/docker/secrets/mysql.env"
      ];
    };

  };

  systemd.tmpfiles.rules = [
    "d /var/lib/docker/mssql 0750 10001 0 -"
    "d /var/lib/docker/mysql 0750 999 999 -"
    "d /var/lib/docker/portainer 0750 root root -"
    "d /var/lib/docker/sql_import 0755 root root -"
    "d /var/lib/docker/secrets 0700 root root -"
  ];

  users.users.t.extraGroups = [ "docker" ];
}


    # ------------------------------------------------------------
    # Microsoft SQL Server 2017
    #
    # Initial setup:
    # 1. Create the secrets file:
    #      sudo nano /var/lib/docker/secrets/mssql.env
    #
    # 2. Add the SA administrator password:
    #      MSSQL_SA_PASSWORD=YourStrongPasswordHere
    #
    #    Use a strong password that satisfies SQL Server's
    #    password policy. Do not commit this file to Git.
    #
    # 3. Restrict access to the secrets file:
    #      sudo chown -R t:users /var/lib/docker/secrets/mssql.env
    #
    # 4. The SA login is the SQL Server system administrator:
    #      Username: sa
    #      Server:   localhost,1433
    #
    # 5. Start the container:
    #      sudo systemctl start docker-mssql.service
    #
    # IMPORTANT:
    # - The SA password is used when SQL Server initializes.
    # - Changing MSSQL_SA_PASSWORD later does not automatically
    #   change the password of an existing SQL Server data volume.
    # - Create separate, least-privilege SQL logins for applications.
    # - Port 1433 is bound to localhost only.
    # ------------------------------------------------------------



    # ------------------------------------------------------------
    # MySQL 8.4
    #
    # Initial setup:
    # 1. Create the secrets file:
    #      sudo nano /var/lib/docker/secrets/mysql.env
    #
    # 2. Add the initial root password:
    #      MYSQL_ROOT_PASSWORD=YourStrongRootPasswordHere
    #
    #    Optional: creWate an application database and user during
    #    the FIRST initialization of an empty MySQL data directory:
    #      MYSQL_DATABASE=appdb
    #      MYSQL_USER=appuser
    #      MYSQL_PASSWORD=YourStrongAppPasswordHere
    #
    #    Use strong passwords. Do not commit this file to Git.
    #
    # 3. Restrict access to the secrets file:
    #      sudo chown root:root /var/lib/docker/secrets/mysql.env
    #      sudo chmod 600 /var/lib/docker/secrets/mysql.env
    #
    # 4. Connect locally:
    #      Host:     127.0.0.1
    #      Port:     3306
    #      Username: root
    #
    #    Or connect using the application account, if configured.
    #
    # 5. Start the container:
    #      sudo systemctl start docker-mysql.service
    #
    # IMPORTANT:
    # - MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD, and
    #   MYSQL_ROOT_PASSWORD initialize a NEW, empty data directory.
    # - Changing these variables later does not automatically change
    #   existing MySQL passwords, users, or databases.
    # - Create separate, least-privilege accounts for applications.
    # - Port 3306 is bound to localhost only.
    # ------------------------------------------------------------
