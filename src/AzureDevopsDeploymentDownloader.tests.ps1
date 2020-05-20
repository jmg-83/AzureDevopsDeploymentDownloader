# Pester testing. https://github.com/pester/Pester/wiki
$myModule = "$PSScriptRoot\AzureDevopsDeploymentDownloader.psm1"
$myScript = "$PSScriptRoot\AzureDevopsDeploymentDownloader.ps1"

$azureDevosOrganization = 'myOrganization'
$azureDevopsAuthenticationHeader = 'Basic AuthHeader'

Describe 'Get-AzureDevopsProjects' {
  Context 'Successful execution' {
    it 'Should list a set of Azure Devops projects' {
      if ($myModule -like '*ps1') {
        $runCommand = invoke-expression $myModule
      } else {
        import-module $myModule
        $runCommand = Get-AzureDevopsProjects $azureDevosOrganization $azureDevopsAuthenticationHeader
      }

      $projects = $runCommand 
      $projects.count | Should BeGreaterThan 0
    }
  }
}

Describe 'Get-AzureDevopsDeployments' {
  Context 'Successful execution' {
    it 'Should list a set of Azure Devops deployment belonging to specific project without using range dates' {
      if ($myModule -like '*ps1') {
        $runCommand = invoke-expression $myModule
      } else {
        import-module $myModule
        $runCommand = Get-AzureDevopsDeployments $azureDevosOrganization $azureDevopsAuthenticationHeader "Acehub"
      }

      $deployments = $runCommand 
      $deployments.count | Should BeGreaterThan 0
    }
    it 'Should list a set of Azure Devops deployment belonging to specific project a range of dates' {
      if ($myModule -like '*ps1') {
        $runCommand = invoke-expression $myModule
      } else {
        import-module $myModule

        <# The range of dates contains the last coupld of months#>
        $maxDate = Get-Date
        $minDate = $maxDate.AddMonths(-2)

        $runCommand = Get-AzureDevopsDeployments $azureDevosOrganization $azureDevopsAuthenticationHeader "Acehub" $minDate $maxDate
      }

      $deployments = $runCommand 
      $deployments.count | Should BeGreaterThan 0
    }
  }
}

Describe 'Run-AzureDevopsDeploymentDownloader' {
  Context 'Successful execution' {
    it 'Should download the list of deployments of the previous month and stores it in a csv' {
      
      Get-ChildItem * -Include *.csv -Recurse | Remove-Item

      $createdFile = & $myScript $azureDevosOrganization $azureDevopsAuthenticationHeader
      Test-Path $createdFile  | Should Be $true

      Get-ChildItem * -Include *.csv -Recurse | Remove-Item
    }
    it 'Should download the list of deployments belonging to date range and stores it in a csv ' {
      Get-ChildItem * -Include *.csv -Recurse | Remove-Item

      <# The range of dates contains the last coupld of months#>
      $maxDate = Get-Date
      $minDate = $maxDate.AddMonths(-2)
      $file = [guid]::NewGuid().ToString() + ".csv"

      $createdFile = & $myScript $azureDevosOrganization $azureDevopsAuthenticationHeader $minDate $maxDate $file
      Test-Path $createdFile  | Should Be $true

      Get-ChildItem * -Include *.csv -Recurse | Remove-Item
    }
  }
}