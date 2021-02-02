<#
 
.SYNOPSIS
PowerShell Script to test Anti-Malware scanning with an Eicar file
 
.NOTES
This script is provided as-is and is not supported by author or Trend Micro

.LINK
https://trendmicro.com/
 
#>

$base1 = 'WDVPIVAlQEFQWzRcUFpYNTQoUF4pN0NDKTd9JEVJQ0FS'
$base2 = 'LVNUQU5EQVJELUFOVElWSVJVUy1URVNULUZJTEUhJEgrSCo='
$eicar = -join($base1, $base2)
$filename = 'C:\test2.txt'

# Enable debugging
Write-Host "Debugging Enabled"
& $Env:ProgramFiles"\Trend Micro\Deep Security Agent\sendCommand" --get Trace trace+=AM,AMSP,dsp.am.*

# Sleep
Start-Sleep -s 50

# Create eicar
Write-Host "Creating Eicar"
$bytes = [Convert]::FromBase64String($eicar)
[IO.File]::WriteAllBytes($filename, $bytes)

# Another Sleep
Start-Sleep -s 50

# Create diagnostic package if eicar is still on system
if (Test-Path $filename) {
  Write-Host "Eicar found; Creating diagnostic package"
  & $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -d
}
else {
  Write-Host "Eicar not found"
}

# Disable debugging
Write-Host "Debugging Disabled"
& $Env:ProgramFiles"\Trend Micro\Deep Security Agent\sendCommand" --get Trace trace-=AM,AMSP,dsp.am.*
