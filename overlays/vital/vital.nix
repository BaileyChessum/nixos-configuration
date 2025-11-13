{ lib
, stdenv
, fetchzip
, autoPatchelfHook
, makeBinaryWrapper
, alsa-lib
, libjack2
, curl
, xorg
, libGL
, freetype
, fetchurl
, makeDesktopItem
}:

let
  pname = "vital";
  version = "1.5.5";

  meta = with lib; {
    description = "Spectral warping wavetable synth";
    homepage = "https://vital.audio/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = with licenses; [ unfree gpl3Plus ];
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ PowerUser64 ];
    mainProgram = "Vital";
  };

  icon = fetchurl {
    url = "https://vitalpublic.s3.dualstack.us-west-2.amazonaws.com/original/1X/8df2d4b7d6602a3a7f2014c765d4f780fa7c6eb6.png";
    hash = "sha256-0PkaqoUFLdy9tcLODXAdwLtQIkSOHPTDWoGxDjYgBKM=";
  };

  desktopItem = makeDesktopItem {
    name = "vital";
    desktopName = "Vital";
    comment = "Spectral warping wavetable synth";
    icon = "vital";
    exec = "Vital %u";
    mimeTypes = [ "x-scheme-handler/vital" ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version desktopItem icon meta;

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
  ];

  buildInputs = [
    alsa-lib
    stdenv.cc.cc.lib
    libGL
    xorg.libSM
    xorg.libICE
    xorg.libX11
    freetype
    libjack2
  ];

  src = fetchzip {
    url = "https://builds.vital.audio/VitalAudio/vital/${builtins.replaceStrings ["."] ["_"] finalAttrs.version}/VitalInstaller.zip";
    hash = "sha256-hCwXSUiBB0YpQ1oN6adLprwAoel6f72tBG5fEb61OCI=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # copy each output to its destination (individually)
    mkdir -p $out/{bin,lib/{clap,vst,vst3}}
    for f in bin/Vital lib/{clap/Vital.clap,vst/Vital.so,vst3/Vital.vst3}; do
      cp -r $f $out/$f
    done

    wrapProgram $out/bin/Vital \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ curl libjack2 ]}"

    runHook postInstall
  '';
})