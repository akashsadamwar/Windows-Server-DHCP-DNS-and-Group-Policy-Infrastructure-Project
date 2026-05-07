[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\configs\lab-variables.psd1",
    [string]$BackupRoot = "$PSScriptRoot\..\backups"
)

$ErrorActionPreference = 'Stop'
$Config = Import-PowerShellDataFile -Path $ConfigPath
$Timestamp = Get-Date -Format yyyyMMdd-HHmmss
$BackupPath = Join-Path $BackupRoot $Timestamp
$DhcpBackupPath = Join-Path $BackupPath 'dhcp'
$GpoBackupPath = Join-Path $BackupPath 'gpo'

New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
New-Item -ItemType Directory -Path $DhcpBackupPath -Force | Out-Null
New-Item -ItemType Directory -Path $GpoBackupPath -Force | Out-Null

Write-Host "Writing backup files to $BackupPath"

try {
    Backup-DhcpServer -ComputerName $Config.DhcpServer -Path $DhcpBackupPath -Force
}
catch {
    Write-Warning "DHCP backup failed: $($_.Exception.Message)"
}

try {
    Backup-GPO -All -Path $GpoBackupPath | Out-Null
}
catch {
    Write-Warning "GPO backup failed: $($_.Exception.Message)"
}

try {
    Get-DnsServerZone | Export-Csv -NoTypeInformation -Path (Join-Path $BackupPath 'dns-zones.csv')
    Get-DnsServerResourceRecord -ZoneName $Config.DomainName |
        Export-Csv -NoTypeInformation -Path (Join-Path $BackupPath 'dns-records.csv')
}
catch {
    Write-Warning "DNS export failed: $($_.Exception.Message)"
}

try {
    Get-GPO -All |
        Select-Object DisplayName, Id, Owner, GpoStatus, CreationTime, ModificationTime |
        Export-Csv -NoTypeInformation -Path (Join-Path $BackupPath 'gpo-inventory.csv')
}
catch {
    Write-Warning "GPO inventory export failed: $($_.Exception.Message)"
}

Write-Host 'Backup/export complete.'
