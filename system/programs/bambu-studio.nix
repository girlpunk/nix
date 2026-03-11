{
  pkgs,
  makeDesktopItem,
  ...
}: let
  version = "02.04.00.70";
  bambu-studio = pkgs.appimageTools.wrapType2 {
    name = "BambuStudio";
    pname = "bambu-studio";
    inherit version;

    #appimageContents = pkgs.appimageTools.extract {
    #  src = appimagePath;
    #};
    #src = appimagePath;
    src = pkgs.fetchurl {
      url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/Bambu_Studio_ubuntu-24.04_PR-8834.AppImage";
      sha256 = "sha256:26bc07dccb04df2e462b1e03a3766509201c46e27312a15844f6f5d7fdf1debd";
    };

    profile = ''
      export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      export GIO_MODULE_DIR="${pkgs.glib-networking}/lib/gio/modules/"
    '';
    extraPkgs = pkgs:
      with pkgs; [
        cacert
        #curl
        glib
        glib-networking
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        webkitgtk_4_1
        #libglvnd
        #fontconfig
        #dejavu_fonts
        #liberation_ttf
        #libxkbcommon
        #hack-font
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
