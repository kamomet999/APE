$pids = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess | Sort-Object -Unique
foreach ($processId in $pids) {
  try {
    Stop-Process -Id $processId -Force -ErrorAction Stop
    Write-Host "Killed PID $processId"
  } catch {
    Write-Host "Failed to kill PID ${processId}: $($_.Exception.Message)"
  }
}
if (-not $pids) { Write-Host "No process on port 3000" }
