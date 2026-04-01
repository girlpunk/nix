_: {
  programs.discord = {
    enable = true;
    settings = {
      DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOUR_DOING = true;
      SKIP_HOST_UPDATE = true;
    };
  };
}
