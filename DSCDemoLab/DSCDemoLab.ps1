$LabName = "DSCDemoLab"
$DomainName = "contoso.local"
$DomainAdministrator = "Administrator"
$DomainPassword = "Somepass1"
$VmPath = Join-Path -Path "C:\LabSources\Labs" -ChildPath $LabName
$VirtualEngine = "HyperV"

New-LabDefinition -Name $LabName -DefaultVirtualizationEngine $VirtualEngine -VmPath $VmPath

#make the network definition
Add-LabVirtualNetworkDefinition -Name $labName
Add-LabVirtualNetworkDefinition -Name 'External' -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Wi-Fi' }

#and the domain definition with the domain admin account
Add-LabDomainDefinition -Name $DomainName -AdminUser $DomainAdministrator -AdminPassword $DomainPassword

#these credentials are used for connecting to the machines. As this is a lab we use clear-text passwords
Set-LabInstallationCredential -Username $DomainAdministrator -Password $DomainPassword

#defining default parameter values, as these ones are the same for all the machines
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network' = $labName
    'Add-LabMachineDefinition:DomainName' = $DomainName
    'Add-LabMachineDefinition:Memory' = 1GB
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2022 Datacenter'
}

$postInstallActivity = Get-LabPostInstallationActivity -ScriptFileName PrepareRootDomain.ps1 -DependencyFolder $labSources\PostInstallationActivities\PrepareRootDomain
Add-LabMachineDefinition -Name DDC1 -Roles RootDC -PostInstallationActivity $postInstallActivity

#router
$netAdapter = @()
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch $labName
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch 'External' -UseDhcp
Add-LabMachineDefinition -Name DRouter -Roles Routing -NetworkAdapter $netAdapter

#CA
Add-LabMachineDefinition -Name DCA1 -Roles CaRoot

#DSC Pull Server
$role = Get-LabMachineRoleDefinition -Role DSCPullServer #-Properties @{ DatabaseEngine = 'mdb' }
Add-LabMachineDefinition -Name DPull1 -Roles $role

#DSC Pull Clients
Add-LabMachineDefinition -Name DServer1
Add-LabMachineDefinition -Name DServer2

Install-Lab

Install-LabDscClient -All

Show-LabDeploymentSummary -Detailed