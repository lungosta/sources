## Developed by Juan Camacho

Param
(

    [string]$csvname,
    [int]$group,
    [string]$action


)

#API Credentials
$encrypted = Get-Content $PSScriptRoot\securepassword.txt
$user = "sys_sdimhoffice"
$password = ConvertTo-SecureString -string $encrypted 
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$password


#Get CSV Information
$servers = Import-Csv $PSScriptRoot\HighWiredPools\$csvname | where{$_.ServerName -like "*$group"}


##Start Session to API
New-LBSession -Domain AMR -Username $cred.UserName -Password $cred.Password

foreach($server in $servers)
{

    $pool = Get-LBLtmPool -Name $server.Pool
    $member = Get-LBLTMPoolMember $pool.Id | Where{$_.Ip -eq $server.IPAddress}
    $member.AdminState = "$action"
    Update-LBLtmPoolMember $pool.Id $member


}
