## once in a lifetime you got to do this: 
## Install-Module -Name MicrosoftPowerBIMgmt
## somtimes in a lifetime you got to do this:
## Update-Module -Name MicrosoftPowerBIMgmt
## Depending on your execution policy do not forget to trust the session
## Set-ExecutionPolicy -ExecutionPolicy remotesigned -Scope Process
## Problems: Retry or logout first by Disconnect-PowerBIServiceAccount


## login to the platform
Login-PowerBI
#Get a token 
$headers = Get-PowerBIAccessToken

#Fill in your workspace and dataset id below
$workspaceid = '74601087-ad5e-481c-a20c-1965baa8607b'
$datasetid = '987940b7-de26-4635-af74-e0a87d8022e9' 
#there are way more parameters possible here, so have a look at the docs to review
#https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/refresh-dataset
#https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/refresh-dataset-in-group
$Body = @{retryCount=1} | ConvertTo-Json

#refresh dataset
#in case of a normal workspace take below
#$uri = (ForEach-Object {'https://api.powerbi.com/v1.0/myorg/groups/{0}/datasets/{1}/refreshes' -F $workspace.Id, $datasetid }) 
#in case of a my workspace take below
$uri = (ForEach-Object {'https://api.powerbi.com/v1.0/myorg/datasets/{0}/refreshes' -F  $datasetid }) 

Invoke-RestMethod -Uri $uri -Body $body -Method 'POST' -Headers $headers

