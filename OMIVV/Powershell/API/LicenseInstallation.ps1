#########################################################################################################
#This script will install several licenses on OMIVV
#Username and password is to login to the share hosting the license files
#MUST have bearer token prior to running this script
#Path will follow this standard "\\\\hostname\\folder\\folder\\"
#Licenses will follow this standard "\\hostname\folder\folder\"
#Licenses is where the license files have been extracted to
#########################################################################################################

#IP address or FQDN of the OMIVV instance
$omivv = "<OMIVV Server>"

#Share Info
$type = "CIFS"
$licensespath = "\\<server>\<folder>\"


#Share Creds
$credential = Get-Credential -Message "<Domain>\<Username> Formatted credentials for CIFS Share"

#OMIVV Creds
$OMIAdminusername = "admin"
$OMIAdminpassword = "<password>"

# Generate Token with admin credentials for OMIVV. For use with setting/adding licenses.

# Generate the body for the Rest request. This will be converted to JSON after the object is generated
$Tokenbody = @{
    "apiUserCredential" = @{
        "username" = $OMIAdminusername
        "domain" = ""
        "password" = $OMIAdminpassword
    }
} | ConvertTo-Json

$TokenRest = @{
    Uri = "https://$omivv/Spectre/api/rest/v1/Services/AuthenticationService/login"
    Method = 'POST'
    Body = $Tokenbody
    HEADERS = @{
        'Content-Type' = 'application/json'
    }
}

$response = Invoke-RestMethod @TokenRest
$bearertoken = $response.accessToken
$bearertoken


foreach($license in (Get-ChildItem -Path $licensespath)){
    
    # Create the body for the Rest request. This will be converted to JSON after the object is generated.
    $Licensebody = @{
    "sharetype" = $type
    "path" = $license.FullName
    "credential" = @{
        "username" = ($credential.GetNetworkCredential().Username)
        "domain" = ($credential.GetNetworkCredential().Domain)
        "password" = ($credential.GetNetworkCredential().Password)
        }
    } | ConvertTo-Json

    $LicenseRest = @{
        Uri = "https://$omivv/Spectre/api/rest/v1/Services/LicenseService/Licenses"
        Method = 'POST'
        Body = $Licensebody
        HEADERS = @{
            'Authorization' = "Bearer $bearertoken"
            'Content-Type' = 'application/json'
        }
    }
    
    $response = $null
    Write-Host "Processing $($license.name)"
    $response = try { Invoke-WebRequest @LicenseRest } catch {$_}
    if ($response.ErrorDetails.Message) {Write-Error $response.ErrorDetails.Message}
    $response.StatusDescription
}