
{ config, lib, pkgs, inputs, ... }:

let
  netextender = pkgs.callPackage ./netextender.nix {
    netextender-src = inputs.netextender-src;
  };
in
{
  environment.systemPackages = [
    netextender
  ];
}
