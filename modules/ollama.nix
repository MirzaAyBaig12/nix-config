{ 
  config, 
  pkgs, 
  ... 
}:

{
  services.ollama = {
    enable = true;

    # CPU inference for Intel Iris Xe
    package = pkgs.ollama-cpu;

    # Local API only
    host = "127.0.0.1";
    port = 11434;

    # Declarative model management
    loadModels = [
      "qwen2.5-coder:3b"
    ];

    syncModels = true;

    # Service configuration
    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_KEEP_ALIVE = "5m";
      OLLAMA_CONTEXT_LENGTH = "4096";
    };
  };
}
