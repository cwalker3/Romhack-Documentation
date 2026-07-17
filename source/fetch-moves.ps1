# Regenerates move_desc.tsv (ORAS move descriptions) + refreshes moves.csv / type_names.csv from PokeAPI.
# The committed files already contain this; run only to refresh. Downloads a ~5MB flavor-text file.
# Run:  powershell -ExecutionPolicy Bypass -File fetch-moves.ps1
$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'
$dir=$PSScriptRoot
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/PokeAPI/pokeapi/master/data/v2/csv/moves.csv' -UseBasicParsing -OutFile "$dir\moves.csv"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/PokeAPI/pokeapi/master/data/v2/csv/type_names.csv' -UseBasicParsing -OutFile "$dir\type_names.csv"
$tmp=Join-Path $env:TEMP 'move_flavor_text.csv'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/PokeAPI/pokeapi/master/data/v2/csv/move_flavor_text.csv' -UseBasicParsing -OutFile $tmp
# prefer ORAS (version group 16) English text, fall back to X/Y (15)
$fl=@{}
Import-Csv $tmp | Where-Object { $_.language_id -eq '9' -and ($_.version_group_id -eq '16' -or $_.version_group_id -eq '15') } | ForEach-Object {
  $mid=[int]$_.move_id
  $txt=($_.flavor_text -replace '[\r\n\f\t]',' ' -replace '\s+',' ').Trim()
  if($_.version_group_id -eq '16'){ $fl[$mid]=$txt } elseif(-not $fl.ContainsKey($mid)){ $fl[$mid]=$txt }
}
$sb=New-Object System.Text.StringBuilder
foreach($k in ($fl.Keys | Sort-Object)){ [void]$sb.AppendLine(("{0}`t{1}" -f $k,$fl[$k])) }
[System.IO.File]::WriteAllText("$dir\move_desc.tsv",$sb.ToString(),(New-Object System.Text.UTF8Encoding($false)))
"Wrote move_desc.tsv ($($fl.Count) moves)"
Remove-Item $tmp -ErrorAction SilentlyContinue
