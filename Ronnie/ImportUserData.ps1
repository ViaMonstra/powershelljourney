<#  
.SYNOPSIS  
    Read data from an Excel Spreadsheet
.DESCRIPTION  
    Uses the module Import-Excel to read structured data from Excel files, kinda like import-csv only smarter
.NOTES  
    File Name  : ImportUserData.ps1  
    Author     : Ronnie Jakobsen - rja@ctglobalservices.com
    Requires   : PowerShell v5
.LINK  
    https://github.com/ViaMonstra/powershelljourney
#>

Import-Module ImportExcel

$UserData = Import-Excel -Path '\\nas01.mb15.dk\source\Users.xlsx'

$UserData

