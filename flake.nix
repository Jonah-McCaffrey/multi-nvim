{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    packages.x86_64-linux.neovim-custom = import ./neovim-custom.nix {inherit pkgs;};

    packages.x86_64-linux.default = self.packages.x86_64-linux.neovim-custom;
  };
}
