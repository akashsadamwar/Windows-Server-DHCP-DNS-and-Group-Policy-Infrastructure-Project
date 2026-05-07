# Testing Checklist

Use this checklist after implementation.

## Server Checks

| Test | Expected Result | Pass/Fail |
| --- | --- | --- |
| `Get-Service DHCPServer` | Service is running |  |
| `Get-Service DNS` | Service is running |  |
| `Get-DhcpServerInDC` | DC01 is authorized |  |
| `Get-DhcpServerv4Scope` | Scope exists and is active |  |
| `Get-DnsServerZone` | Forward and reverse zones exist |  |
| `Get-GPO -All` | Baseline GPOs exist |  |

## DHCP Client Checks

Run on a Windows client:

```powershell
ipconfig /release
ipconfig /renew
ipconfig /all
```

Expected:

| Item | Expected Value | Pass/Fail |
| --- | --- | --- |
| IPv4 address | 10.10.10.50-10.10.10.200 |  |
| Subnet mask | 255.255.255.0 |  |
| Default gateway | 10.10.10.1 |  |
| DNS server | 10.10.10.10 |  |
| DNS suffix | contoso.local |  |

## DNS Checks

Run:

```powershell
Resolve-DnsName dc01.contoso.local
Resolve-DnsName fs01.contoso.local
Resolve-DnsName files.contoso.local
Resolve-DnsName microsoft.com
```

Expected:

| Test | Expected Result | Pass/Fail |
| --- | --- | --- |
| DC01 lookup | 10.10.10.10 |  |
| FS01 lookup | 10.10.10.20 |  |
| CNAME lookup | files resolves to fs01 |  |
| External lookup | Public name resolves |  |

## GPO Checks

Run on a test workstation:

```powershell
gpupdate /force
gpresult /r
gpresult /h C:\Temp\gpresult.html
```

Expected:

| Test | Expected Result | Pass/Fail |
| --- | --- | --- |
| Computer baseline GPO | Applied |  |
| Workstation configuration GPO | Applied |  |
| User environment GPO | Applied for test user |  |
| Unexpected denied GPOs | None without explanation |  |

## Final Sign-Off

| Role | Name | Date | Signature |
| --- | --- | --- | --- |
| Implementer |  |  |  |
| Reviewer |  |  |  |
| Instructor/Manager |  |  |  |

