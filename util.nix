{
  lib,
  pkgs,
  ...
}: {
  # Function to generate the wrapped Neovim package
  pkgGenFunction = lib.mapAttrsToList (
    pkgName: pkgConf: let
      nvimPackage =
        if pkgConf ? "nvimPackage"
        then pkgConf.nvimPackage
        else pkgs.neovim;
      configName =
        if pkgConf ? "configName"
        then pkgConf.configName
        else pkgName;
      dependencies =
        if pkgConf ? "dependencies"
        then pkgConf.dependencies
        else [];
    in
      pkgs.symlinkJoin {
        name = pkgName; # Custom package name

        paths = [nvimPackage] ++ dependencies;

        nativeBuildInputs = [pkgs.makeWrapper];

        postBuild = ''
          mv $out/bin/nvim $out/bin/${pkgName}  # Custom binary name
          wrapProgram $out/bin/${pkgName} \
            --set NVIM_APPNAME ${configName}  # Custom config dir: ~/.config/nvim-custom
        '';
      }
  );
}
