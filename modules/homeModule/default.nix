{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf;
  inherit (lib.types) attrs listOf package;
  inherit (import ../../util.nix {inherit lib pkgs;}) pkgGenFunction;
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
      globalDeps = mkOption {
        type = listOf package;
        default = [];
        description = "Packages to include as runtime dependencies for all configurations";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = (pkgGenFunction cfg.configurations) ++ cfg.globalDeps;
  };
}
