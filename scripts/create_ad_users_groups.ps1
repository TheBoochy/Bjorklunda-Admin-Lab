# Bjorklunda Admin Lab
# Part 5 - Account management with scripts
# Purpose: Create and verify Active Directory OUs, groups, users and memberships.

Import-Module ActiveDirectory

$DomainDN = "DC=bjorklunda,DC=local"

$MainOU = "OU=Bjorklunda,$DomainDN"
$UsersOU = "OU=Users,$MainOU"
$GroupsOU = "OU=Groups,$MainOU"
$ComputersOU = "OU=Computers,$MainOU"
$ServersOU = "OU=Servers,$MainOU"
$DepartmentsOU = "OU=Departments,$MainOU"

$DepartmentOUs = @(
    "IT",
    "HR",
    "Finance",
    "Education"
)

$Groups = @(
    @{ Name = "GG_IT_Users"; Department = "IT"; Description = "Global security group for IT users" },
    @{ Name = "GG_HR_Users"; Department = "HR"; Description = "Global security group for HR users" },
    @{ Name = "GG_Finance_Users"; Department = "Finance"; Description = "Global security group for Finance users" },
    @{ Name = "GG_Education_Users"; Department = "Education"; Description = "Global security group for Education users" }
)

$Users = @(
    @{ Name = "IT User01"; GivenName = "IT"; Surname = "User01"; Sam = "it.user01"; Group = "GG_IT_Users" },
    @{ Name = "HR User01"; GivenName = "HR"; Surname = "User01"; Sam = "hr.user01"; Group = "GG_HR_Users" },
    @{ Name = "Finance User01"; GivenName = "Finance"; Surname = "User01"; Sam = "finance.user01"; Group = "GG_Finance_Users" },
    @{ Name = "Education User01"; GivenName = "Education"; Surname = "User01"; Sam = "education.user01"; Group = "GG_Education_Users" }
)

$TemporaryPassword = ConvertTo-SecureString "TempPass!2026" -AsPlainText -Force

function Ensure-OU {
    param (
        [string]$Name,
        [string]$Path
    )

    $DistinguishedName = "OU=$Name,$Path"
    $ExistingOU = Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$DistinguishedName)" -ErrorAction SilentlyContinue

    if (-not $ExistingOU) {
        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
        Write-Host "Created OU: $DistinguishedName"
    }
    else {
        Write-Host "OU already exists: $DistinguishedName"
    }
}

function Ensure-Group {
    param (
        [string]$Name,
        [string]$Description
    )

    $ExistingGroup = Get-ADGroup -Filter "SamAccountName -eq '$Name'" -ErrorAction SilentlyContinue

    if (-not $ExistingGroup) {
        New-ADGroup `
            -Name $Name `
            -SamAccountName $Name `
            -GroupCategory Security `
            -GroupScope Global `
            -Path $GroupsOU `
            -Description $Description

        Write-Host "Created group: $Name"
    }
    else {
        Write-Host "Group already exists: $Name"
    }
}

function Ensure-User {
    param (
        [string]$Name,
        [string]$GivenName,
        [string]$Surname,
        [string]$SamAccountName
    )

    $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue

    if (-not $ExistingUser) {
        New-ADUser `
            -Name $Name `
            -GivenName $GivenName `
            -Surname $Surname `
            -SamAccountName $SamAccountName `
            -UserPrincipalName "$SamAccountName@bjorklunda.local" `
            -Path $UsersOU `
            -AccountPassword $TemporaryPassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Created user: $SamAccountName"
    }
    else {
        Write-Host "User already exists: $SamAccountName"
    }
}

# Create OU structure
Ensure-OU -Name "Bjorklunda" -Path $DomainDN
Ensure-OU -Name "Users" -Path $MainOU
Ensure-OU -Name "Groups" -Path $MainOU
Ensure-OU -Name "Computers" -Path $MainOU
Ensure-OU -Name "Servers" -Path $MainOU
Ensure-OU -Name "Departments" -Path $MainOU

foreach ($Department in $DepartmentOUs) {
    Ensure-OU -Name $Department -Path $DepartmentsOU
}

# Create groups
foreach ($Group in $Groups) {
    Ensure-Group -Name $Group.Name -Description $Group.Description
}

# Create users
foreach ($User in $Users) {
    Ensure-User `
        -Name $User.Name `
        -GivenName $User.GivenName `
        -Surname $User.Surname `
        -SamAccountName $User.Sam
}

# Add users to groups
foreach ($User in $Users) {
    Add-ADGroupMember -Identity $User.Group -Members $User.Sam -ErrorAction SilentlyContinue
    Write-Host "Verified membership: $($User.Sam) -> $($User.Group)"
}

Write-Host ""
Write-Host "Users in Bjorklunda Users OU:"
Get-ADUser -Filter * -SearchBase $UsersOU | Select-Object Name, SamAccountName, Enabled

Write-Host ""
Write-Host "Groups in Bjorklunda Groups OU:"
Get-ADGroup -Filter * -SearchBase $GroupsOU | Select-Object Name, GroupScope, GroupCategory