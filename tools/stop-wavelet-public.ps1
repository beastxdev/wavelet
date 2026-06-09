$processNames = @("cloudflared", "node", "java")

foreach ($name in $processNames) {
  Get-Process $name -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Stopping $($_.ProcessName) PID $($_.Id)"
    Stop-Process -Id $_.Id -Force
  }
}
