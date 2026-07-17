# Rebuilds ../docs/data.js from the .txt source documents.
# Run:  powershell -ExecutionPolicy Bypass -File build.ps1
$ErrorActionPreference = 'Stop'
$src  = $PSScriptRoot
$docs = Join-Path (Split-Path $src -Parent) 'docs'

& "$src\parse.ps1"    # .txt  -> data.json
& "$src\enrich.ps1"   # + base stats (Gen-6 corrected) + vanilla Ability 1

$data = [System.IO.File]::ReadAllText("$src\data.json", [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText((Join-Path $docs 'data.js'), ("window.RRSS_DATA=" + $data + ";"), (New-Object System.Text.UTF8Encoding($false)))
"Wrote {0}\data.js ({1:N0} bytes)" -f $docs, ((Get-Item (Join-Path $docs 'data.js')).Length)
