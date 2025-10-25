{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (builtins) hasAttr;
  inherit (lib) mkOption mkEnableOption mkIf mapAttrsToList flatten unique;
  inherit (lib.types) attrs;
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
  config = mkIf cfg.enable (
    let
      # Extract package dependencies for all configurations
      dependencies = unique (flatten (mapAttrsToList (_: value:
        if hasAttr "dependencies" value
        then value.dependencies
        else [])
      cfg.configurations));

      # Function to generate the wrapped Neovim package
      pkgGenFunction = mapAttrsToList (
        pkgName: pkgConf: let
          pkgs' =
            if hasAttr "pkgs" pkgConf
            then pkgConf.pkgs
            else pkgs;
          configName =
            if hasAttr "configName" pkgConf
            then pkgConf.configName
            else pkgName;
        in
          pkgs.symlinkJoin {
            name = pkgName; # Custom package name

            paths = [pkgs'.neovim];

            nativeBuildInputs = [pkgs.makeWrapper];

            postBuild = ''
              mv $out/bin/nvim $out/bin/${pkgName}  # Custom binary name
              wrapProgram $out/bin/${pkgName} \
                --set NVIM_APPNAME ${configName}  # Custom config dir: ~/.config/nvim-custom
            '';
          }
      );
    in {
      home.packages =
        dependencies
        ++ (pkgGenFunction cfg.configurations);
    }
  );
}
