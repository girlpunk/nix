{pkgs, ...}: {
  # Local LLM inference for opencode (see home/machine/sam@minos). No GPU on
  # minos, so CPU build; swap the package for pkgs.ollama-cuda / -rocm /
  # -vulkan if that ever changes.
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cpu;

    # Pulled on boot so a model is ready before the first session.
    loadModels = [
      "qwen3:30b" # MoE (30B total, 3B active): best coding model that fits CPU-only in 48GB
      "qwen3:8b" # smaller, fast fallback
    ];

    environmentVariables = {
      # opencode sessions get long
      OLLAMA_CONTEXT_LENGTH = "32768";
      # keep only one model resident in RAM at a time
      OLLAMA_MAX_LOADED_MODELS = "1";
    };
  };
}
