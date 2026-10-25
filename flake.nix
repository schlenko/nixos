{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland/v0.56.1";

    hyprtasking = {
      url = "github:raybbian/hyprtasking";
      inputs.hyprland.follows = "hyprland";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.56.0";
      inputs.hyprland.follows = "hyprland";
    };

   netextender-src = {
    url = "https://software.sonicwall.com/NetExtender/NetExtender.Linux-10.2.850.x86_64.tgz";
    flake = false;
  };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs pkgs-unstable; };

        modules = [
          ./configuration.nix
          ./Apps/docker/docker-container.nix
          ./Apps/Packages/netextender/netextender-module.nix

          ./Hardware/hardware-configuration.nix
          ./Hardware/VFIO_Swift.nix
          


          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = { inherit inputs pkgs-unstable; };

            home-manager.users.t = import ./home.nix;
          }
        ];
      };
    };
}