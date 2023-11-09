Param($PreferredSite)
# Get the first ProviderLocation object
$ProviderLocations = Get-CimInstance -Namespace 'Root\SMS' -ClassName 'SMS_ProviderLocation'
$SelectedSite = $null 

if ($PreferredSite) {
    $SelectedSite = $ProviderLocations | Where-Object { $_.SiteCode -eq $PreferredSite }
}

if ($SelectedSite -eq $null) {
    $SelectedSite = $ProviderLocations | select -First 1
}

$SiteCode = $SelectedSite.SiteCode
$ProviderMachineName = $SelectedSite.Machine

Write-Host "Loading Configuration Manager modules for ($SiteCode) connected to ($ProviderMachineName)..." -NoNewline

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" 

Write-Host 
Write-Host 