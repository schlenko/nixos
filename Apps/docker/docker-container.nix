{ pkgs, ... }:

let
  mssql2022Dockerfile = pkgs.writeTextDir "Dockerfile" ''
    FROM mcr.microsoft.com/mssql/server:2022-CU24-ubuntu-22.04

    USER root

    RUN apt-get updatne \
     && apt-get install -y --no-install-recommends curl gnupg ca-certificates \
     && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
          | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
     && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/22.04/mssql-server-2022 jammy main" \
          > /etc/apt/sources.list.d/mssql-server-2022.list \
     && apt-get update \
     && apt-get install -y mssql-server-fts \
     && apt-get purge -y curl gnupg \
     && apt-get autoremove -y \
     && rm -rf /var/lib/apt/lists/*

    USER mssql
  '';
in
{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers = {

  mssql2017 = {
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

  mssql2022 = {
          image = "mssql-2022-fts:16.0.4245.2";

          autoStart = false;

          ports = [
            "127.0.0.1:1434:1433"   # 1433 is already used by the 2017 container
          ];

          volumes = [
            "/var/lib/docker/mssql2022:/var/opt/mssql"
            "/var/lib/docker/sql_import:/sql_import"
          ];

          environment = {
            ACCEPT_EULA = "Y";
            MSSQL_PID = "Developer";
          };

          environmentFiles = [
            "/var/lib/docker/secrets/mssql2022.env"
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

  # Builds the local image (cached after the first build)
  systemd.services.build-mssql2022-fts = {
    description = "Build SQL Server 2022 image with Full-Text Search";
    after = [ "docker.service" "network-online.target" ];
    requires = [ "docker.service" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.docker ];
    serviceConfig.Type = "oneshot";
    script = ''
      docker build -t mssql-2022-fts:16.0.4245.2 ${mssql2022Dockerfile}
    '';
  };

  # Make the container wait for the image build
  systemd.services.docker-mssql2022 = {
    requires = [ "build-mssql2022-fts.service" ];
    after = [ "build-mssql2022-fts.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/docker/mssql 0750 10001 0 -"
    "d /var/lib/docker/mssql2022 0750 10001 0 -"
    "d /var/lib/docker/mysql 0750 999 999 -"
    "d /var/lib/docker/sql_import 0755 root root -"
    "d /var/lib/docker/secrets 0700 root root -"
  ];

  users.users.t.extraGroups = [ "docker" ];
}

  # ------------------------------------------------------------
  # Microsoft SQL Server 2017
  #
  # Image:
  #   mcr.microsoft.com/mssql/server:2017-latest
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
  # 3. Set ownership and permissions:
  #      sudo chown root:root /var/lib/docker/secrets/mssql.env
  #      sudo chmod 600 /var/lib/docker/secrets/mssql.env
  #
  # 4. Start the container:
  #      sudo systemctl start docker-mssql2017.service
  #
  #    The container is not configured to start automatically
  #    at boot (autoStart = false).
  #
  # 5. Connect to SQL Server:
  #      Server:   localhost,1433
  #      Username: sa
  #
  # Notes:
  # - Port 1433 is published on 127.0.0.1 only.
  # - Database files persist in /var/lib/docker/mssql.
  # - Files in /var/lib/docker/sql_import are available inside
  #   the container at /sql_import.
  # - MSSQL_SA_PASSWORD is used when SQL Server initializes.
  #   Changing the environment variable does not automatically
  #   change the password stored in an existing data volume.
  # - Use separate, least-privilege SQL logins for applications.
  # ------------------------------------------------------------


  # ------------------------------------------------------------
  # Microsoft SQL Server 2022 Developer + Full-Text Search
  #
  # Image:
  #   Locally built as mssql-2022-fts:16.0.4245.2
  #   Base image: mcr.microsoft.com/mssql/server:2022-CU24-ubuntu-22.04
  #
  # Initial setup:
  # 1. Create the secrets file:
  #      sudo nano /var/lib/docker/secrets/mssql2022.env
  #
  # 2. Add the SA administrator password:
  #      MSSQL_SA_PASSWORD=YourStrongPasswordHere
  #
  #    Use a strong password that satisfies SQL Server's
  #    password policy. Do not commit this file to Git.
  #
  # 3. Set ownership and permissions:
  #      sudo chown root:root /var/lib/docker/secrets/mssql2022.env
  #      sudo chmod 600 /var/lib/docker/secrets/mssql2022.env
  #
  # 4. Rebuild the NixOS configuration:
  #      sudo nixos-rebuild switch --flake /etc/nixos#nixos
  #
  #    The build-mssql2022-fts.service builds the local image.
  #    The docker-mssql2022.service is configured to require
  #    and start after that image-build service.
  #
  # 5. Start the container:
  #      sudo systemctl start docker-mssql2022.service
  #
  # 6. Connect to SQL Server:
  #      Server:   localhost,1434
  #      Username: sa
  #
  # Notes:
  # - SQL Server runs in Developer edition (MSSQL_PID=Developer).
  #   Developer edition is intended for development and testing,
  #   not production workloads.
  # - The image installs the mssql-server-fts package for
  #   Full-Text Search support.
  # - Port 1433 inside the container is published as host port
  #   1434 on 127.0.0.1, avoiding the SQL Server 2017 port.
  # - Database files persist in /var/lib/docker/mssql2022.
  # - Files in /var/lib/docker/sql_import are available inside
  #   the container at /sql_import.
  # - MSSQL_SA_PASSWORD is used when SQL Server initializes.
  #   Changing the environment variable does not automatically
  #   change the password stored in an existing data volume.
  # - Use separate, least-privilege SQL logins for applications.
  # ------------------------------------------------------------