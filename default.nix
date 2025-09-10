{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) hasAttr;
  inherit (lib) mkOption mkEnableOption mkIf mapAttrsToList;
  inherit (lib.types) attrs;
  cfg = config.multi-nvim;
in {
  options = {
    multi-nvim = {
      enable = mkEnableOption "multi-nvim";
      packages = mkOption {
        type = attrs;
        default = {};
        description = "Attribute set of wrapped neovim packages.";
        # name = {
        #   pkgs = ...
        #   configName = ...
        # };
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =
      mapAttrsToList (
        pkgName: pkgConf: let
          pkgs' =
            if hasAttr "pkgs" pkgConf
            then pkgConf.pkgs
            else pkgs;
        in
          pkgs.symlinkJoin {
            name = pkgName; # Custom package name

            paths = [pkgs'.neovim];

            nativeBuildInputs = [pkgs.makeWrapper];

            postBuild = ''
              mv $out/bin/nvim $out/bin/${pkgName}  # Custom binary name
              wrapProgram $out/bin/${pkgName} \
                --set NVIM_APPNAME ${pkgConf.configName}  # Custom config dir: ~/.config/nvim-custom
            '';
          }
      )
      cfg.packages;
  };
}
