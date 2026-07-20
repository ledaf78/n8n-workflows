#!/bin/bash

# ============================================
# Script: remove_prometheus_target.sh
# Usage : ./remove_prometheus_target.sh <IP>
# Example: ./remove_prometheus_target.sh 10.50.0.4
# ============================================

TARGET_IP=$1
CONFIG_FILE="/home/infra/dcim-automation/docker/monitoring/prometheus.yml"
BACKUP_FILE="/home/infra/dcim-automation/docker/monitoring/prometheus.yml.backup.$(date +%Y%m%d_%H%M%S)"

# ── Validasi input ──────────────────────────
if [ -z "$TARGET_IP" ]; then
  echo "❌ ERROR: IP address harus diisi!"
  echo "   Usage: $0 <IP_ADDRESS>"
  exit 1
fi

# ── Cek file exists ─────────────────────────
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ ERROR: File tidak ditemukan: $CONFIG_FILE"
  exit 1
fi

# ── Backup dulu ─────────────────────────────
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "✅ Backup dibuat: $BACKUP_FILE"

# ── Cek apakah IP ada di file ───────────────
if ! grep -q "$TARGET_IP" "$CONFIG_FILE"; then
  echo "⚠️  WARNING: IP $TARGET_IP tidak ditemukan di $CONFIG_FILE"
  exit 0
fi

# ── Hapus job menggunakan Python ────────────
python3 - <<EOF
import yaml
import sys

config_path = "$CONFIG_FILE"
target_ip   = "$TARGET_IP"

with open(config_path, 'r') as f:
    config = yaml.safe_load(f)

original_count = len(config['scrape_configs'])
original_jobs  = [job['job_name'] for job in config['scrape_configs']]

# Filter out job yang mengandung IP
config['scrape_configs'] = [
    job for job in config['scrape_configs']
    if not any(
        target_ip in str(t)
        for sc in job.get('static_configs', [])
        for t in sc.get('targets', [])
    )
]

removed_count = original_count - len(config['scrape_configs'])
remaining_jobs = [job['job_name'] for job in config['scrape_configs']]
removed_jobs   = list(set(original_jobs) - set(remaining_jobs))

if removed_count == 0:
    print(f"⚠️  WARNING: Tidak ada job yang dihapus untuk IP {target_ip}")
    sys.exit(0)

with open(config_path, 'w') as f:
    yaml.dump(config, f, default_flow_style=False, allow_unicode=True)

print(f"✅ SUCCESS: {removed_count} job dihapus")
print(f"   Job dihapus : {', '.join(removed_jobs)}")
print(f"   Sisa job    : {len(remaining_jobs)}")
EOF

# Cek apakah Python berhasil
if [ $? -ne 0 ]; then
  echo "❌ ERROR: Python script gagal, restore backup..."
  cp "$BACKUP_FILE" "$CONFIG_FILE"
  echo "✅ File dikembalikan dari backup"
  exit 1
fi

# ── Reload Prometheus ────────────────────────
echo ""
echo "🔄 Reloading Prometheus..."

PROMETHEUS_CONTAINER=$(docker ps --filter "name=prometheus" --format "{{.Names}}" | head -1)

if [ -z "$PROMETHEUS_CONTAINER" ]; then
  echo "⚠️  WARNING: Container Prometheus tidak ditemukan!"
  echo "   Reload manual: docker kill --signal=SIGHUP <nama_container>"
  exit 0
fi

docker kill --signal=SIGHUP "$PROMETHEUS_CONTAINER"

if [ $? -eq 0 ]; then
  echo "✅ Prometheus berhasil di-reload (container: $PROMETHEUS_CONTAINER)"
else
  echo "❌ Reload gagal, coba manual:"
  echo "   docker kill --signal=SIGHUP $PROMETHEUS_CONTAINER"
fi

echo ""
echo "🎉 Selesai! Target $TARGET_IP telah dihapus dari Prometheus"
