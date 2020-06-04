   <#
   .Description
    This Script contains an function which switches your dns to google.
    if you already use google dns is switches to the DHCP distributed dns
   
   #>
    # Self-elevate the script if required
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
         $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
         Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
         Exit
        }
       }

function setDnsToGoogle
{
    param
    (
        $interfacealias = "Ethernet"
    )
    $googleIP = @("8.8.8.8","8.8.4.4","2001:4860:4860::8888","2001:4860:4860::8844")
    $currentdns = Get-DnsClientServerAddress -InterfaceAlias $interfacealias
    foreach ($gip in $googleIP)
    {
        if(($currentdns).ServerAddresses -like $gip)
        {    
            Set-DnsClientServerAddress -InterfaceAlias $interfacealias -ResetServerAddresses
            Clear-DnsClientCache
            exit
        }else
        {
        Set-DnsClientServerAddress -InterfaceAlias $interfacealias -ServerAddresses ("8.8.8.8","8.8.4.4","2001:4860:4860::8888","2001:4860:4860::8844")
            exit
        }
    }
}
setDnsToGoogle -interfacealias "Ethernet"