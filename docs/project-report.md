# Project Report

## Title

Implementation of DHCP, DNS, and Group Policy Services for a Small Business Network

## Executive Summary

This project designs and implements three core Windows infrastructure services for a small business environment: DHCP, DNS, and Group Policy. The solution centralizes network address assignment, internal name resolution, and workstation policy enforcement through Windows Server and Active Directory.

The environment supports a branch office with approximately 80 users and room for future expansion. The design separates static infrastructure addresses from DHCP client addresses, uses Active Directory-integrated DNS for secure internal records, and applies Group Policy through organized OUs.

## Business Requirements

- Users must connect to the network without manually configuring IP addresses.
- Internal servers must resolve by friendly DNS names.
- Workstations must receive consistent security and configuration policies.
- Administrators must be able to troubleshoot and validate the environment quickly.
- The design must support future growth without major redesign.

## Technical Scope

Included:

- IP addressing plan
- DHCP scope design
- DHCP reservations
- DNS forward and reverse zones
- DNS records
- DNS forwarding and scavenging
- OU structure
- Baseline GPOs
- Testing checklist
- Validation script
- Backup script
- Troubleshooting and operations documentation

Excluded:

- Full Active Directory forest deployment
- Firewall appliance configuration
- Cloud identity integration
- Production change approval workflow

## Proposed Solution

The solution uses `DC01` as the main infrastructure server for the branch office. It provides:

- DHCP leases for client computers
- DNS resolution for internal hosts
- Active Directory-integrated DNS storage
- Group Policy management through GPMC

The design is simple enough for a small site but organized enough to scale.

## Risk Assessment

| Risk | Impact | Mitigation |
| --- | --- | --- |
| DHCP scope exhaustion | New clients cannot join network | Monitor utilization and reserve expansion range |
| Incorrect DHCP options | Clients lose DNS or gateway access | Validate scope options before rollout |
| Bad DNS record | Users reach wrong system or cannot connect | Document records and use validation testing |
| GPO misconfiguration | Workstations receive unwanted restrictions | Test GPOs on `Workstations-Test` OU first |
| Single server dependency | DHCP and DNS outage if DC01 fails | Add secondary domain controller/DNS/DHCP for production |

## Success Criteria

- A Windows client receives an address between `10.10.10.50` and `10.10.10.200`.
- Client DNS server is `10.10.10.10`.
- `dc01.contoso.local`, `fs01.contoso.local`, and `files.contoso.local` resolve.
- GPOs are linked to the intended OUs.
- `gpresult /r` confirms that test clients receive baseline policies.
- Backup and validation reports can be generated.

## Conclusion

The project provides a complete foundation for DHCP, DNS, and GPO administration in a Windows domain environment. It includes design documentation, implementation automation, testing procedures, operational guidance, and troubleshooting support.

