<#
.SYNOPSIS
  Configure windows scheduler download task
.DESCRIPTION
  Configue windows scheduler task with the power shell script that downloads the information about deployments from a Azure Devops organization
.EXAMPLE
  C:\PS> ./AzureDEvopsDeploymentsInstaller.ps1
.NOTES
  Author: JM Glez
  CreateDate: 04/21/2020 21:21:13
#>

$currentPath = Get-Location
$trigger = New-JobTrigger -Daily -At "09:00AM"

if (!(Get-ScheduledJob -Name "DownloadAzureDevopsDeployments"))
{
  Register-ScheduledJob -Name "DownloadAzureDevopsDeployments" -FilePath "$currentPath\AzureDevopsDeploymentDownloader.ps1" -Trigger $trigger
}