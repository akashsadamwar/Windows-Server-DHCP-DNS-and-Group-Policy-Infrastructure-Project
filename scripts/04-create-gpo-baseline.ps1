[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\configs\lab-variables.psd1"
)

$ErrorActionPreference = 'Stop'
$Config = Import-PowerShellDataFile -Path $ConfigPath

Import-Module ActiveDirectory
Import-Module GroupPolicy

function Ensure-OrganizationalUnit {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $DistinguishedName = "OU=$Name,$Path"
    if (-not (Get-ADOrganizationalUnit -Identity $DistinguishedName -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
    }
}

$DomainDn = (Get-ADDomain).DistinguishedName

Ensure-OrganizationalUnit -Name 'Users' -Path $DomainDn
Ensure-OrganizationalUnit -Name $Config.TestOuName -Path $DomainDn
Ensure-OrganizationalUnit -Name 'Workstations' -Path $DomainDn
Ensure-OrganizationalUnit -Name 'Servers' -Path $DomainDn
Ensure-OrganizationalUnit -Name 'Service Accounts' -Path $DomainDn
Ensure-OrganizationalUnit -Name 'Groups' -Path $DomainDn

$Gpos = @(
    'CONTOSO - Computer Security Baseline',
    'CONTOSO - Workstation Configuration',
    'CONTOSO - User Environment'
)

foreach ($GpoName in $Gpos) {
    if (-not (Get-GPO -Name $GpoName -ErrorAction SilentlyContinue)) {
        if ($PSCmdlet.ShouldProcess($GpoName, 'Create GPO')) {
            New-GPO -Name $GpoName | Out-Null
        }
    }
}

if ($PSCmdlet.ShouldProcess($Config.WorkstationOuDn, 'Link computer GPOs')) {
    New-GPLink -Name 'CONTOSO - Computer Security Baseline' -Target $Config.WorkstationOuDn -LinkEnabled Yes -ErrorAction SilentlyContinue
    New-GPLink -Name 'CONTOSO - Workstation Configuration' -Target $Config.WorkstationOuDn -LinkEnabled Yes -ErrorAction SilentlyContinue
}

if ($PSCmdlet.ShouldProcess($Config.UserOuDn, 'Link user GPO')) {
    New-GPLink -Name 'CONTOSO - User Environment' -Target $Config.UserOuDn -LinkEnabled Yes -ErrorAction SilentlyContinue
}

if ($PSCmdlet.ShouldProcess('CONTOSO - Computer Security Baseline', 'Configure registry-based baseline settings')) {
    Set-GPRegistryValue -Name 'CONTOSO - Computer Security Baseline' -Key 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System' -ValueName 'ConsentPromptBehaviorAdmin' -Type DWord -Value 5
    Set-GPRegistryValue -Name 'CONTOSO - Computer Security Baseline' -Key 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System' -ValueName 'EnableLUA' -Type DWord -Value 1
    Set-GPRegistryValue -Name 'CONTOSO - Computer Security Baseline' -Key 'HKLM\Software\Policies\Microsoft\WindowsFirewall\DomainProfile' -ValueName 'EnableFirewall' -Type DWord -Value 1
}

if ($PSCmdlet.ShouldProcess('CONTOSO - Workstation Configuration', 'Configure workstation settings')) {
    Set-GPRegistryValue -Name 'CONTOSO - Workstation Configuration' -Key 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -ValueName 'NoAutoUpdate' -Type DWord -Value 0
    Set-GPRegistryValue -Name 'CONTOSO - Workstation Configuration' -Key 'HKLM\Software\Policies\Microsoft\Windows\System' -ValueName 'DisableCMD' -Type DWord -Value 0
}

if ($PSCmdlet.ShouldProcess('CONTOSO - User Environment', 'Configure user drive mapping preference note')) {
    Set-GPRegistryValue -Name 'CONTOSO - User Environment' -Key 'HKCU\Software\Contoso\Environment' -ValueName 'SharedDrivePath' -Type String -Value $Config.SharedDrivePath
    Set-GPRegistryValue -Name 'CONTOSO - User Environment' -Key 'HKCU\Software\Contoso\Environment' -ValueName 'SharedDriveLetter' -Type String -Value $Config.SharedDriveLetter
}

Write-Host 'GPO baseline created and linked. Configure advanced settings through GPMC as needed.'
