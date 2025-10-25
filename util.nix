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

      # Runtime deps env: Merges libs/data without /bin
      runtimeEnv = pkgs.buildEnv {
        name = "myvim-runtime";
        paths = runtimeDeps;
        pathsToLink = [
          "/lib" # Shared libraries
          "/lib64" # 64-bit libs
          "/share" # Data, configs, or Neovim runtime files (e.g., /share/nvim)
          "/include" # Headers if needed
          # Add others like "/etc" if relevant; explicitly omit "/bin"
        ];
        # Optional: Install extra outputs (e.g., dev/docs)
        # extraOutputsToInstall = ["dev" "doc"];
      };
    in
      pkgs.symlinkJoin {
        name = pkgName; # Custom package name

        paths = [nvimPackage runtimeEnv];

        nativeBuildInputs = [pkgs.makeWrapper];

        postBuild = ''
          mv $out/bin/nvim $out/bin/${pkgName}  # Custom binary name
          wrapProgram $out/bin/${pkgName} \
            --set NVIM_APPNAME ${pkgName}  # Custom config dir: ~/.config/nvim-custom
          # Optional: For runtime access, e.g., add to Neovim's runtimepath or LD_LIBRARY_PATH
          # wrapProgram $out/bin/${pkgName} \
          #   --suffix PATH : "${runtimeEnv}/bin" \  # Only if you *want* some bins selectively
          #   --suffix LD_LIBRARY_PATH : "$out/lib";  # Ensures libs are found
        '';
      }
  );
}
