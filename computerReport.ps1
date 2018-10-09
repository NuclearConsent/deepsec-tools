<#
.SYNOPSIS
PowerShell Script to query computers and save output to csv
.LINK
http://success.trendmicro.com
.EXAMPLE
.\computerReport.ps1 -managerIp 127.0.0.1 -managerPort 4119 -user api -password NoVirus -tenant "Trend Micro"
#>

param (
    [Parameter(Mandatory=$true)][string]$managerIp,
    [Parameter(Mandatory=$true)][string]$managerPort,
    [Parameter(Mandatory=$true)][string]$user,
    [Parameter(Mandatory=$false)][string]$password,
    [Parameter(Mandatory=$false)][string]$tenant
)

# Variables
$outputfilepath = "C:\deepsecurity"
$date = Get-Date -UFormat "%m_%d_%Y"
$stamp = (Get-Date).toString("HH:mm:ss yyyy/MM/dd")
$manager = "${managerIp}:$managerPort"
$file = "C:\DeepSecurity\ComputerReport_$date.csv"
$log = "C:\DeepSecurity\Log\error.log"
$versionMinimum = '4'

# Function to write logs
Function LogWrite {
  Param ([string]$logstring)
  Add-content $log -value "${stamp}: $logstring"
}

# Make sure working directory exists
if(!(Test-Path "C:\deepsecurity\log" )){
    New-Item -ItemType directory -Path "C:\DeepSecurity\Log"
}

# Make sure powershell version is correct
if ($versionMinimum -gt $PSVersionTable.PSVersion) {
  LogWrite "Failed to run. This script requires PowerShell $versionMinimum"
  throw "This script requires PowerShell $versionMinimum"
}

# Prompt for password if one was not provided
if (!$password) {
  $passwordinput = Read-host "Password for Deep Security Manager" -AsSecureString
  $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordinput))
}

# Make sure we can connect to Manager
try {
  $test = New-Object System.Net.Sockets.TCPClient -ArgumentList $managerIp,$managerPort;
}
catch {
  LogWrite "Unable to connect to manager - $manager"
  throw "Unable to connect to manager - $manager"
}

# Create soap object
[System.Net.ServicePointManager]::ServerCertificateValidationCallback={$true}
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
$DSMSoapService = New-WebServiceProxy -uri "https://$manager/webservice/Manager?WSDL" -Namespace "DSSOAP" -ErrorAction Stop
$DSM = New-Object DSSOAP.ManagerService
$SID

# Authenticate to the DSM
try {
  if (!$tenant) {
       $SID = $DSM.authenticate($user, $password)
   }
   else {
       $SID = $DSM.authenticateTenant($tenant, $user, $password)
   }
}
catch {
   LogWrite "An error occurred during authentication. Verify username and password and try again. `nError returned was: $($_.Exception.Message)"
   throw "An error occurred during authentication. Verify username and password and try again. `nError returned was: $($_.Exception.Message)"
}

# Logic to make sure there is only one file
if (Test-Path $file) {
  LogWrite "Report Already Exists - $file"
}
else {
  # Query all the groups
  $groups = $DSM.hostGroupRetrieveAll($SID);
  # Loop through all groups
  foreach ($a in $groups) {
    # Create an object
    $HFT = New-Object DSSOAP.HostFilterTransport
    $HFT.type = [DSSOAP.EnumHostFilterType]::HOSTS_IN_GROUP
    $HFT.hostGroupID = $a.id
    # Retrieve specific information from the object
    $cRetrieve = $DSM.hostDetailRetrieve($HFT, [DSSOAP.EnumHostDetailLevel]::HIGH, $SID) | Select-Object name, lastIPUsed, overallVersion, platform, overallDpiStatus
    # Write to file
    $cRetrieve | Export-Csv -Path $file -Append -NoTypeInformation
  }
}
# End the session
$DSM.endSession($SID)
