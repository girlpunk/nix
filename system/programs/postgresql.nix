{pkgs, ...}: {
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_18;

      # Sized for mnemosyne: 4 vCPU, 40 GB RAM, NVMe (virtio)
      settings = {
        shared_buffers = "4GB";
        effective_cache_size = "16GB";
        work_mem = "32MB";
        maintenance_work_mem = "512MB";
        wal_buffers = "16MB";
        max_wal_size = "4GB";
        min_wal_size = "1GB";
        checkpoint_completion_target = 0.9;
        max_connections = 200;
        random_page_cost = 1.1;
        effective_io_concurrency = 256;
      };
    };

    postgresqlBackup = {
      enable = true;
    };
  };
}
