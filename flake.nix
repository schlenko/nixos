{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
      hyprtasking-src = {
      url = "github:colonelpanic8/hyprtasking/hyprland-0.57";
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
      legacyPackages.${system} = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;


      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs pkgs-unstable; };

        modules = [
          ./configuration.nix
          ./Apps/docker/docker-container.nix

          ./Hardware/hardware-configuration.nix
          ./Hardware/VFIO_Swift.nix
          ./Hardware/boot-style.nix
        #  ./Hardware/Nvidia.nix

          ./Hardware/display-scaling.nix

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