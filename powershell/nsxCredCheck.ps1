<#
.SYNOPSIS
PowerShell Script to check NSX Manager credentials
.LINK
https://github.com/devfailure
#>

param (
    [Parameter(Mandatory=$true, HelpMessage="NSX Username")][string]$username,
    [Parameter(Mandatory=$true, HelpMessage="NSX IP")][string]$nsxip
)
$passwordinput = Read-host "Password for Deep Security Manager" -AsSecureString
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordinput))
$BaseURL = "https://$nsxip/api/2.0/services/ssoconfig"
# Base64 encode the user:pass for basic auth
$Header = @{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username+":"+$password))}
$Type = "application/json"

# To ignore self signed certs
# https://bit.ly/2wr9rPq
add-type -TypeDefinition  @"
  using System.Net;
  using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
      ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
        return true;
      }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Try the GET request
Try {
  $response = Invoke-RestMethod -Uri $BaseURL -TimeoutSec 100 -Headers $Header -ContentType $TypeJSON
  # Write message if credentials are valid
  Write-Host "Status:  Credentials are valid"
}
Catch {
  # Write message if credentials are invalid
  Write-Host "Status Code:" $_.Exception.Response.StatusCode.value__
  Write-Host "Description:" $_.Exception.Response.StatusDescription
}
