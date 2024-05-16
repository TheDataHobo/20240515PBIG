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

Write-Output "preparing file folder locations"
$stten = "c:\temp\tennant"

$storageplaces = $stten
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

$filepath = (ForEach-Object {'{0}\TennantSettings{1}.json' -F $stten, ((get-date).AddDays($dateoffset).ToUniversalTime()).ToString("yyyy-MM-ddTHHmmss1Z") })
Write-Output $filepath

Invoke-RestMethod -uri "https://api.fabric.microsoft.com/v1/admin/tenantsettings" -Headers $headers -OutFile $filepath

