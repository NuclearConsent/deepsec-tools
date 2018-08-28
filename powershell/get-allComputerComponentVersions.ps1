<#
.SYNOPSIS
  PowerShell Script to create a CSV of all computers with component information

.NOTES
  Name: get-allComputerComponentVersions.ps1
  Instructions: Save and run script as ps1 file
                When prompted for manager, please input the IP/fqdn & port of manager (Example: 127.0.0.1:4119)

.LINK
  https://help.deepsecurity.trendmicro.com/10/0/rest-api.html
#>

param (
    [Parameter(Mandatory=$true)][string]$manager,
    [Parameter(Mandatory=$true)][string]$user,
    [Parameter(Mandatory=$false)][string]$tenant
)

$passwordinput = Read-host "Password for Deep Security Manager" -AsSecureString
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordinput))

[System.Net.ServicePointManager]::ServerCertificateValidationCallback={$true}
$Global:DSMSoapService = New-WebServiceProxy -uri "https://$manager/webservice/Manager?WSDL" -Namespace "DSSOAP" -ErrorAction Stop
$Global:DSM = New-Object DSSOAP.ManagerService
$Global:SID
try {
    if (!$tenant) {
        $Global:SID = $DSM.authenticate($user, $password)
        }
    else {
        $Global:SID = $DSM.authenticateTenant($tenant, $user, $password)
        }
}
catch {
    echo "An error occurred during authentication. Verify username and password and try again. `nError returned was: $($_.Exception.Message)"
    exit
}

$obj = new-object DSSOAP.HostFilterTransport
$obj.type = [DSSOAP.EnumHostFilterType]::ALL_HOSTS
echo "Retrieving data..."
$detail = $DSM.hostDetailRetrieve($obj, [DSSOAP.EnumHostDetailLevel]::LOW, $SID) 
echo "Saving data to csv file..."
$detail | Select-Object ID, name, antiMalwareClassicPatternVersion,antiMalwareEngineVersion, antiMalwareIntelliTrapExceptionVersion, antiMalwareSmartScanPatternVersion, antiMalwareSpywarePatternVersion, overallVersion, overallStatus, platform, lastIPUsed, Hostname, description, securityProfileName | Export-Csv -Path 'C:\patternversion.csv' -NoTypeInformation
echo "Report saved to C:\"

$DSM.endSession($SID)