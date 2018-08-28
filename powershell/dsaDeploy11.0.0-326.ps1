<#
 
.SYNOPSIS
PowerShell Script to download and install Deep Security Agent version 11.0.0-326
 
.LINK
https://files.trendmicro.com/products/deepsecurity/en/11.0/DS_Agent-Windows_11.0_U1_readme.txt
 
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
# Log data available here: $env:appdata\Trend Micro\Deep Security Agent\installer\dsa_deploy.log
$env:LogPath = "$env:appdata\Trend Micro\Deep Security Agent\installer"
New-Item -path $env:LogPath -type directory
Start-Transcript -path "$env:LogPath\dsa_deploy.log" -append
echo "$(Get-Date -format T) - DSA download started"
# Download Agent-Core-Windows-11.0.0-326.x86_64.msi
(New-Object System.Net.WebClient).DownloadFile("https://relay.deepsecurity.trendmicro.com/dsa/Windows.x86_64/Agent-Core-Windows-11.0.0-326.x86_64.msi", "$env:temp\agent.msi")
echo "$(Get-Date -format T) - Downloaded File Size:" (Get-Item "$env:temp\agent.msi").length
echo "$(Get-Date -format T) - DSA install started"
# Install Agent-Core-Windows-11.0.0-326.x86_64.msi
echo "$(Get-Date -format T) - Installer Exit Code:" (Start-Process -FilePath msiexec -ArgumentList "/i $env:temp\agent.msi /qn ADDLOCAL=ALL /l*v `"$env:LogPath\dsa_install.log`"" -Wait -PassThru).ExitCode

Stop-Transcript
echo "$(Get-Date -format T) - DSA Deployment Finished"