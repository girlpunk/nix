{
  pkgs,
  makeDesktopItem,
  ...
}: let
  version = "2.3.1";
  appimageName = "Bambu_Studio_ubuntu-24.04_PR-7292.AppImage";
  Url = "https://github.com/bambulab/BambuStudio/releases/download/v02.03.01.51/Bambu_Studio_ubuntu-24.04_PR-8583.AppImage";
  Sha256 = "sha256:280ecff1535139f49045e4df13bbab1caccbb4bfb6e5e0f573dd1e55c58922fd";
  srcZipped = pkgs.fetchzip {
    url = zipUrl;
    sha256 = zipSha256;
  };
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
        #        pkgs.linuxPackages.nvidia_x11
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
