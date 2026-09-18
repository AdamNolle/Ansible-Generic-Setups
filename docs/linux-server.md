# Linux server / homelab profile

The `linux_server` play turns an existing Debian or Ubuntu host into a durable
Docker server without treating its disks or secrets casually. It is designed
for media, AI, document, backup, and dashboard services such as Jellyfin,
Immich, Ollama, Open WebUI, Paperless-ngx, SearXNG, Homepage, Glances,
LanguageTool, Uptime Kuma, Karakeep, and Cloudflared.

## What it manages

- baseline utilities, correct timezone, security updates, SMART tooling, and
  periodic SSD trimming;
- existing data disks mounted by **filesystem UUID**, with a safe `nofail`
  systemd timeout and a recurring mount/Docker health check;
- Docker Engine, Compose v2, daemon log rotation, live restore, a shared
  service network, and boot-time stack recovery through Compose restart
  policies plus generated systemd recovery units;
- optional NVIDIA Container Toolkit setup for CUDA, NVENC, Ollama, and Immich
  machine-learning containers;
- opt-in UFW, preserving SSH before applying any deny rule;
- opt-in Docker image cleanup that never deletes volumes; and
- optional high-memory sysctl tuning that keeps services and hot filesystem
  data resident before reaching swap/zram; and
- idempotent deployment of any number of Compose projects from a separate,
  secret-aware source tree.

It never partitions or formats a disk, moves media, opens ports, changes SSH
authentication, deploys an application, or removes Docker images by default.

## First run

1. Install the collections:

   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

2. Add the target under `linux_server` in your inventory. For a local server,
   use `localhost` and `ansible_connection: local`.
3. Create host-specific variables (for example
   `host_vars/homelab.yml`) from `group_vars/linux_server.yml`.
4. Identify disks with `lsblk -f`, then set only existing filesystem UUIDs.
5. Keep all `.env` files, Cloudflared credentials, application passwords, and
   API tokens in Ansible Vault or another secret manager. Do not commit them.
6. Validate before changing a host:

   ```bash
   ansible-playbook site.yml --limit linux_server --syntax-check
   ansible-playbook site.yml --limit linux_server --check --diff -K
   ansible-playbook site.yml --limit linux_server -K
   ```

## Storage example

```yaml
linux_server_storage_mounts:
  - name: backup
    uuid: 70cbde53-dbba-4d40-9ec3-9b771a18c15d
    path: /mnt/backup
    fstype: ext4
    options: defaults,nofail,x-systemd.device-timeout=10
```

This writes an `fstab` entry and mounts the existing filesystem. It refuses a
raw `/dev/sdX` source and never invokes `mkfs`, protecting the most common
media-drive accident.

## Compose deployment example

Keep the production stack in a private directory or repository, with no
secrets in this public setup repository:

```yaml
linux_server_compose_projects:
  - name: jellyfin
    source: ./private-services/jellyfin
    compose_files: [docker-compose.yml]
  - name: ai
    source: ./private-services/ai
    compose_files: [docker-compose.yml]
```

Every Compose service should use `restart: unless-stopped` or `restart: always`.
Docker is enabled at boot, and the profile also generates a
`homeserver-compose-<project>.service` unit for each declared project. The
unit performs `docker compose up -d` after Docker becomes available, so the
application stack recovers after normal restarts and power restoration even
when a one-shot helper has no restart policy.

## Memory and SSD behavior

Linux uses spare RAM for file cache automatically. A server that reports a lot
of `buff/cache` and a large `available` value is already using abundant memory
well; forcing an artificial RAM disk usually reduces usable SSD space and adds
risk. For a high-memory system that should resist swapping active workloads,
enable the documented, conservative sysctl set:

```yaml
linux_server_memory_tuning_enabled: true
```

It sets `vm.swappiness=10`, preserves inode/dentry cache longer, raises
`vm.max_map_count` for search/index services, and increases the host file
descriptor ceiling. Review or override `linux_server_memory_sysctls` for a
database host with its own tuning guidance. Docker's local log driver caps
container logs at 30 MiB per container and the optional prune timer removes
only unused images, helping preserve SSD capacity without touching volumes.

## GPU and firewall

Enable GPU containers only after `nvidia-smi` succeeds on the host:

```yaml
linux_server_gpu_enabled: true
```

The UFW role is deliberately off by default. When exposing a reverse proxy,
enable it only after confirming SSH and the intended public ports:

```yaml
linux_server_firewall_enabled: true
linux_server_ssh_port: 22
linux_server_allowed_tcp_ports: [80, 443]
```

Cloudflared-only deployments generally need no inbound web ports at all.
