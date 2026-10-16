# reset_database.ps1 — clear the WiseGuardAlertsWatch database.
#
# The app recreates the schema and re-seeds defaults on the next start:
#   - admin / admin@123 (default admin account)
#   - 5 default proxy locations, default radar config, guard state
#
# Usage:  powershell -ExecutionPolicy Bypass -File .\scripts\reset_database.ps1
#         (add -Force to delete without a backup)
param([switch]$Force)

$root = Split-Path -Parent $PSScriptRoot
$db = Join-Path $root 'MVCWiseGuardAlertsWatch\wiseguard.db'

if (-not (Test-Path $db)) {
    Write-Host "No database found at $db — nothing to clear."
    exit 0
}

if (-not $Force) {
    $bak = "$db.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
    try {
        Copy-Item $db $bak
        Write-Host "backup: $bak"
    } catch {
        Write-Host "Could not back up the database (is the app running?). Stop it first, then retry." -ForegroundColor Yellow
        exit 1
    }
}

try {
    Remove-Item "$db*" -Force   # wiseguard.db, wiseguard.db-wal, wiseguard.db-shm
} catch {
    Write-Host "Could not delete the database (is the app running?). Stop it first (Ctrl+C on 'dotnet run'), then retry." -ForegroundColor Yellow
    exit 1
}

Write-Host "cleared: $db"
Write-Host ""
Write-Host "Next start re-seeds defaults. Then log in with:"
Write-Host "    admin / admin@123"
Write-Host "Start with:"
Write-Host "    cd MVCWiseGuardAlertsWatch; dotnet run"
