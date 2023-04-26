Import-Module Microsoft.Graph.Intune  
Connect-MSGraph -ForceInteractive

# Get all Windows Devices 
$Devices = Get-IntuneManagedDevice -Filter "contains(operatingsystem, 'Windows')" | Get-MSGraphAllPages

# Get all ViaMonstra Lab Machines from Device Category
$Devices = Get-IntuneManagedDevice -Filter "deviceCategoryDisplayName eq 'ViaMonstra Lab Machines'" 

# Get all Driver Update Pilot Machines
$Devices = Get-IntuneManagedDevice -Filter "deviceCategoryDisplayName eq 'ViaMonstra Lab Machines'" 


# Get Single Devices
$Devices = Get-IntuneManagedDevice -Filter "deviceName eq 'DA-INTUNE-001'" 

# Get Devices from wildcard name
$Devices = Get-IntuneManagedDevice -Filter "contains(deviceName, 'DA-INTUNE')"
$Devices = Get-IntuneManagedDevice -Filter "contains(deviceName, 'PC')"

# Show Device Name(s)
$Devices | Select-Object deviceName

# Show Device Count
($Devices | Measure-Object).Count

# Report Last Sync, and force sync on each Device
Foreach ($Device in $Devices)
{
    $DeviceID = $Device.managedDeviceId
    $DeviceName = $Device.deviceName
    $lastSyncDateTime = $Device.lastSyncDateTime

    Write-Host "Last Sync Time for $DeviceName was: $lastSyncDateTime"
    # Force Sync
    Invoke-IntuneManagedDeviceSyncDevice -managedDeviceId $DeviceID 
    Write-Host "Sending Sync request to $DeviceName having device id: $DeviceID" -ForegroundColor Yellow
    Write-Host ""
}


#
# Misc samples
#

# Get all devices
Get-IntuneManagedDevice | Get-MSGraphAllPages

# Get devices for a specific user
$Devices = Get-IntuneManagedDevice | Where-Object {$_.userDisplayName -eq "Johan Arwidmark"}
$Devices | Select-Object deviceName

# Get Devices from wildcard 
$Devices = Get-IntuneManagedDevice -Filter "contains(deviceName, '001')"
$Devices | Select-Object deviceName

# Get Devices from wildcard 
$Devices = Get-IntuneManagedDevice -Filter "contains(deviceName, 'DA-INTUNE')"
$Devices | Select-Object deviceName


# Get Single Device
$Devices = Get-IntuneManagedDevice -Filter "deviceName eq 'DA-INTUNE-001'"


# Update-IntuneManagedDevice -managedDeviceId $device.id -managedDeviceName "New management device name"
# Change-DeviceCategory.ps1: https://github.com/JayRHa/Intune-Scripts/blob/main/Change-DeviceCategory.ps1

# Group
# $GroupName = "ViaMonstra Lab Machines"
#Get-AADGroup | Where-Object {$_.DisplayName -eq $GroupName} | Get-AADGroupMember
#$Devices = Get-AADGroup | Where-Object {$_.DisplayName -eq 'ViaMonstra Lab Machines'} | Get-AADGroupMember

# Get all ViaMonstra Lab Machines from AAD Group
#$Devices = Get-AADGroup -Filter "DisplayName eq 'ViaMonstra Lab Machines'" | Get-AADGroupMember 
