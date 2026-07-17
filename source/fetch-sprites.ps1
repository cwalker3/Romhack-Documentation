# Downloads all 721 Pokemon sprites from PokeAPI and writes ../docs/sprites.js.
# Only needed if sprites must be refreshed; the committed docs/sprites.js already contains them.
# Run:  powershell -ExecutionPolicy Bypass -File fetch-sprites.ps1
$ErrorActionPreference = 'Stop'
$docs = Join-Path (Split-Path $PSScriptRoot -Parent) 'docs'
Add-Type -AssemblyName System.Net.Http
$client = New-Object System.Net.Http.HttpClient
$client.Timeout = [TimeSpan]::FromSeconds(20)
$base = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/'
$map = [ordered]@{}
$fail = New-Object System.Collections.ArrayList
foreach($id in 1..721){
  try { $map["$id"] = [Convert]::ToBase64String($client.GetByteArrayAsync("$base$id.png").GetAwaiter().GetResult()) }
  catch { [void]$fail.Add($id) }
}
$client.Dispose()
"downloaded {0}/721 (failed: {1})" -f $map.Count, ($fail -join ',')
$json = $map | ConvertTo-Json -Compress
[System.IO.File]::WriteAllText((Join-Path $docs 'sprites.js'), ("window.RRSS_SPR=" + $json + ";"), (New-Object System.Text.UTF8Encoding($false)))
"Wrote {0}\sprites.js" -f $docs
