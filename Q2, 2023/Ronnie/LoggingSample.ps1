<#  
.SYNOPSIS  
    Show how to create powerful logging using a module
.DESCRIPTION  
    Logging to a number of sources using a simple module
.NOTES  
    File Name  : LoggingSample.ps1  
    Author     : Ronnie Jakobsen - rja@ctglobalservices.com
    Requires   : PowerShell v5
.LINK  
    https://github.com/ViaMonstra/powershelljourney
#>

#install-module logging -Force

Import-Module Logging

Set-LoggingDefaultLevel -Level INFO

Add-LoggingTarget -Name Console -Configuration @{Level = 'WARNING'; Format = "[%{level:-7}] %{message}" }
Add-LoggingTarget -Name File -Configuration @{ Path = 'e:\temp\sample.log' }
#Add-LoggingTarget -Name WinEventLog -Configuration @{Level = 'ERROR'; LogName='Application'; Source='MyPowerShellScript' }

$Level = 'DEBUG', 'INFO', 'WARNING', 'ERROR'

Foreach ($i IN 1..100) {

    Write-Log -Level ($Level | Get-Random) -Message "Testing logging, message #$i"

    Start-Sleep -Milliseconds (Get-Random -Minimum 10 -Maximum 400)

}

Wait-Logging
