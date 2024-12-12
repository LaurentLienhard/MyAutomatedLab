$LabName = "MyTestLab"
$DomainName = "contoso.local"
$DomainAdministrator = "Administrator"
$DomainPassword = "Passw0rd"
$VmPath = Join-Path -Path "C:\LabSources\Labs" -ChildPath $LabName
$VirtualEngine = "HyperV"

New-LabDefinition -Name $LabName -DefaultVirtualizationEngine $VirtualEngine -VmPath $VmPath

Add-LabVirtualNetworkDefinition -Name $LabName -AddressSpace 10.1.0.0/16

Add-LabMachineDefinition -Name DC1 -Memory 2GB -OperatingSystem 'Windows Server 2022 Standard (Desktop Experience)' -Roles RootDC -DomainName contoso.com -Network $LabName -ToolsPath "$labSources\Tools" 
#Add-LabMachineDefinition -Name Client1 -Memory 4GB -OperatingSystem 'Windows 11 Enterprise' -DomainName contoso.com -Network $LabName -ToolsPath "$labSources\Tools" 

Install-Lab

Show-LabDeploymentSummary -Detailed