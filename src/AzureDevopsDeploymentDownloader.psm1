function Get-AzureDevopsProjects{
<#
  .SYNOPSIS
  Functions that return the information related with all the project in an Azure Devops organization.

.OUTPUTS
  https://docs.microsoft.com/en-us/rest/api/azure/devops/core/projects/list?view=azure-devops-rest-5.1#teamprojectreference

.EXAMPLE
  Get-AzureDevopsProjects "payvision" 'Basic 123456M6Z3Rkd3FkNGF4dDXXXXXXNjQ3bXhwZXo3ZmtqemdqZWZnM2ljNmlrZHd0ZjJ1cWtxbTV5cQ=='

.LINK
  https://docs.microsoft.com/en-us/rest/api/azure/devops/core/projects/list?view=azure-devops-rest-5.1
#>
  [cmdletbinding()]
  [OutputType([String])]
  [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
  param(
    [Parameter(Mandatory=$true
    , HelpMessage = 'Name of the organization defined in Azure Devops')
    ]
    [string]$organization
    , [Parameter(Mandatory=$true
    , HelpMessage = 'Token registered in Azure Devops used interact with its Rest API')
    ]
    [string]$authHeader
  )
  $apiversion = "5.1"
  $azureDevopsOrganizationUri = "https://dev.azure.com/$organization/_apis/projects?api-version=$apiversion"

  # Retrieve list of proejcts 
  return Invoke-RestMethod -Uri $azureDevopsOrganizationUri -Method get -Headers @{Authorization = $authHeader}
}

function Get-AzureDevopsDeployments
{
  <#
  .SYNOPSIS
  Functions that return the information related with all the deployments an Azure Devops project.

.OUTPUTS
  https://docs.microsoft.com/en-us/rest/api/azure/devops/release/deployments/list?view=azure-devops-rest-5.1#deployment

.EXAMPLE
  Get-AzureDevopsDeployments "payvision" 'Basic 123456M6Z3Rkd3FkNGF4dDXXXXXXNjQ3bXhwZXo3ZmtqemdqZWZnM2ljNmlrZHd0ZjJ1cWtxbTV5cQ==' 'myproject'

.LINK
 https://docs.microsoft.com/en-us/rest/api/azure/devops/release/deployments/list?view=azure-devops-rest-5.1
#>
  [cmdletbinding()]
  [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
  param(
    [Parameter(Mandatory=$true
    , HelpMessage = 'Name of the organization defined in Azure Devops')
    ]
    [string]$organization
    ,[Parameter(Mandatory=$true
    , HelpMessage = 'Token registered in Azure Devops used interact with its Rest API')
    ]
    [string]$authHeader
    ,[Parameter(Mandatory=$true
    , HelpMessage = 'Azure Devops project query to list the deployments ')
    ]
    [string]$project
    ,[Parameter(Mandatory=$false
    , HelpMessage =  'Floor date of the range of deployments retrieved')
    ]
    [AllowNull()] 
    [Nullable[DateTime]] $minDate 
    ,[Parameter(Mandatory=$false
    , HelpMessage =  'Ceiling date of the range of deployments retrieved')
    ]
    [AllowNull()] 
    [Nullable[DateTime]] $maxDate
  )

  $apiversion = "5.1"

  if ($null -eq $minDate)
  {
    $minDate = [DateTime]::MinValue
  }

  if ($null -eq $maxDate)
  {
    $maxDate = [DateTime]::MaxValue
  }

  $deployments = New-Object System.Collections.ArrayList
  $continuationToken = '0'
      
   DO
   {
      $azureDevopsDeploymentsUri = "https://vsrm.dev.azure.com/$organization/$project/_apis/release/deployments?api-version=$apiversion&minStartedTime=$minDate&maxStartedTime=$maxDate&continuationToken=$continuationToken"

      $webResponse = Invoke-WebRequest -Uri $azureDevopsDeploymentsUri -Method get -Headers @{Authorization = $authHeader} 
      
      if($webResponse.StatusCode -eq 200){

         $continuationToken = $webResponse.Headers['x-ms-continuationtoken']
         $deploymentPerProject = $webResponse | Select-Object -Expand Content | ConvertFrom-Json | Select-Object value

         if($deploymentPerProject.value.Length -ne 0){
            $deployments.AddRange($deploymentPerProject.value)     
          }  
      }
   } While((-not ([string]::IsNullOrEmpty($continuationToken))) -and ($webResponse.StatusCode -eq 200))

   return $deployments
}

function Convert-DevopsDeployments
{
  [cmdletbinding()]
  [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
  param(
    [Parameter(Mandatory=$true
    , HelpMessage = 'Name of the project in Azure Devops of those deployments')
    ]
    [string]$projectName
    , [Parameter(Mandatory=$true
    , HelpMessage = 'List of deployments in an Azure Devops project')
    ]
    $deployment
  )

    return New-Object psobject -Property @{
      id = $deployment.id
      releaseId = $deployment.release.id
      releaseName = $deployment.release.name
      releaseUrl = $deployment.release.webAccessUri
      releaseDefinitionId = $deployment.releaseDefinition.id
      releaseDefinitionName = $deployment.releaseDefinition.name            
      releaseEnvironmentId = $deployment.releaseEnvironment.id
      releaseEnvironmentName = $deployment.releaseEnvironment.name
      projectName = $projectName
      attempt = $deployment.attempt
      reason = $deployment.reason
      deploymentStatus = $deployment.deploymentStatus
      operationStatus = $deployment.operationStatus
      requestedByName = $deployment.requestedBy.uniqueName
      requestedForName = $deployment.requestedFor.uniqueName
      queueOn = $deployment.queuedOn
      startedOn = $deployment.startedOn
      completedOn = $deployment.completedOn
      lastModifiedOn = $deployment.lastModifiedOn
      lastModifiedBy = $deployment.lastModifiedBy.displayName 
      preDeploymentApprovals = ConvertTo-Json $deployment.preDeployApprovals -Compress
      postDeploymentApprovals = ConvertTo-Json $deployment.postDeployApprovals -Compress
      artifacts = ConvertTo-Json $deployment.release.artifacts -Compress
   };
}

function Export-DeploymentsToCsv {
  param (
    [Parameter(Mandatory=$true
    , HelpMessage =  'Full file path where the csv is created')
    ] 
    [string] $file,
    [Parameter(Mandatory=$true
    , HelpMessage =  'Object with information of the deployments which they will be bulked into the csv')
    ] 
    [System.Collections.ArrayList] $deployments
  )
  
  $deployments | 
  Select-Object -Property id, releaseId, releaseName, releaseUrl, releaseDefinitionId, releaseDefinitionName, releaseEnvironmentId, releaseEnvironmentName, projectName, attempt, reason, deploymentStatus, operationStatus, requestedByName, requestedForName, queueOn, startedOn, completedOn, lastModifiedOn, lastModifiedBy, preDeploymentApprovals, postDeploymentApprovals, artifacts |
  Export-Csv -Path $file -NoTypeInformation
}

# Export functions
Export-ModuleMember -Function *
