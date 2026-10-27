{
  lib,
  pkgs,
  ...
}: {
  defaultGit.work = true;

  imports = [
    ../../programs/git/work.nix
    ../../programs/opencode
  ];

  programs = {
    nh = {
      flake = lib.mkForce "/mnt/d/nix#work";
    };

    npm.enable = true;

    opencode = {
      settings = {
        plugin = ["opencode-concurrency-limit"];

        provider = {
          litellm = {
            npm = "@ai-sdk/openai-compatible";
            name = "LiteLLM";
            options = {
              baseURL = "http://192.168.105.1:4000/v1";
            };
            models = {
              "qwen3.8-27b" = {
                name = "qwen3.8-27b";
                options = { concurrency = 1; };
              };
              hermes-agent = {
                name = "Giles";
                options = { concurrency = 1; };
              };
            };
          };
        };

        mcp = {
          visualstudio = {
            type = "remote";
            url = "http://localhost:5050";
            enabled = true;
          };
        };
      };
    };
  };
}
