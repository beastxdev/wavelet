$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$lavalinkDir = Join-Path $root "lavalink"
$backendDir = Join-Path $root "backend"
$cloudflared = Join-Path $PSScriptRoot "cloudflared.exe"
$logFile = Join-Path $PSScriptRoot "cloudflared.log"

if (-not (Test-Path $cloudflared)) {
  throw "cloudflared.exe was not found at $cloudflared"
}

if (-not (Get-Process java -ErrorAction SilentlyContinue)) {
  Start-Process -FilePath "java" -ArgumentList "-jar", "Lavalink.jar" -WorkingDirectory $lavalinkDir -WindowStyle Hidden
  Start-Sleep -Seconds 8
}

try {
  Invoke-RestMethod -Uri "http://localhost:3000/api/health" -TimeoutSec 3 | Out-Null
} catch {
  Start-Process -FilePath "node" -ArgumentList "server.js" -WorkingDirectory $backendDir -WindowStyle Hidden
  Start-Sleep -Seconds 3
}

if (Test-Path $logFile) {
  Remove-Item -LiteralPath $logFile -Force
}

Write-Host ""
Write-Host "Wavelet public tunnel is starting."
Write-Host "When Cloudflare prints a trycloudflare.com URL, use it in the app as:"
Write-Host "  https://YOUR-TUNNEL.trycloudflare.com/api"
Write-Host ""
Write-Host "Keep this window open while using the app on mobile data."
Write-Host ""

& $cloudflared tunnel --url "http://localhost:3000" --logfile $logFile --loglevel info
