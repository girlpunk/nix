{ inputs, pkgs, lib, ... }:

let
  username = "sam";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  packages = with pkgs; [
    dig # dns command-line tool
    docker-compose # docker manager
    duf # disk usage/free utility
    du-dust
    eza # a better `ls`
    killall # kill processes by name
    ncdu # disk space info (a better du)
    tree # display files in a tree view
    jq
    file
    tree
    kubectl
    wget
    ffmpeg-headless
    yt-dlp
    watch
    nano
    _1password-cli
    nixfmt-rfc-style
    terraform
    comma

    # Python
    python3
    hatch
    unstable.jetbrains.pycharm-professional

    # Rust
    rustPlatform.rustcSrc
    rustc
    rustfmt
    cargo
    pkg-config
    gcc
    unstable.jetbrains.rust-rover
  ];
in
{
  programs.home-manager.enable = true;

  imports = lib.concatMap import [
    ../modules
    #../scripts
    #../themes
    ./programs.nix
    ./services.nix
  ];

  xdg = {
    inherit configHome;
    enable = true;
    autostart.enable = true;
    userDirs.enable = true;
    userDirs.createDirectories = true;
  };

  home = {
    inherit username homeDirectory packages;

    changes-report.enable = true;

    language.base = "en_GB";

    sessionVariables = {
      DOTNET_ROOT = "${pkgs.dotnet-sdk_9}/share/dotnet";
      #LANG = "en_GB.UTF-8";
      LC_CTYPE = "en_GB.UTF-8";
      LC_ALL = "en_GB.UTF-8";
      PAGER = "less -FirSwX";
      # https://github.com/NixOS/nixpkgs/issues/24311#issuecomment-980477051
      GIT_ASKPASS = "";

      # https://github.com/rust-lang/rust-bindgen#environment-variables
      #LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
      #LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (buildInputs ++ nativeBuildInputs);
      # Add precompiled library to rustc search path
      #RUSTFLAGS = (builtins.map (a: ''-L ${a}/lib'') [
      #  # add libraries here (e.g. pkgs.libvmi)
      #]);
      # Add glibc, clang, glib, and other headers to bindgen search path
      #BINDGEN_EXTRA_CLANG_ARGS =
      #  # Includes normal include path
      #  (builtins.map (a: ''-I"${a}/include"'') [
      #    # add dev libraries here (e.g. pkgs.libvmi.dev)
      #    pkgs.glibc.dev
      #  ])
      #  # Includes with special directory paths
      #  ++ [
      #    ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
      #    ''-I"${pkgs.glib.dev}/include/glib-2.0"''
      #    ''-I${pkgs.glib.out}/lib/glib-2.0/include/''
      #  ];
      RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    };

    sessionPath = [
      "$HOME/.dotnet/tools"
    ];
  };

  programs.nh = {
    enable = true;
    flake = "/home/sam/programs/nix";
  };

  manual.html.enable = true;

  # restart services on change
  #systemd.user.startServices = "sd-switch";

  # notifications about home-manager news
  news.display = "show";

  home.stateVersion = "24.05";
}
