[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\configs\lab-variables.psd1"
)

$ErrorActionPreference = 'Stop'
$Config = Import-PowerShellDataFile -Path $ConfigPath

$Features = @(
    'DHCP',
    'DNS',
    'RSAT-DHCP',
    'RSAT-DNS-Server',
    'RSAT-AD-Tools',
    'GPMC'
)

foreach ($Feature in $Features) {
    if ($PSCmdlet.ShouldProcess($Feature, 'Install Windows feature')) {
        Install-WindowsFeature -Name $Feature -IncludeManagementTools | Out-Null
    }
}

Write-Host "Installed DHCP, DNS, AD, and Group Policy management tools for $($Config.DomainName)."

