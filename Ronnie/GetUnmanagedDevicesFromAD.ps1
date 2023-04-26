<#  
.SYNOPSIS  
    Identify unmanaged devices in Active Directory 
.DESCRIPTION  
    Any device that is in Active Directory but is not a client in ConfigMgr is unmanaged and should be managed
.NOTES  
    File Name  : GetUnmanagedDevicesFromAD.ps1  
    Author     : Ronnie Jakobsen - rja@ctglobalservices.com
    Requires   : PowerShell v5
.LINK  
    https://github.com/ViaMonstra/powershelljourney
#>

Import-Module Join-Object
Import-Module ImportExcel

# Get list of client devices in Active Directory
$ADDevices = Get-ADComputer -SearchBase $ClientsOUName -SearchScope Subtree -Filter * -Properties 'LastLogonDate','PasswordLastSet'

# Get list of client devices in ConfigMgr
$ConfigMgrDevices = Get-CimInstance -Namespace 'ROOT\SMS\Site_PRI' -ClassName 'SMS_R_System'
$WorkstationStatus = Get-CimInstance -Namespace 'ROOT\SMS\Site_PRI' -ClassName 'SMS_G_System_WORKSTATION_STATUS'

# Join the two datasets from ConfigMgr
$ConfigMgrDevicesWithWorkstationStatus = Join-Object -Left $ConfigMgrDevices -Right $WorkstationStatus -LeftJoinProperty 'ResourceID' -RightJoinProperty 'ResourceID' -RightProperties 'LastHardwareScan'

# Match the devices from ConfigMgr with the devices in Active Directory
$MatchedDevices = Join-Object -Left $ADDevices -Right $ConfigMgrDevicesWithWorkstationStatus -LeftJoinProperty 'SID' -RightJoinProperty 'SID' -RightProperties 'ResourceID', 'LastHardwareScan'

# List devices that are not in ConfigMgr, aka they are not managed
$NotInConfigMgr = $MatchedDevices | Where-Object { $_.ResourceID -eq $null }
$NotInConfigMgr | Select-Object -Property Name,DNSHostName,SID | Sort-Object -Property Name | Format-Table

#$NotInConfigMgr | Select-Object -Property Name,DNSHostName,SID | Sort-Object -Property Name | Export-Excel '\\nas01\source\UnmanagedDeviceFromAD.xlsx' -TableName 'UnmanagedDevicesFromAD' -AutoSize