job "postgres-server" {
  datacenters = ["dc1"]
  type = "service"

  group "postgres-server" {
    count = 1

    volume "pgdata" {
      type = "host"
      read_only = false
      source = "default"
    }

    task "postgresql" {
      driver = "docker"

      config {
        image = "postgres"
        network_mode = "host"
        port_map = {
          db = 5432
        }
      }

      env {
          POSTGRES_USER="nomad-demo"
          POSTGRES_PASSWORD="demo"
      }

      volume_mount {
        volume = "pgdata"
        destination = "/var/lib/postgresql"
        read_only = false
      }

      resources {
        cpu = 1000
        memory = 1024

        network {
          mbits = 100
          port "db" {
            static = 5432
          }
        }
      }

      # service {
      #   name = "postgres"
      #   port = "db"
      # }
    }
  }
}
