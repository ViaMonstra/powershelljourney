<#  
.SYNOPSIS  
    Identify stale devices in Active Directory 
.DESCRIPTION  
    Any device that has not logged in or changed its password in Active Directory in 30 days are considered stale
.NOTES  
    File Name  : GetStaleDevicesFromAD.ps1  
    Author     : Ronnie Jakobsen - rja@ctglobalservices.com
    Requires   : PowerShell v5
.LINK  
    https://github.com/ViaMonstra/powershelljourney
#>

#Import-Module ImportExcel

$MaximumAgeInDays = 30

# Get list of client devices in Active Directory
$ADDevices = Get-ADComputer -SearchBase $ClientsOUName -SearchScope Subtree -Filter * -Properties 'LastLogonDate','PasswordLastSet'

# List devices that are too "old" (what is too old?)
$StaleDate = (Get-Date).AddDays(-$MaximumAgeInDays)
$OldDevices = $ADDevices | Where-Object { $_.PasswordLastSet -le $StaleDate -and $_.LastLogonDate -le $StaleDate }
$OldDevices | Select-Object -Property Name,DNSHostName,SID,LastLogonDate,PasswordLastSet | Sort-Object -Property Name | Format-Table

# $OldDevices | Select-Object -Property Name,DNSHostName,SID,LastLogonDate,PasswordLastSet | Sort-Object -Property Name | Export-Excel '\\nas01\source\StaleDevicesFromAD.xlsx' -TableName 'StaleDevicesFromAD' -AutoSize
