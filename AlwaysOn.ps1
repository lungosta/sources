#Import Module
Import-Module Sqlps -DisableNameChecking;

#Get Instance Name and Availability Group
$instance = Get-ChildItem SQL/$env:computername | Select DisplayName
$instance = $instance.DisplayName
$ag_name = Get-ChildItem SQL/$env:computername/$instance/AvailabilityGroups | Select-Object Name
$ag_name = $ag_name.Name


#Get Nodes
$primary = Get-ChildItem SQL/$env:computername/$instance/AvailabilityGroups/$ag_name/AvailabilityReplicas | Where{$_.Role -eq "Primary"}
$primary = $primary.Name -replace "\\$instance", ""


$secondary = Get-ChildItem SQL/$env:computername/$instance/AvailabilityGroups/$ag_name/AvailabilityReplicas | Where{$_.Role -eq "Secondary"}
$secondary = $secondary.Name -replace "\\$instance", ""

if ($primary -eq $env:computername)

{

    #Performing Failover
    Switch-SqlAvailabilityGroup -Path SQLSERVER:\Sql\$secondary\$instance\AvailabilityGroups\$ag_name

    Start-Sleep -s 30

    $DBTest = Get-ChildItem SQLSERVER:\Sql\$primary\$instance\AvailabilityGroups\$ag_name\DatabaseReplicaStates `
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

