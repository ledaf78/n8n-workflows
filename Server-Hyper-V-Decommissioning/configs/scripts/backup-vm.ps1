param(
    [Parameter(Mandatory=$true)]
    [string]$VMName
)

# ── Konfigurasi ──────────────────────────────
$BackupRoot = "C:\backup-vm"
$DateStamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupPath = "$BackupRoot\$VMName\$DateStamp"
$LogDir     = "C:\script\logs"
$LogFile    = "$LogDir\backup_${VMName}_${DateStamp}.log"
$MaxBackups = 5

# ── Buat folder ──────────────────────────────
foreach ($dir in @($LogDir, $BackupPath)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Message"
    Write-Output $line
    Add-Content -Path $LogFile -Value $line
}

Write-Log "START Backup VM: $VMName"
Write-Log "Destination: $BackupPath"

# ── Cek VM exists ────────────────────────────
$VM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $VM) {
    Write-Log "ERROR: VM $VMName tidak ditemukan"
    exit 1
}

Write-Log "VM Status: $($VM.State)"

# ── Export VM ke Local ───────────────────────
try {
    Write-Log "Memulai export VM..."
    Export-VM -Name $VMName -Path $BackupPath -ErrorAction Stop
    Write-Log "SUCCESS: Export selesai → $BackupPath"
} catch {
    Write-Log "ERROR: Export gagal - $_"
    exit 1
}

# ── Hapus backup lama (retain MaxBackups) ────
Write-Log "Membersihkan backup lama (retain: $MaxBackups)..."
$OldBackups = Get-ChildItem "$BackupRoot\$VMName" |
    Sort-Object CreationTime -Descending |
    Select-Object -Skip $MaxBackups

foreach ($old in $OldBackups) {
    Remove-Item $old.FullName -Recurse -Force
    Write-Log "Deleted old backup: $($old.Name)"
}

Write-Log "DONE: Backup VM $VMName selesai"
exit 0