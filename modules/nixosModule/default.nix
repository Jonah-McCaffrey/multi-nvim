{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf;
  inherit (lib.types) attrs;
  inherit (import ../../util.nix {inherit lib pkgs;}) extractDeps pkgGenFunction;
  cfg = config.programs.multi-nvim;
in {
  options = {
    programs.multi-nvim = {
      enable = mkEnableOption "multi-nvim";
      configurations = mkOption {
        type = attrs;
        default = {};
        description = "Attribute set of wrapped neovim packages.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =
      (extractDeps cfg.configurations)
      ++ (pkgGenFunction cfg.configurations);
  };
}
