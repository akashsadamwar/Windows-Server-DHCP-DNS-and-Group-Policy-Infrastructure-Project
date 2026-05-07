# Troubleshooting Guide

## DHCP Issues

### Client receives APIPA address

Symptom:

```text
169.254.x.x
```

Checks:

```powershell
ipconfig /all
Get-Service DHCPServer
Get-DhcpServerv4Scope
Get-DhcpServerv4ScopeStatistics
```

Likely causes:

- DHCP service is stopped.
- DHCP server is not authorized in Active Directory.
- Scope is inactive.
- Scope has no available addresses.
- Client is on a VLAN without DHCP relay.

### Client receives wrong DNS server

Check DHCP options:

```powershell
Get-DhcpServerv4OptionValue -ScopeId 10.10.10.0
```

Expected:

- Router: `10.10.10.1`
- DNS server: `10.10.10.10`
- DNS domain: `contoso.local`

## DNS Issues

### Internal host does not resolve

Run:

```powershell
Resolve-DnsName hostname.contoso.local
nslookup hostname.contoso.local
Get-DnsServerResourceRecord -ZoneName contoso.local
```

Likely causes:

- Missing A record.
- Client points to external DNS instead of domain DNS.
- DNS registration failed.
- Stale or duplicate record exists.

### External websites do not resolve

Check:

```powershell
Get-DnsServerForwarder
Resolve-DnsName microsoft.com -Server 10.10.10.10
```

Likely causes:

- Missing or unreachable DNS forwarder.
- Firewall blocks DNS recursion.
- Internet connectivity issue.

## GPO Issues

### GPO does not apply

Run on the client:

```powershell
gpupdate /force
gpresult /r
```

Check:

- Computer is in the correct OU.
- GPO is linked to the OU.
- Security filtering allows the computer or user.
- WMI filter does not exclude the target.
- Block inheritance or enforced links are not interfering.

### GPO applies but setting is missing

Check:

```powershell
gpresult /h C:\Temp\gpresult.html
```

Likely causes:

- Another GPO has a higher precedence.
- Setting is under user configuration but only computer object was targeted.
- Client needs restart or sign-out.
- Administrative template setting is unsupported on client OS.

## Event Logs

Useful logs:

- System
- Directory Service
- DNS Server
- DHCP Server
- GroupPolicy Operational log

