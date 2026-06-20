# Bjorklunda Admin Lab
# Script: create_department_shares.ps1
# Purpose: Create department folders and SMB shares on srv-dc01.

$BasePath = "C:\Shares"

$Shares = @(
    @{ Name = "IT";        Group = "BJORKLUNDA\GG_IT_Users" },
    @{ Name = "HR";        Group = "BJORKLUNDA\GG_HR_Users" },
    @{ Name = "Finance";   Group = "BJORKLUNDA\GG_Finance_Users" },
    @{ Name = "Education"; Group = "BJORKLUNDA\GG_Education_Users" }
)

Write-Host "Creating base folder: $BasePath"
New-Item -Path $BasePath -ItemType Directory -Force | Out-Null

foreach ($Share in $Shares) {
    $FolderPath = Join-Path $BasePath $Share.Name

    Write-Host "Creating folder: $FolderPath"
    New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null

    if (Get-SmbShare -Name $Share.Name -ErrorAction SilentlyContinue) {
        Write-Host "Share already exists: $($Share.Name)"
    }
    else {
        Write-Host "Creating SMB share: $($Share.Name)"
        New-SmbShare `
            -Name $Share.Name `
            -Path $FolderPath `
            -FullAccess "BJORKLUNDA\Domain Admins" `
            -ChangeAccess $Share.Group | Out-Null
    }
}

Write-Host ""
Write-Host "Department shares:"
Get-SmbShare | Where-Object { $_.Name -in "IT","HR","Finance","Education" }

Write-Host ""
Write-Host "Share access:"
Get-SmbShareAccess -Name "IT"
Get-SmbShareAccess -Name "HR"
Get-SmbShareAccess -Name "Finance"
Get-SmbShareAccess -Name "Education"