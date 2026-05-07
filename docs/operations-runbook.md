# Operations Runbook

## Daily Checks

- Confirm DHCP service is running.
- Check DHCP scope utilization.
- Review DNS event logs for recurring errors.
- Review failed logon spikes or lockout events.

## Weekly Checks

- Export DHCP configuration.
- Review new DNS records.
- Check for stale DNS records.
- Review GPO changes.
- Confirm workstation patch compliance.

## Monthly Checks

- Validate DHCP backups.
- Review DHCP reservations.
- Audit GPO links and inheritance.
- Review domain administrator group membership.
- Test restore process for DHCP configuration.

## Useful Commands

DHCP:

```powershell
Get-DhcpServerv4Scope
Get-DhcpServerv4ScopeStatistics
Get-DhcpServerv4Lease -ScopeId 10.10.10.0
Backup-DhcpServer -ComputerName DC01 -Path C:\DHCPBackup
```

DNS:

```powershell
Get-DnsServerZone
Get-DnsServerResourceRecord -ZoneName contoso.local
Resolve-DnsName dc01.contoso.local
```

GPO:

```powershell
Get-GPO -All
Get-GPInheritance -Target "OU=Workstations-Test,DC=contoso,DC=local"
gpresult /r
gpresult /h C:\Temp\gpresult.html
```

## Backup Guidance

DHCP:

```powershell
Backup-DhcpServer -ComputerName DC01 -Path C:\DHCPBackup
```

GPO:

```powershell
Backup-GPO -All -Path C:\GPOBackup
```

DNS:

Active Directory-integrated zones are protected through system state and AD backups. Also export important records for documentation.

## Rollback Guidance

DHCP:

- Remove new scope options if clients receive incorrect network settings.
- Deactivate a faulty scope instead of deleting it immediately.

DNS:

- Remove incorrect A, CNAME, or PTR records.
- Clear client resolver cache with `ipconfig /flushdns`.

GPO:

- Unlink the GPO from the affected OU.
- Disable the computer or user configuration side if only one side caused the issue.
- Restore a previous GPO backup if needed.

