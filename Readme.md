# Azure Devops Deployment Information Downloader

This set of scripts facilitates the use of Azure Devops Rest API to download the information related with deployment from every project in an Azure Devops organization. The information is bulked in csv file to be analyzed later using tools as Excel.

## Getting Started

This script uses [Azure Devops Rest Api](https://docs.microsoft.com/en-us/rest/api/azure/devops/?view=azure-devops-rest-5.1) to retrieve the information to deployments performed used Azure Devops Pipelines for an entire organization (every project in an organization). 

In orden to run the script you can do just providing the organization and the [authentication token](https://docs.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/authentication-guidance?view=azure-devops) and by default it retrieves the deployments belonging to the previous natural month (from example, if we run it in April it would retrieve the information from March) and it will store in a folder called "DeploymentsArchive" under the current folder. 

```
.\AzureDevopsDeploymentDownloader.ps1 "myorganization" "myAuthToken"
```

Script also supports to provide them a range of dates and file path where to bulk the information related of the deployment information. 

```
$maxDate = Get-Date
$minDate = $maxDate.AddMonths(-2)
$file = "myfile.csv"
.\AzureDevopsDeploymentDownloader.ps1 "myorganization" "myAuthToken" $minDate $maxDate $file
```


### Prerequisites

The scripts have been built using Powershell 5.0 in a Windows 10 environment.


## Running the tests

Test are based built using [Pester](https://github.com/Pester/Pester) framework. 

Pester comes pre-installed with Windows 10, but we recommend updating, by running this PowerShell command as administrator:

```
Install-Module -Name Pester -Force
```
Test scripts can be executed using the following script:
```
Invoke-Pester -Script .\AzureDevopsDeploymentDownloader.tests.ps1.ps1
```

## Built With

*  [Pester](https://github.com/Pester/Pester) - Testing framework used 
* [PowerRails](https://github.com/misterGF/PowerRails) - Scaffolding for Powershell
* [Psake](https://github.com/psake/psake) - Build tool

