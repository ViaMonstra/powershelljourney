$SiteServer= "CM01"
$DatabaseServer= "CM01"
$Database = "CM_PS1"

$ts = $(get-date -f MMddyyyy_hhmmss)
$ExportPath = "\\CM01\HealthCheck$\Results\TaskSequenceDeploymentTimes_$ts.csv"
# Query for all Windows 10 21H2 task sequence deployments the last 30 days
$TaskSequenceName = "Windows 10 Enterprise x64 21H2 MDM BranchCache"
$NumberOfDays = 30
$DeploymentTimeQuery = $("
Select Distinct v_R_System.Name0 as ComputerName ,
v_TaskExecutionStatus.ResourceID,
MIN(V_TaskExecutionStatus.ExecutionTime) as 'StartTime', 
MAX(v_TaskExecutionStatus.ExecutionTime) as 'EndTime', 
DATEDIFF(MINUTE, MIN(V_TaskExecutionSTatus.ExecutionTime) , 
MAX(V_TaskExecutionSTatus.ExecutionTime)) as 'DeploymentTimeInMinutes', 
V_Package.Name as TaskSequence,
v_Network_DATA_Serialized.IPAddress0 as IPAddress
from v_TaskExecutionStatus 
left outer join v_R_System on v_TaskExecutionStatus.ResourceID = v_R_System.ResourceID 
left Join v_AdvertisementInfo on v_AdvertisementInfo.AdvertisementID = v_TaskExecutionStatus.AdvertisementID 
Left join v_Package on v_Package.PackageID = v_AdvertisementInfo.PackageID 
left outer join v_Advertisement on v_TaskExecutionStatus.AdvertisementID = v_Advertisement.AdvertisementID 
left outer join v_TaskSequencePackage on v_Advertisement.PackageID = v_TaskSequencePackage.PackageID 
left outer join v_Network_DATA_Serialized on v_TaskExecutionStatus.ResourceID = v_Network_DATA_Serialized.ResourceID
where v_TaskSequencePackage.BootImageID is not NULL 
and V_Package.Name = '$TaskSequenceName'
and v_TaskExecutionStatus.ExecutionTime >= CURRENT_TIMESTAMP -$NumberOfDays 
and v_Network_DATA_Serialized.IPAddress0 is not null
and v_Network_DATA_Serialized.IPAddress0 not like '%:%'
Group By v_R_System.Name0,v_TaskExecutionStatus.ResourceID,v_Package.Name,v_Network_DATA_Serialized.IPAddress0 order by V_r_system.Name0
")

# Run Deployment Time SQL Query
$DeploymentTimeDT = New-Object System.Data.DataTable
$Connection = New-Object System.Data.SQLClient.SQLConnection
$Connection.ConnectionString = "server='$DatabaseServer';database='$Database';trusted_connection=true;"
$Connection.Open()
$Command = New-Object System.Data.SQLClient.SQLCommand
$Command.Connection = $Connection
$Command.CommandText = $DeploymentTimeQuery
$Reader = $Command.ExecuteReader()
$DeploymentTimeDT.Load($Reader)
$Connection.Close()

# Query for all status messages the last 30 days with certain operating system deployment actions(Start Time, Partition Disk, Apply Operating System, and Finish Time)
$AllStatusMessagesQuery = $("
Select ResourceID, ActionName, ExecutionTime from v_TaskExecutionStatus 
Where v_TaskExecutionStatus.ExecutionTime >= CURRENT_TIMESTAMP -30 
and v_TaskExecutionStatus.ActionName like '%Start Time%'
or v_TaskExecutionStatus.ActionName like '%Partition Disk%'
or v_TaskExecutionStatus.ActionName like '%Operating System%'
or v_TaskExecutionStatus.ActionName like '%Finish Time%'
")

# Run Deployment Time SQL Query
$AllStatusMessagesDT = New-Object System.Data.DataTable
$Connection = New-Object System.Data.SQLClient.SQLConnection
$Connection.ConnectionString = "server='$DatabaseServer';database='$Database';trusted_connection=true;"
$Connection.Open()
$Command = New-Object System.Data.SQLClient.SQLCommand
$Command.Connection = $Connection
$Command.CommandText = $AllStatusMessagesQuery
$Reader = $Command.ExecuteReader()
$AllStatusMessagesDT.Load($Reader)
$Connection.Close()


# Get the data and build a new arraylist
[System.Collections.ArrayList]$DeploymentTime = @()
Foreach ($Row in $DeploymentTimeDT){

    # Get only Task Sequences with certain operating system deployment actions completed (Partition Disk, Apply Operating System, and Finish Time)
    $AllActions = $AllStatusMessagesDT | Where-Object { $_.ResourceID -eq $Row.ResourceID }

    # Only list machines that have all actions completed
    If ($AllActions){

        # Further filtering by only listing deployments with six actions reported
        $AllActionsCount = ($AllActions | Measure-Object).Count
       
        If ($AllActionsCount -eq 4){

            foreach($Action in $AllActions){
                Write-Host "Computer: $($row.ComputerName), Action: $($Action.ActionName), StartTime: $($Action.ExecutionTime)"
            }

            $obj = [PSCustomObject]@{

                # Add values to arraylist
                ComputerName = $row.ComputerName
                DeploymentTimeInMinutes = $row.DeploymentTimeInMinutes
            }

            # Add all the values
            $DeploymentTime.Add($obj)|Out-Null
        }
        Else{
            Write-Warning "Computer: $($row.ComputerName) had $AllActionsCount actions"
            foreach($Action in $AllActions){
                Write-Warning "Computer: $($row.ComputerName), Action: $($Action.ActionName), StartTime: $($Action.ExecutionTime)"
            }
            #Break
        }
    }
       
}

Set-Location C:
$DeploymentTime | Export-Csv -Path $ExportPath -NoTypeInformation
 




