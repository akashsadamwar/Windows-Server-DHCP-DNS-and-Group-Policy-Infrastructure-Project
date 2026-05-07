# IT Infrastructure Project: DHCP, DNS, and Group Policy

This project designs and documents a small business Windows Server infrastructure focused on three core IT administration services:

- DHCP for automatic IP address assignment
- DNS for internal name resolution
- Group Policy Objects (GPOs) for centralized workstation and user management

The project is written as a complete implementation package for a lab, class project, or junior systems administration portfolio.

## Scenario

Contoso Branch Office needs a reliable local infrastructure for 80 users, Windows client computers, printers, and shared internal services. The organization uses Active Directory Domain Services with centralized DHCP, DNS, and GPO management.

## Goals

- Build a clean IP addressing plan.
- Configure DHCP scopes, reservations, exclusions, and options.
- Configure internal DNS zones, records, forwarding, and scavenging.
- Create Group Policies for security, workstation settings, user settings, and mapped resources.
- Provide validation steps, troubleshooting steps, and operational maintenance guidance.

## Project Structure

```text
.
├── configs/
│   └── lab-variables.psd1
├── docs/
│   ├── architecture.md
│   ├── implementation-guide.md
│   ├── operations-runbook.md
│   ├── project-report.md
│   ├── security-baseline.md
│   ├── testing-checklist.md
│   └── troubleshooting.md
├── gpo/
│   └── security-baseline.csv
├── inventory/
│   ├── dhcp-reservations.csv
│   ├── dns-records.csv
│   └── network-plan.csv
├── scripts/
│   ├── 01-install-roles.ps1
│   ├── 02-configure-dhcp.ps1
│   ├── 03-configure-dns.ps1
│   ├── 04-create-gpo-baseline.ps1
│   ├── 05-validation-report.ps1
│   └── 06-backup-config.ps1
└── README.md
```

## Lab Environment

Recommended virtual machines:

| Server | Role | OS | IP Address |
| --- | --- | --- | --- |
| DC01 | Domain Controller, DNS, DHCP | Windows Server 2022/2025 | 10.10.10.10 |
| FS01 | File Server | Windows Server 2022/2025 | 10.10.10.20 |
| PC01 | Test Workstation | Windows 10/11 Enterprise or Pro | DHCP |

Domain:

```text
contoso.local
```

Network:

```text
10.10.10.0/24
```

## Quick Start

Run PowerShell as Administrator on the domain controller.

1. Review [configs/lab-variables.psd1](configs/lab-variables.psd1).
2. Install roles:

   ```powershell
   .\scripts\01-install-roles.ps1
   ```

3. Configure DHCP:

   ```powershell
   .\scripts\02-configure-dhcp.ps1
   ```

4. Configure DNS:

   ```powershell
   .\scripts\03-configure-dns.ps1
   ```

5. Create baseline GPOs:

   ```powershell
   .\scripts\04-create-gpo-baseline.ps1
   ```

6. Generate a validation report:

   ```powershell
   .\scripts\05-validation-report.ps1
   ```

7. Export DHCP, DNS, and GPO configuration backups:

   ```powershell
   .\scripts\06-backup-config.ps1
   ```

## Important Notes

- These scripts are designed for a lab or controlled environment.
- Review all IP addresses, domain names, DNS forwarders, and GPO settings before using in production.
- GPO settings can affect many computers quickly. Test with a small organizational unit first.

## Deliverables

This project includes:

- Network design
- DHCP design and automation
- DNS design and automation
- GPO design and automation
- Security baseline
- Inventory templates
- Troubleshooting guide
- Operations runbook
- Validation script
- Backup script
- Final project report
