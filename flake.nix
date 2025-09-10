{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs:
  # let
  #   systems = ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
  #   eachSystem = nixpkgs.lib.genAttrs systems;
  # in
  #   eachSystem (system: let
  #     pkgs = import nixpkgs {
  #       inherit system;
  #     };
  #   in {
  #
  #   });
  {
    nixosModules.default = import ./modules/nixosModule;
    homeModules.default = import ./modules/homeModule;
  };
}
