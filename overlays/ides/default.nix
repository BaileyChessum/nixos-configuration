final: prev: 

let
  dotnetPkg =
    (with prev.dotnetCorePackages; combinePackages [
      sdk_8_0
    ]);

  rider-fhs = prev.buildFHSUserEnv {
    name = "rider-fhs";
    runScript = "";
    targetPkgs = pkgs: with pkgs; [
      dotnetPkg
      mono
      msbuild
      powershell
    ];
  };
in
{
  jetbrains = prev.jetbrains // {
    clion = prev.jetbrains.clion.overrideAttrs (old: {
      propegatedBuildInputs = [
        final.cmake
        final.libgcc
      ] ++ old.propegatedBuildInputs or [];
    });

    webstorm = prev.jetbrains.webstorm.overrideAttrs (old: {
      propegatedBuildInputs = [
        final.nodejs
        final.yarn
        final.nodePackages.eslint
        final.nodePackages.typescript
        final.nodePackages.typescript-language-server
      ] ++ old.propegatedBuildInputs or [];
    });

    pycharm-professional = prev.jetbrains.pycharm-professional;

    rider = prev.jetbrains.rider.overrideAttrs (attrs: {
      postInstall = ''
        echo BAILEY AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 

        # wrap rider in my custom fhs which has some dependencies
        mv $out/bin/rider $out/bin/.rider-unwrapped

        cat >$out/bin/rider <<EOL
        #!${final.bash}/bin/bash
        ${rider-fhs}/bin/rider-fhs $out/bin/.rider-unwrapped "\$@"
        EOL

        chmod +x $out/bin/rider

        ## Making Unity Rider plugin work!
        # unity plugins looks for a build.txt at ../../build.txt, relative to binary
        # same for hte product-info.json, both are used for BuildVersion and Numbers
        ln -s $out/rider/build.txt $out/
        ln -s $out/rider/product-info.json $out/

        # looks for ../../plugins/rider-unity, relative to binary
        # it needs some dll file in there, which it uses to bind to rider
        ln -s $out/rider/plugins $out/plugins
      '' + attrs.postInstall or "";
    });
  };
}