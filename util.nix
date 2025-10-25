{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) unique flatten mapAttrsToList hasAttr;
in {
  # Extract package dependencies for all configurations
  # extractDeps = configurations:
  #   unique (flatten (mapAttrsToList (_: value:
  #     if hasAttr "dependencies" value
  #     then value.dependencies
  #     else [])
  #   configurations));

  extractDeps = unique flatten mapAttrsToList (_: value:
    if hasAttr "dependencies" value
    then value.dependencies
    else []);

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
}
