## once in a lifetime you got to do this: 
## Install-Module -Name MicrosoftPowerBIMgmt
## somtimes in a lifetime you got to do this:
## Update-Module -Name MicrosoftPowerBIMgmt
## Depending on your execution policy do not forget to trust the session
## Set-ExecutionPolicy -ExecutionPolicy remotesigned -Scope Process
## Problems: Retry or logout first by Disconnect-PowerBIServiceAccount

Write-Output "preparing file folder locations"
$stdat = "c:\temp\datasets"
$stref = "c:\temp\refreshes"
$stwor = "c:\temp\workspaces"
$strep = "c:\temp\reports"
$stusr = "c:\temp\users"
$stgat = "c:\temp\gateways"
$stdds = "c:\temp\datasources"
$stres = "c:\temp\refreshschedule"

$storageplaces = $stdat,$stref,$stwor,$strep,$stusr,$stgat,$stdds,$stres
foreach ($FolderPath in $storageplaces)
{
If (-not (Test-Path $FolderPath)) {
    # Folder does not exist, create it
    New-Item -Path $folderPath -ItemType Directory
    Write-host "New Folder Created at '$FolderPath'!" -f Green
}
Else {
    Write-host "Folder '$FolderPath' already exists!" -f yellow
    Remove-Item ("$FolderPath" + '\*.*') -Force
}
}

## get both datasets and their refureshes ##
Get-Date
## login to the platform
Login-PowerBI
#Get a token 
$headers = Get-PowerBIAccessToken
#clear previous

# List the full list of workspaces
$workspaces = Get-PowerBIWorkspace | Select-Object -Property Name,Id 

Write-Output "Retrieving datasets and their latest refreshes"
foreach ($workspace in $workspaces){ 
#concaternating the workspaceid caused spaces in the url and filepath, solved with this ForEach-Object though it does not feel quite elegant  
$filepath = (ForEach-Object {'{0}\datasets{1}.csv' -F $stdat, $workspace.Id })
Write-Output $filepath
$exportheader = "WorkspaceId,DatasetId,Name,ConfiguredBy,UpstreamDatasets,CreatedDate,IsOnPremGatewayRequired,Description" 
$exportheader| Out-File $filepath -Append
$uri = (ForEach-Object {'https://api.powerbi.com/v1.0/myorg/groups/{0}/datasets' -F $workspace.Id })   
try { 
$datasets = Invoke-RestMethod -Uri $uri -Headers $headers
  Write-Output $datasets
foreach ($dataset in $datasets.value) { 
 $exportlines = "$($workspace.Id),$($dataset.id),$($dataset.name),$($dataset.configuredBy),$($dataset.upstreamDatasets),$($dataset.createdDate),$($dataset.isOnPremGatewayRequired),$($dataset.isRefreshable),$($dataset.description)" 
 $exportlines| Out-File $filepath -Append

 #if ($dataset.isRefreshable -eq "True" ) {
 try {
  $refreshfilepath = (ForEach-Object {'c:\temp\refreshes\refresh{0}.json' -F $dataset.id })
  $urirefresh = (ForEach-Object {'https://api.powerbi.com/v1.0/myorg/datasets/{0}/refreshes?$top=1' -F $dataset.id })
  Write-Output $urirefresh
  Invoke-RestMethod -Uri $urirefresh -Headers $headers -Method GET -OutFile $refreshfilepath
   $refreshresult =  Invoke-RestMethod -Uri $urirefresh -Headers $headers -Method GET
     }
  catch{Write-Output  "try failed to get dataset refresh of $($dataset.id)"} 
#datasources based on datasets  
  try {
  $datasourcefilepath = (ForEach-Object {'{0}\datasource{1}.json' -F $stdds, $dataset.id })
  $urirefresh = (ForEach-Object {'https://api.powerbi.com/v1.0/myorg/datasets/{0}/datasources' -F $dataset.id })
  Write-Output $urirefresh
  Invoke-RestMethod -Uri $urirefresh -Headers $headers -Method GET -OutFile $datasourcefilepath

     }
  catch{Write-Output  "try failed to get datasource of $($dataset.id)"} 
# https://api.powerbi.com/v1.0/myorg/datasets/{datasetId}/refreshSchedule to get the refresh schedule

 try {
  $datasourcefilepath = (ForEach-Object {'{0}\refreshschedule{1}.json' -F $stres, $dataset.id })
  $urirefresh = (ForEach-Object {'https://api.powerbi.com/v1.0/myorg/datasets/{0}/refreshSchedule' -F $dataset.id })
  Write-Output $urirefresh
  Invoke-RestMethod -Uri $urirefresh -Headers $headers -Method GET -OutFile $datasourcefilepath
     }
  catch{Write-Output  "try failed to get refresh schedule of datasource of $($dataset.id)"} 
}
}
catch {Write-Output  "try failed to get dataset info for workspace $($workspace.Id) "}}

Write-Output "Retrieving workspaces"
#clear previous
Remove-Item c:\temp\workspaces\*.*  -Force
Remove-Item c:\temp\reports\*.*
# List the full list of workspaces
 Get-PowerBIWorkspace |  Export-csv C:\temp\workspaces\workspaces.csv

 Write-Output "Retrieving reports"
foreach ($workspace in $workspaces){ 
#concaternating the workspaceid caused spaces in the url and filepath, solved with this ForEach-Object though it does not feel quite elegant  
$filepath = (ForEach-Object {'C:\temp\reports\reports{0}.json' -F $workspace.Id })
try {  Invoke-PowerBIRestMethod -Url (ForEach-Object {'https://api.powerbi.com/v1.0/myorg/groups/{0}/reports' -F $workspace.Id }) -Method GET | Out-File $filepath -Append
#Invoke-PowerBIRestMethod -Url (ForEach-Object {'https://api.powerbi.com/v1.0/myorg/groups/{0}/reports' -F "75dfe697-ed75-4a29-892c-60acfd155569" }) -Method GET

}
catch {Write-Output  "try failed"}}

#clear previous
Remove-Item  ("$stusr" + '\*.*') -Force

#Retrieving workspace users
Write-Output "Retrieving workspace users"
foreach ($workspace in $workspaces){  
$filepath = (ForEach-Object {'{0}\users{1}.json' -F $stusr, $workspace.Id })
#try  { Invoke-RestMethod -Headers $headers -Uri 'https://api.powerbi.com/v1.0/myorg/groups/' + $workspace.Id + '/users' }
#try { Invoke-RestMethod -Headers $headers -Uri  (ForEach-Object {'https://api.powerbi.com/v1.0/myorg/groups/{0}/users' -F $workspace.Id })  Out-File C:\temp\users.json -Append
try {  Invoke-PowerBIRestMethod -Url (ForEach-Object {'https://api.powerbi.com/v1.0/myorg/groups/{0}/users' -F $workspace.Id }) -Method GET | Out-File $filepath -Append
}
catch {Write-Output  "try failed"}}

# List the full list gateways 
 $uri = (ForEach-Object {'https://api.powerbi.com/v1.0/myorg/gateways' })   
try { 
$gateways = Invoke-RestMethod -Uri $uri -Headers $headers
}
catch {Write-Output "try failed"}
  Write-Output $gateways

Get-Date