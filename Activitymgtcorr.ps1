## once in a lifetime you got to do this: 
## Install-Module -Name MicrosoftPowerBIMgmt
## somtimes in a lifetime you got to do this:
## Update-Module -Name MicrosoftPowerBIMgmt
## Depending on your execution policy do not forget to trust the session
## Set-ExecutionPolicy -ExecutionPolicy remotesigned -Scope Process
## Problems: Retry or logout first by Disconnect-PowerBIServiceAccount

## authentication ##
Get-Date
## login to the platform
Login-PowerBI
#Get a token 
$headers = Get-PowerBIAccessToken

#1 recreates all files 0 leaves them and skips
$forcerecreate = 0

#preparing file folder locations
Write-Output "preparing file folder locations"
$stact = "c:\temp\activity"
$storageplaces = $stact
foreach ($FolderPath in $storageplaces)
{
If (-not (Test-Path $FolderPath)) {
    # Folder does not exist, create it
    New-Item -Path $folderPath -ItemType Directory
    Write-host "New Folder Created at '$FolderPath'!" -f Green
}
Else {
    Write-host "Folder '$FolderPath' already exists!" -f yellow
#    Remove-Item ("$FolderPath" + '\*.*') -Force
}
}

#all within this loop runs 
foreach ($number in 1..30) {$dateoffset = ($number * -1)

#$dateoffset = 0
Write-Output $dateoffset

$filepath = (ForEach-Object {'{0}\activity{1}.json' -F $stact, ((get-date).AddDays($dateoffset).ToUniversalTime()).ToString("yyyy-MM-ddT000000001Z") })
Write-Output $filepath

#If file already exists do not target the api anymore just skip unless we force then delete and go for it again, default is dont skip, except when file already exists but if forced dont skip remove the file and go
$skipit = 0
If ( Test-Path($filepath)  ) 
{$skipit = 1 }

If (($forcerecreate -eq 1) -and ( Test-Path($filepath)  )  )
{Remove-Item $filepath 
$skipit = 0
}



If ($skipit -eq 1) 
{Write-Host "Skipped "  $filepath}
else{



#Retrieving a valid date period 
$startdatetime = ((get-date).AddDays($dateoffset).ToUniversalTime()).ToString("\'yyyy-MM-ddT00:00:00.000Z\'")
$enddatetime = ((get-date).AddDays($dateoffset).ToUniversalTime()).ToString("\'yyyy-MM-ddT23:59:59.999Z\'")
#constructing first api url
$uri = (ForEach-Object {'https://api.powerbi.com/v1.0/myorg/admin/activityevents?startDateTime={0}&endDateTime={1}' -F $startdatetime, $enddatetime })   
#Write-Output $uri
#first api call 
$activityresponse = Invoke-RestMethod -Uri $uri -Headers $headers 


# here we should test if the activityEvenEntities is empty, game over for this uri response if there is no data 
if ($activityresponse.activityEventEntities.Count -gt 0) {

#constructing a valid Json from api response and looping thru the continuation tokens
"{ `"all`": [" | Out-File $filepath -Append

#the all construct is the outer construct that will append all activ together
        "{" | Out-File $filepath -Append
        " `"activ`": [" | Out-File $filepath -Append
#the first activityresponse already contains the first chunck of data we have to grab that before looping over

 $maxforeach = $activityresponse.activityEventEntities | measure | % { $_.Count }
    $foreachcounter = 0
    foreach ($activityresent in $activityresponse.activityEventEntities) { 
    $foreachcounter = $foreachcounter + 1
        $activityresent | ConvertTo-Json |  Out-File $filepath -Append
        if ( $foreachcounter -eq  $maxforeach) {} else {
        "," |  Out-File $filepath -Append}      
    }
     if ($activityresponse.lastResultSet.ToString() -eq "False") {     
     " ]}, " | Out-File $filepath -Append # continue in all loop by closing activ: and placing a comma to make it possible to add a new activ:
     } else { 
     " ]} " | Out-File $filepath -Append
     } 
#    Write-Output $activityresponse.lastResultSet
#    Write-Output $activityresponse.continuationUri


While ($activityresponse.lastResultSet.ToString() -eq "False") {
#        "" | Out-File $filepath -Append 
        "{ `"activ`": [" | Out-File $filepath -Append
    $activityresponse = Invoke-RestMethod -Uri $activityresponse.continuationUri -Headers $headers 
#    Write-Output $activityresponse
#    Write-Output $activityresponse.activityEventEntities
    $maxforeach = $activityresponse.activityEventEntities | measure | % { $_.Count }
    $foreachcounter = 0
    foreach ($activityresent in $activityresponse.activityEventEntities) { 
    $foreachcounter = $foreachcounter + 1
        $activityresent | ConvertTo-Json |  Out-File $filepath -Append
        if ( $foreachcounter -eq  $maxforeach) {} else {
        "," |  Out-File $filepath -Append}      
    }
     if ($activityresponse.lastResultSet.ToString() -eq "False") {     
     " ]}, " | Out-File $filepath -Append # continue in all loop by closing activ: and placing a comma to make it possible to add a new activ:
     } else { 
     " ]} " | Out-File $filepath -Append
     } 
#    Write-Output $activityresponse.lastResultSet
#    Write-Output $activityresponse.continuationUri
}
 "] }" | Out-File $filepath -Append #closing all
Write-Output "finished export at UTC time to file location " 
(Get-Date).ToUniversalTime() 
$filepath 
}
}
}