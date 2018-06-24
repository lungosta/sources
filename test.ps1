#Import Module
Import-Module Sqlps -DisableNameChecking;



#Get Nodes
$primary = Get-ChildItem SQL/$env:computername/SQL01/AvailabilityGroups/AG_CDOCSDEV/AvailabilityReplicas | Where{$_.Role -eq "Primary"}
$primary = $primary.Name -replace "\\SQL01", ""


$secondary = Get-ChildItem SQL/$env:computername/SQL01/AvailabilityGroups/AG_CDOCSDEV/AvailabilityReplicas | Where{$_.Role -eq "Secondary"}
$secondary = $secondary.Name -replace "\\SQL01", ""

if ($primary -eq $env:computername)

{

    #Performing Failover
    Switch-SqlAvailabilityGroup -Path SQLSERVER:\Sql\$secondary\SQL01\AvailabilityGroups\AG_CDOCSDEV

    Start-Sleep -s 30

    $DBTest = Get-ChildItem SQLSERVER:\Sql\FMSCDSSQL301\SQL01\AvailabilityGroups\AG_CDOCSDEV\DatabaseReplicaStates `
    | Test-SqlDatabaseReplicaState | Where{($_.HealthState -ne "PolicyExecutionFailure") -and ($_.HealthState -ne "Healthy")}
    $DBTest
    

    if ($DBTest -eq $null)
    {
    
        Write-Host "DBHealthy"
    
    }else
    {
    
        Write-Host "DBError"
    
    }

}else
{

   Write-Host "SecNode"

}

