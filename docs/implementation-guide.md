# Implementation Guide

## Prerequisites

- Windows Server 2022 or newer
- Administrator access
- Static IP address on the domain controller
- Active Directory Domain Services installed and promoted
- PowerShell running as Administrator

## Phase 1: Prepare the Server

1. Rename the server to `DC01`.
2. Assign static IP address `10.10.10.10`.
3. Set preferred DNS server to `10.10.10.10`.
4. Install and promote Active Directory Domain Services for `contoso.local`.
5. Restart the server and sign in with a domain administrator account.

## Phase 2: Install DHCP and DNS Tools

Run:

```powershell
.\scripts\01-install-roles.ps1
```

This installs:

- DHCP Server
- DNS Server
- Remote Server Administration Tools for DHCP, DNS, AD DS, and Group Policy

## Phase 3: Configure DHCP

Review:

```text
configs/lab-variables.psd1
inventory/dhcp-reservations.csv
```

Then run:

```powershell
.\scripts\02-configure-dhcp.ps1
```

Confirm:

```powershell
Get-DhcpServerv4Scope
Get-DhcpServerv4OptionValue -ScopeId 10.10.10.0
Get-DhcpServerv4Reservation -ScopeId 10.10.10.0
```

Expected DHCP options:

| Option | Value |
| --- | --- |
| Router | 10.10.10.1 |
| DNS server | 10.10.10.10 |
| DNS suffix | contoso.local |

## Phase 4: Configure DNS

Review:

```text
inventory/dns-records.csv
```

Then run:

```powershell
.\scripts\03-configure-dns.ps1
```

Confirm:

```powershell
Resolve-DnsName dc01.contoso.local
Resolve-DnsName fs01.contoso.local
Resolve-DnsName intranet.contoso.local
Resolve-DnsName files.contoso.local
```

## Phase 5: Create and Link GPOs

Run:

```powershell
.\scripts\04-create-gpo-baseline.ps1
```

Then test on a small OU first:

```powershell
gpupdate /force
gpresult /r
```

## Phase 6: Validate

Run:

```powershell
.\scripts\05-validation-report.ps1
```

Save the report for project documentation or audit evidence.

## Acceptance Criteria

The project is complete when:

- DHCP leases are issued to test workstations.
- Clients receive correct gateway, DNS server, and DNS suffix.
- Internal DNS records resolve successfully.
- Reverse lookup works for key static devices.
- GPOs are linked to the correct OUs.
- A test workstation receives the expected GPOs.
- Validation report shows no major failures.
