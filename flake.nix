{
  description = "A very basic flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs: {
    nixosModules.default = import ./modules/nixosModule;
    homeModules.default = import ./modules/homeModule;
  };
}
