[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\configs\lab-variables.psd1",
    [string]$OutputPath = "$PSScriptRoot\..\validation-report-$(Get-Date -Format yyyyMMdd-HHmmss).txt"
)

$ErrorActionPreference = 'Continue'
$Config = Import-PowerShellDataFile -Path $ConfigPath

$Lines = New-Object System.Collections.Generic.List[string]

function Add-Section {
    param([string]$Title)
    $Lines.Add('')
    $Lines.Add("== $Title ==")
}

function Add-Result {
    param(
        [string]$Name,
        [scriptblock]$Test
    )

    try {
        $Value = & $Test
        $Lines.Add("[PASS] $Name")
        if ($Value) {
            $Lines.Add(($Value | Out-String).Trim())
        }
    }
    catch {
        $Lines.Add("[FAIL] $Name - $($_.Exception.Message)")
    }
}

$Lines.Add("Contoso DHCP DNS GPO Validation Report")
$Lines.Add("Generated: $(Get-Date)")
$Lines.Add("Computer: $env:COMPUTERNAME")
$Lines.Add("Domain: $($Config.DomainName)")

Add-Section 'DHCP'
Add-Result 'DHCP Server service status' { Get-Service DHCPServer | Select-Object Name, Status }
Add-Result 'DHCP scopes' { Get-DhcpServerv4Scope | Select-Object ScopeId, Name, State, StartRange, EndRange }
Add-Result 'DHCP scope options' { Get-DhcpServerv4OptionValue -ScopeId $Config.NetworkId | Select-Object OptionId, Name, Value }
Add-Result 'DHCP scope utilization' { Get-DhcpServerv4ScopeStatistics -ScopeId $Config.NetworkId | Select-Object ScopeId, AddressesInUse, AddressesFree, PercentageInUse }

Add-Section 'DNS'
Add-Result 'DNS Server service status' { Get-Service DNS | Select-Object Name, Status }
Add-Result 'DNS zones' { Get-DnsServerZone | Select-Object ZoneName, ZoneType, IsDsIntegrated, DynamicUpdate }
Add-Result 'Resolve domain controller' { Resolve-DnsName "dc01.$($Config.DomainName)" | Select-Object Name, Type, IPAddress }
Add-Result 'DNS forwarders' { Get-DnsServerForwarder | Select-Object IPAddress, UseRootHint }

Add-Section 'Group Policy'
Add-Result 'All GPOs' { Get-GPO -All | Select-Object DisplayName, GpoStatus, CreationTime, ModificationTime }
Add-Result 'Workstation OU inheritance' { Get-GPInheritance -Target $Config.WorkstationOuDn | Select-Object -ExpandProperty GpoLinks }
Add-Result 'User OU inheritance' { Get-GPInheritance -Target $Config.UserOuDn | Select-Object -ExpandProperty GpoLinks }

Add-Section 'Client Commands To Run'
$Lines.Add('ipconfig /all')
$Lines.Add('ipconfig /renew')
$Lines.Add('Resolve-DnsName dc01.contoso.local')
$Lines.Add('gpupdate /force')
$Lines.Add('gpresult /r')

$Lines | Set-Content -Path $OutputPath -Encoding UTF8
Write-Host "Validation report written to $OutputPath"

