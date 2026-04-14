_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        controlPersist = "5m";
        controlMaster = "auto";
        addKeysToAgent = "yes";
        forwardAgent = true;

        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlPath = "~/.ssh/master-%r@%n:%p";
      };
      "minos" = {
        hostname = "192.168.42.24";
        forwardAgent = true;
      };
      "10.101.15.2" = {
        forwardAgent = true;
      };
    };
  };

  services.ssh-agent.enable = false;
}
