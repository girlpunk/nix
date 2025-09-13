{
  lib,
  appimageTools,
  fetchurl,
}: let
  version = "1.68.0";
  pname = "marvin";

  src = fetchurl {
    url = "https://amazingmarvin.s3.amazonaws.com/Marvin-${version}.AppImage";
    hash = "sha256-c6ql3loog0nU7dcCHe5ba7PEhcyQ+MwTTIAKKT5aOB4=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
  appimageTools.wrapType2 rec {
    inherit pname version src;

    #  extraInstallCommands = ''
    #    substituteInPlace $out/share/applications/${pname}.desktop \
    #      --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
    #  '';

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
      install -m 444 -D ${appimageContents}/${pname}.png     $out/share/icons/hicolor/512x512/apps/${pname}.png
      substituteInPlace $out/share/applications/${pname}.desktop --replace 'Exec=AppRun' 'Exec=${pname}'
    '';

    meta = {
      description = "Personal productivity app that incorporates principles from behavioral psychology to help you beat procrastination, feel in control and finish your to-do list";
      homepage = "https://amazingmarvin.com/";
      #    license = lib.licenses.mkLicense {
      #      free = false;
      #      url = "https://amazingmarvin.com/terms/";
      #      fullName = "Amazing Marvin License";
      #    };
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      mainProgram = "marvin";
      #maintainers = with lib.maintainers; [ onny ];
      platforms = ["x86_64-linux"];
    };
  }
