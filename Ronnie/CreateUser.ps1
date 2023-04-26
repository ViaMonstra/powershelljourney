# Validate params
Param(
    [Parameter(Mandatory=$true, ParameterSetName='excel')]
    $Path,
    [Parameter(Mandatory=$true, ParameterSetName='details')]
    $Name,
    [Parameter(Mandatory=$true, ParameterSetName='details')]
    $Department,
    [Parameter(ParameterSetName='details')]
    $Manager
)

$entries = @{}
$emailSuffix = 'viamonstra.com'

If ($PSCmdlet.ParameterSetName -eq 'excel') {

    # Read from Excel Spreadsheet
    $entries = Import-Excel -Path $Path 

} else {

    # Create entry based on input params
    $entries += @{
        'Name' = $Name
        'Department' = $Department
        'Manager' = $Manager
    }
}

Foreach ($entry in $entries) {

    try {

        # Calculate names
        $UserName = ($entry.Name.ToLower() -split ' ' | ForEach-Object { $_.substring(0,1) }) -join ""
        $FirstName = $entry.Name -split ' ' | Select-Object -First 1
        $LastName =  $entry.Name -split ' ' | Select-Object -Last 1

        # Check if UserName already exists
        $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$UserName'" 
        if ($ExistingUser) {
            throw "User '$UserName' already exists"
        }

        # Generate email address
        $UserEmail = $UserName+'@'+$emailSuffix

        # Find OU
        $DepartmentOU = Get-ADOrganizationalUnit -Filter "name -like '$($entry.Department)'" -Properties "ManagedBy"
        if ($DepartmentOU -eq $null) {
            throw "Department OU: $($entry.Department) was not found"
        }

        # Find Department group
        $GroupName = $entry.Department
        $DepartmentGroup = Get-ADGroup -filter "name -like '$GroupName'"
        if ($DepartmentGroup -eq $null) {
            throw "Department Group: $($entry.Department) was not found"
        }

        # Assume no manager
        $ManagerUser = $null

        # If a manager name was given find that user
        if ($manager) {
            $ManagerUser = Get-ADUser -filter "name -like '$manager'"
        } else {
            $ManagerUser = $DepartmentOU.ManagedBy
        }

        # Generate super secret password
        $Password = ConvertTo-SecureString -String "MySecret$tandardPassw0rd!" -AsPlainText -Force

        # Get the OU where we will place the new user
        $UsersOU = Get-ADOrganizationalUnit -Filter 'name -like "users"'

        $NewUser = New-ADUser -Name $entry.Name -GivenName $FirstName -Surname $LastName -SamAccountName $UserName -EmailAddress $UserEmail -Manager $ManagerUser -Path $UsersOU.DistinguishedName -AccountPassword $Password -PassThru 

        # Add to Department Group
        Add-ADGroupMember -Identity $GroupName -Members $NewUser

        # Create share for personal data
        $newFolder = New-item -ItemType Directory -Path 'e:\users' -Name $UserName
        $newShare = New-SmbShare -Name "$UserName$" -Path $newFolder.FullName 

        # Enable User
        Set-ADUser -Identity $NewUser -Enabled $true 

        write-host "New user created for $($entry.Name)" -ForegroundColor Green

    } catch {

        Write-Host $_.exception.Message -ForegroundColor Red
        Write-Host "Skipping entry $($entry.Name)"

    }

}
