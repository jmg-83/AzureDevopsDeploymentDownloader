<#
.SYNOPSIS
  Bulks into a csv all the information related with Deployments from an Azure Devops organization
.DESCRIPTION
  This scripts connects to one Azure Devops organization and retrieve the information of every deployment during a period of time and bulk th informaton
.EXAMPLE
  C:\PS> ./AzureDevopsDeploymentDownloader.ps1 "payvision" 'Basic 123456M6Z3Rkd3FkNGF4dDXXXXXXNjQ3bXhwZXo3ZmtqemdqZWZnM2ljNmlrZHd0ZjJ1cWtxbTV5cQ==' 'myproject'
.NOTES
  Author: JM Glez
  CreateDate: 04/21/2020 21:21:13
#>

Param
(
  [Parameter(Mandatory=$true)]
  [ValidateNotNullOrEmpty()]
  [string]$azureDevosOrganization,
  [Parameter(Mandatory=$true)]
  [ValidateNotNullOrEmpty()]
  [string]$azureDevopsAuthenticationHeader,
  [AllowNull()] 
  [Nullable[DateTime]]$minDate,
  [AllowNull()] 
  [Nullable[DateTime]]$maxDate,
  [AllowNull()] 
  [string]$filePath
)

function Get-FileName {
  param (
    [Parameter(Mandatory=$true
    , HelpMessage =  'Floor date of the range of deployments retrieved')
    ] 
    [datetime] $date
  )

  $folder = ".\DeploymentsArchive"
  
  If (!(Test-Path $folder))
  {
    New-Item $folder -itemtype directory
  }

  $file = Join-Path $folder $date.tostring("yyyy-MMM")
  $file = $file + ".csv"

  return $file
}

if ($null -eq $minDate)
{
  $minDate = (Get-Date -day 1 -hour 0 -minute 0 -second 0).AddMonths(-1)
}

if ($null -eq $maxDate)
{
  $maxDate = (($minDate).AddMonths(1).AddSeconds(-1))
}

if ([string]::IsNullOrEmpty($filePath))
{
  $filePath = Get-FileName $minDate
}

If (Test-Path $filePath)
{
  return $filePath
}

Get-ChildItem -recurse -include '*.psm1' | Import-Module

# Retrieve list of projects 
$projects =  Get-AzureDevopsProjects $azureDevosOrganization $azureDevopsAuthenticationHeader

$deployments = New-Object System.Collections.ArrayList
foreach($project in $projects.value.name){
  $rawDataOfDeployments =  Get-AzureDevopsDeployments $azureDevosOrganization $azureDevopsAuthenticationHeader $project $minDate $maxDate
  
  foreach($rawDataOfDeployment in $rawDataOfDeployments)
  {
    $deployment = Convert-DevopsDeployments $project $rawDataOfDeployment
    $deployments.Add($deployment) > $null
  } 
}

Export-DeploymentsToCsv $filePath $deployments

return $filePath
