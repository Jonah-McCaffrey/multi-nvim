{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) hasAttr;
  inherit (lib) mkOption mkEnableOption mkIf;
  inherit (lib.types) attrs;
  inherit (import ../../util.nix) extractDeps pkgGenFunction;
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
    home.packages =
      (extractDeps cfg.configurations)
      ++ (pkgGenFunction cfg.configurations);
  };
}
