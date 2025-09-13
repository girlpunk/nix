{
  pkgs,
  makeDesktopItem,
  ...
}: let
  version = "2.1.1";
  appimageName = "Bambu_Studio_ubuntu-24.04_PR-7292.AppImage";
  zipUrl = "https://github.com/bambulab/BambuStudio/releases/download/v02.01.01.52/BambuStudio_ubuntu-24.04_PR-7292.zip";
  zipSha256 = "sha256-0xQqDlW0yHnshy6O7nsmOGT49XsLjf6Y8TPnyohp7Sc=";
  srcZipped = pkgs.fetchzip {
    url = zipUrl;
    sha256 = zipSha256;
  };
  appimagePath = "${srcZipped}/${appimageName}";
  bambu-studio = pkgs.appimageTools.wrapType2 {
    name = "BambuStudio";
    pname = "bambustudio";
    inherit version;
    appimageContents = pkgs.appimageTools.extract {
      src = appimagePath;
    };
    src = appimagePath;
    profile = ''
      export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      export GIO_MODULE_DIR="${pkgs.glib-networking}/lib/gio/modules/"
    '';
    extraPkgs = pkgs:
      with pkgs; [
        cacert
        curl
        glib
        glib-networking
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        webkitgtk_4_1
        pkgs.linuxPackages.nvidia_x11
        libglvnd
        fontconfig
        dejavu_fonts
        liberation_ttf
        libxkbcommon
        hack-font
      ];
    desktopItems = [
      (makeDesktopItem {
        name = "BambuStudio";
        exec = "GBM_BACKEND=dri bambustudio";
        icon = "BambuStudio";
        genericName = "3D Printing Software";
        categories = ["Graphics" "3DGraphics" "Engineering"];
        terminal = false;
        mimeTypes = ["model/stl" "model/3mf" "application/vnd.ms-3mfdocument" "application/prs.wavefront-obj" "application/x-amf" "x-scheme-handler/bambustudio"];
        startupNotify = false;
      })
    ];
  };
in {
  environment.systemPackages = [bambu-studio];
}
