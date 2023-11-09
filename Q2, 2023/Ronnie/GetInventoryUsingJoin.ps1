<#  
.SYNOPSIS  
    Join lists of data from ConfigMgr to form dataset for report
.DESCRIPTION  
    Uses the module Join-Object to merge data sets together
.NOTES  
    File Name  : GetInventoryUsingJoin.ps1  
    Author     : Ronnie Jakobsen - rja@ctglobalservices.com
    Requires   : PowerShell v5
.LINK  
    https://github.com/ViaMonstra/powershelljourney
#>

$ns = 'Root\sms\site_pri'

$devices = Get-CimInstance -Namespace $ns -ClassName 'SMS_R_System' | Where-Object { $_.Name -ne 'Unknown' -and $_.Client -eq 1 } | Sort-Object -Property Name

$computerSystem = Get-CimInstance -Namespace $ns -ClassName 'SMS_G_System_Computer_System' 
$operatingSystem = Get-CimInstance -Namespace $ns -ClassName 'SMS_G_System_Operating_System' 

$result = Join-Object -Left $devices -Right $computerSystem -LeftJoinProperty ResourceID -RightJoinProperty ResourceID -LeftProperties ResourceID, Name -RightProperties Manufacturer, Model
$result = Join-Object -Left $result -Right $operatingSystem -LeftJoinProperty ResourceID -RightJoinProperty ResourceID -RightProperties Caption, BuildNumber

$result