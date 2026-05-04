try {
  $r = Invoke-WebRequest -Uri 'http://localhost:3000/login' -MaximumRedirection 0 -UseBasicParsing -ErrorAction Stop
  Write-Host "Status: $($r.StatusCode)"
} catch {
  $resp = $_.Exception.Response
  if ($resp) {
    Write-Host "Status: $([int]$resp.StatusCode)"
    Write-Host "Location: $($resp.Headers['Location'])"
  } else {
    Write-Host "Error: $($_.Exception.Message)"
  }
}
