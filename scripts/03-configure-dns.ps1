[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\configs\lab-variables.psd1",
    [string]$RecordsPath = "$PSScriptRoot\..\inventory\dns-records.csv"
)

$ErrorActionPreference = 'Stop'
$Config = Import-PowerShellDataFile -Path $ConfigPath

Import-Module DnsServer

$ForwardZone = Get-DnsServerZone -Name $Config.DomainName -ErrorAction SilentlyContinue
if (-not $ForwardZone) {
    if ($PSCmdlet.ShouldProcess($Config.DomainName, 'Create AD-integrated forward lookup zone')) {
        Add-DnsServerPrimaryZone -Name $Config.DomainName -ReplicationScope Domain -DynamicUpdate Secure
    }
}

$ReverseZone = Get-DnsServerZone -Name $Config.ReverseZone -ErrorAction SilentlyContinue
if (-not $ReverseZone) {
    if ($PSCmdlet.ShouldProcess($Config.ReverseZone, 'Create AD-integrated reverse lookup zone')) {
        Add-DnsServerPrimaryZone -NetworkId "$($Config.NetworkId)/$($Config.PrefixLength)" -ReplicationScope Domain -DynamicUpdate Secure
    }
}

if ($Config.DnsForwarders.Count -gt 0) {
    if ($PSCmdlet.ShouldProcess(($Config.DnsForwarders -join ', '), 'Configure DNS forwarders')) {
        Set-DnsServerForwarder -IPAddress $Config.DnsForwarders -UseRootHint $true
    }
}

if (Test-Path $RecordsPath) {
    $Records = Import-Csv -Path $RecordsPath
    foreach ($Record in $Records) {
        switch ($Record.Type.ToUpperInvariant()) {
            'A' {
                if ($PSCmdlet.ShouldProcess("$($Record.Name).$($Record.Zone)", 'Create A record')) {
                    Add-DnsServerResourceRecordA `
                        -ZoneName $Record.Zone `
                        -Name $Record.Name `
                        -IPv4Address $Record.IPAddress `
                        -CreatePtr `
                        -AllowUpdateAny `
                        -ErrorAction SilentlyContinue
                }
            }
            'CNAME' {
                if ($PSCmdlet.ShouldProcess("$($Record.Name).$($Record.Zone)", 'Create CNAME record')) {
                    Add-DnsServerResourceRecordCName `
                        -ZoneName $Record.Zone `
                        -Name $Record.Name `
                        -HostNameAlias $Record.Target `
                        -ErrorAction SilentlyContinue
                }
            }
        }
    }
}

Set-DnsServerScavenging -ScavengingState $true -RefreshInterval 7.00:00:00 -NoRefreshInterval 7.00:00:00 -ApplyOnAllZones
Write-Host "DNS configuration complete for $($Config.DomainName)."

