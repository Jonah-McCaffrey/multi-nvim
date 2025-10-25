{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mapAttrsToList hasAttr;
in {
  # Function to generate the wrapped Neovim package
  pkgGenFunction = mapAttrsToList (
    pkgName: pkgConf: let
      nvimPackage =
        if hasAttr "nvimPackage" pkgConf
        then pkgConf.nvimPackage
        else pkgs.neovim;
      configName =
        if hasAttr "configName" pkgConf
        then pkgConf.configName
        else pkgName;
      runtimeDeps =
        if hasAttr "dependencies" pkgConf
        then pkgConf.dependencies
        else [];
    in
      # pkgs.symlinkJoin {
      #   name = pkgName; # Custom package name
      #
      #   paths = [nvimPackage] ++ runtimeDeps;
      #
      #   nativeBuildInputs = [pkgs.makeWrapper];
      #
      #   postBuild = ''
      #     mv $out/bin/nvim $out/bin/${pkgName}  # Custom binary name
      #     wrapProgram $out/bin/${pkgName} \
      #       --set NVIM_APPNAME ${configName}  # Custom config dir: ~/.config/nvim-custom
      #   '';
      # }
      pkgs.buildEnv {
        name = pkgName; # Custom package name

        paths = [nvimPackage] ++ runtimeDeps;

        nativeBuildInputs = [pkgs.makeWrapper];

        pathsToLink = [
          "/lib" # Libraries for runtime linking
          "/lib64" # 64-bit libs (if applicable)
          "/include" # Headers, if needed
          "/share" # Data/config files
        ];

        postBuild = ''
          mv $out/bin/nvim $out/bin/${pkgName}  # Custom binary name
          wrapProgram $out/bin/${pkgName} \
            --set NVIM_APPNAME ${configName}  # Custom config dir: ~/.config/nvim-custom
        '';
      }
  );
}
