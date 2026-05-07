@{
    DomainName       = 'contoso.local'
    NetBIOSName      = 'CONTOSO'
    DhcpServer       = 'DC01.contoso.local'
    DnsServer        = 'DC01.contoso.local'
    ServerIPAddress  = '10.10.10.10'
    DnsServerIPAddress = '10.10.10.10'
    InterfaceAlias   = 'Ethernet'

    NetworkId        = '10.10.10.0'
    SubnetMask       = '255.255.255.0'
    PrefixLength     = 24
    DefaultGateway   = '10.10.10.1'
    ScopeName        = 'Contoso LAN'
    ScopeStart       = '10.10.10.50'
    ScopeEnd         = '10.10.10.200'
    ExclusionStart   = '10.10.10.1'
    ExclusionEnd     = '10.10.10.49'
    LeaseDuration    = '8.00:00:00'

    DnsForwarders    = @('1.1.1.1', '8.8.8.8')
    ReverseZone      = '10.10.10.in-addr.arpa'

    TestOuName       = 'Workstations-Test'
    WorkstationOuDn  = 'OU=Workstations-Test,DC=contoso,DC=local'
    UserOuDn         = 'OU=Users,DC=contoso,DC=local'

    SharedDrivePath  = '\\FS01\Shared'
    SharedDriveLetter = 'S:'
}
