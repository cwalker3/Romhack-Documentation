# Downloads the gym-badge artwork from Bulbapedia, downscales each to 48x48, and embeds
# them (base64) into ../../docs/badge-sprites.js as window.RRSS_BADGES = { <key>: <b64> }.
# Keys match gymBadgeKey() in docs/app.js. Run:
#   powershell -ExecutionPolicy Bypass -File fetch-badge-sprites.ps1
$ErrorActionPreference = 'Stop'
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Drawing
$docs = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'docs'

# badge key -> Bulbapedia file title (all are "<Name> Badge.png")
$badges = [ordered]@{
  # Kanto
  boulder='Boulder'; cascade='Cascade'; thunder='Thunder'; rainbow='Rainbow';
  soul='Soul'; marsh='Marsh'; volcano='Volcano'; earth='Earth';
  # Hoenn
  stone='Stone'; knuckle='Knuckle'; dynamo='Dynamo'; heat='Heat';
  balance='Balance'; feather='Feather'; mind='Mind'; rain='Rain';
  # Unova
  trio='Trio'; basic='Basic'; insect='Insect'; bolt='Bolt';
  quake='Quake'; jet='Jet'; freeze='Freeze'; legend='Legend'
}

function Get-Badge($name){
  $fn = "$name Badge.png"
  $u = 'https://archives.bulbagarden.net/w/index.php?title=Special:FilePath/' + [uri]::EscapeDataString($fn)
  $r = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 30
  $bytes = $r.Content; if ($bytes -is [string]) { $bytes = [Text.Encoding]::Default.GetBytes($bytes) }
  $ms = New-Object System.IO.MemoryStream (,$bytes)
  $img = [System.Drawing.Image]::FromStream($ms)
  $bmp = New-Object System.Drawing.Bitmap 48, 48
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode  = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.Clear([System.Drawing.Color]::Transparent)
  $g.DrawImage($img, 0, 0, 48, 48)
  $out = New-Object System.IO.MemoryStream
  $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose(); $img.Dispose(); $ms.Dispose()
  return [Convert]::ToBase64String($out.ToArray())
}

$result = New-Object System.Collections.Specialized.OrderedDictionary
$ok = 0; $miss = New-Object System.Collections.ArrayList
foreach ($k in $badges.Keys) {
  try { $result[$k] = Get-Badge $badges[$k]; $ok++ }
  catch { [void]$miss.Add("$k ($($badges[$k]) Badge)"); Write-Warning "  $k -> $($_.Exception.Message)" }
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.Append('window.RRSS_BADGES=')
[void]$sb.Append(($result | ConvertTo-Json -Compress))
[void]$sb.Append(';')
$outFile = Join-Path $docs 'badge-sprites.js'
[System.IO.File]::WriteAllText($outFile, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
"Wrote {0} ({1:N0} bytes)" -f $outFile, ((Get-Item $outFile).Length)
"Badges: {0} matched, {1} unmatched" -f $ok, $miss.Count
if ($miss.Count) { "Unmatched: " + ($miss -join ', ') }
