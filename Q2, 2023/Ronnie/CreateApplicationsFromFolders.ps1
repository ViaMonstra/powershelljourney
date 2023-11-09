<#  
.SYNOPSIS  
    Create applications based on a folder structure
.DESCRIPTION  
    Locates all MSI files and build applications based on that
.NOTES  
    File Name  : CreateApplicationsFromFolders.ps1  
    Author     : Ronnie Jakobsen - rja@ctglobalservices.com
    Requires   : PowerShell v5
.LINK  
    https://github.com/ViaMonstra/powershelljourney
#>

. D:\scripts\loadsccm.ps1

$AppNamePrefix = "Viamonstra"
$CollectionName = 'Generally Available Software'
$Path = 'filesystem::\\nas01.mb15.dk\source\software\applications'
$DistributionPointGroupName = 'LAB OnPrem'

$ApplictionFolders = Get-ChildItem -Path $Path | Where-Object { $_.Name -notlike '@*' }

foreach ($folder in $ApplictionFolders) {

    $AppPath = Join-Path -Path $path -ChildPath $folder.Name
    $AppContentPath = Join-Path -Path $AppPath -ChildPath 'Content'
    $AppIconPath = Join-Path -Path $AppPath -ChildPath 'Icon'
    $AppName = $AppNamePrefix+' '+$folder.Name
    $MSIFile = Get-ChildItem -Path $AppContentPath | Where-Object { $_.Extension -eq '.msi' } | Select-Object -First 1 |Select-Object -ExpandProperty FullName
    $IconFile = Get-ChildItem -Path $AppIconPath | Where-Object { $_.Extension -eq '.png' } | Select-Object -First 1 |Select-Object -ExpandProperty FullName

    If ($MSIFile) {
        Write-Host $folder.Name -ForegroundColor Green

        Write-Host "Create application"
        $NewApp = New-CMApplication -Name $AppName 

        if ($IconFile) {
            Write-Host "Set icon"
            Set-CMApplication -Name $AppName -IconLocationFile $IconFile
        }

        Write-Host "Move application to correct folder"
        Move-CMObject -InputObject $NewApp -FolderPath 'Application\Viamonstra'

        Write-Host "Create DeploymentType"
        $NewDeploymentType = Add-CMMsiDeploymentType -ApplicationName $AppName -ContentLocation $MSIFile -DeploymentTypeName 'Install/Uninstall' -InstallationBehaviorType InstallForSystem -LogonRequirementType WhetherOrNotUserLoggedOn -UserInteractionMode Hidden -Force

        Write-Host "Distribute content"
        Start-CMContentDistribution -ApplicationName $AppName -DistributionPointGroupName $DistributionPointGroupName 

        Write-Host "Create deployment to collection"
        $NewDeployment = New-CMApplicationDeployment -Name $AppName -CollectionName $CollectionName -DeployAction Install -DeployPurpose Available

    } 

    Write-Host 

}

Write-Host "All done " -NoNewline
Write-Host "👍" -ForegroundColor Green
