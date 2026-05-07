# Security Baseline

## Security Objectives

- Reduce unauthorized access.
- Standardize workstation configuration.
- Improve audit visibility.
- Keep client systems patched.
- Limit unnecessary user control over sensitive settings.

## Password and Account Policy

Recommended baseline:

| Setting | Value |
| --- | --- |
| Enforce password history | 24 passwords |
| Minimum password length | 14 characters |
| Password complexity | Enabled |
| Maximum password age | 90 days |
| Account lockout threshold | 5 invalid attempts |
| Account lockout duration | 15 minutes |

## Windows Firewall

Enable Windows Defender Firewall for:

- Domain profile
- Private profile
- Public profile

Only approve inbound exceptions that are required for business operations.

## Auditing

Enable audit events for:

- Successful and failed logons
- Account management
- Policy changes
- Privilege use
- Object access where required

## Local Administrator Controls

Recommended controls:

- Rename the built-in local Administrator account.
- Disable guest account.
- Use separate administrative accounts.
- Consider Microsoft LAPS or Windows LAPS for local administrator password management.

## GPO Testing Process

1. Create a test OU.
2. Move one test workstation into the test OU.
3. Link the new GPO to the test OU.
4. Run `gpupdate /force`.
5. Check `gpresult /h report.html`.
6. Confirm no unexpected setting conflicts.
7. Roll the GPO out to production OUs.

## Change Control

For every GPO change, record:

- Date
- Requestor
- Business reason
- Settings changed
- Test result
- Rollback plan

