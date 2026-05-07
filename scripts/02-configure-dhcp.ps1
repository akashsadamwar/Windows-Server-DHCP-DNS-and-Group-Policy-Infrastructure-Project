[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\configs\lab-variables.psd1",
    [string]$ReservationsPath = "$PSScriptRoot\..\inventory\dhcp-reservations.csv"
)

$ErrorActionPreference = 'Stop'
$Config = Import-PowerShellDataFile -Path $ConfigPath

Import-Module DhcpServer

$ScopeId = [System.Net.IPAddress]::Parse($Config.NetworkId)
$StartRange = [System.Net.IPAddress]::Parse($Config.ScopeStart)
$EndRange = [System.Net.IPAddress]::Parse($Config.ScopeEnd)
$SubnetMask = [System.Net.IPAddress]::Parse($Config.SubnetMask)

if ($PSCmdlet.ShouldProcess($Config.DhcpServer, 'Authorize DHCP server in Active Directory')) {
    try {
        Add-DhcpServerInDC -DnsName $Config.DhcpServer -IPAddress $Config.ServerIPAddress
    }
    catch {
        Write-Warning "DHCP authorization may already exist or failed: $($_.Exception.Message)"
    }
}

$ExistingScope = Get-DhcpServerv4Scope -ScopeId $ScopeId -ErrorAction SilentlyContinue
if (-not $ExistingScope) {
    if ($PSCmdlet.ShouldProcess($Config.ScopeName, 'Create DHCP scope')) {
        Add-DhcpServerv4Scope `
            -Name $Config.ScopeName `
            -StartRange $StartRange `
            -EndRange $EndRange `
            -SubnetMask $SubnetMask `
            -LeaseDuration ([TimeSpan]::Parse($Config.LeaseDuration)) `
            -State Active
    }
}
else {
    Write-Host "DHCP scope $($Config.NetworkId) already exists."
}

if ($PSCmdlet.ShouldProcess($Config.ScopeName, 'Configure DHCP exclusions and options')) {
    Add-DhcpServerv4ExclusionRange `
        -ScopeId $ScopeId `
        -StartRange $Config.ExclusionStart `
        -EndRange $Config.ExclusionEnd `
        -ErrorAction SilentlyContinue

    Set-DhcpServerv4OptionValue `
        -ScopeId $ScopeId `
        -Router $Config.DefaultGateway `
        -DnsServer $Config.DnsServerIPAddress `
        -DnsDomain $Config.DomainName
}

if (Test-Path $ReservationsPath) {
    $Reservations = Import-Csv -Path $ReservationsPath
    foreach ($Reservation in $Reservations) {
        if ($Reservation.Name -and $Reservation.IPAddress -and $Reservation.ClientId) {
            if ($PSCmdlet.ShouldProcess($Reservation.Name, 'Create DHCP reservation')) {
                Add-DhcpServerv4Reservation `
                    -ScopeId $ScopeId `
                    -IPAddress $Reservation.IPAddress `
                    -ClientId $Reservation.ClientId `
                    -Name $Reservation.Name `
                    -Description $Reservation.Description `
                    -ErrorAction SilentlyContinue
            }
        }
    }
}

Restart-Service DHCPServer
Write-Host "DHCP configuration complete for scope $($Config.NetworkId)."
