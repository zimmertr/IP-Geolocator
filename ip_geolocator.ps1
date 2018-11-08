#ip_gelocator.ps1 is a geo-location script used for Movere Netstat Auditing. To use, execute this script and provide a parameter that is a absolute path to a CSV dataset.
#This dataset should contain AT LEAST a single column with the heading 'Foreign IP Address' that contains a list of IP Addresses that you wish to geo-locate. 
#Other data will be ignored, and may even slow down the performance of this script. Movere can automatically generate this CSV for you at ARC -> Network -> Netstat. 
Param(
    [Parameter(Mandatory=$True)]
    [string]$csvFile
)
clear
$ErrorActionPreference = "Stop"
Write-Host "Welcome to the Netstat Processing Script. - $(Get-Date -Format T)" -ForegroundColor "Green"; Write-Host

#LIST OF ALLOWED COUNTRIES: Add additional short country codes to the array to expand list of trusted countries. 
#Each country code example should be wrapped in commas to avoid accidental misglobbing of data. 
#For example: BE might accidentally match Berlin Germany if you don't.
$allowedCountries = ",PA,", ",AT,", ",DE,", ",IN,", ",CL,", ",UY,", ",GB,", ",CO,", ",BE,", ",PH,", ",NZ,", ",GT,", ",AF,", ",CR,", ",NG,", ",CW,", ",BB,", ",TT,", ",SA,", ",IT,", ",NL,", ",GG,", ",AU,", ",MX,", ",HN,", ",RO,", ",PK,", ",MO,", ",CA,", ",KH,", ",EG,", ",KW,", ",DK,", ",DO,", ",PR,", ",LB,", ",BR,", ",ZA,", ",AR,", ",CH,", ",IE,", ",TH,", ",FO,", ",PL,", ",FR,", ",ID,", ",MY,", ",QA,", ",WS,", ",US,", ",JO,", ",AE,", ",RU,", ",KR,", ",ES,", ",NP,", ",CN,", ",SV,", ",NO,", ",BS,", ",SG,", ",SR,", ",FI,"
$totalCountries = $allowedCountries.length

#Import all Foreign IP Addresses into a PowerShell array. Ignore unnecessary data and only obtain UNIQUE IPs. 
Write-Host "Importing CSV - Determining Unique IP Addresses and removing unnecessary data. - $(Get-Date -Format T)" -ForegroundColor "Cyan"; Write-Host
$dataset = Import-CSV $csvFile | Select-Object 'Foreign IP Address' -Unique
$totalIPs = $dataset.length

$date = $(Get-Date -Format yyyy-MM-dd_HH-MM-ss)

#Perform a geo lookup on each IP Address in the inputted CSV. Save results to temporary file.
Write-Host "Geolocating IP Addresses. - $(Get-Date -Format T)" -ForegroundColor "Cyan"; Write-Host
foreach ($ip in $dataset) {
    
    $index = $dataset.indexOf($ip) +1

    $actualIP = $($ip -replace '.*=')
    Write-Host "Geolocating $index/$totalIPs`: {$actualIP"
    (Invoke-WebRequest "freegeoip.net/csv/$($ip.'Foreign IP Address')").Content | Out-File -Append -FilePath "$(Get-Location)\RawGeolocationResults_$date.tmp"
}

#Backup temporary file so that user can review it when finished if desired.
Copy-Item -Path "$(Get-Location)\RawGeolocationResults_$date.tmp" -Destination "$(Get-Location)\RawGeolocationResults_$date.txt"

#Analyze resulting Geolookup data for trusted countries, remove all matching lines from dataset. 
Write-Host; Write-Host "Detecting unknown countries. - $(Get-Date -Format T)" -ForegroundColor "Cyan"; Write-Host
foreach ($country in $allowedCountries){
    
    $index = $allowedCountries.indexOf($country) +1
        
    Write-Host "Filtering Results for $country`: $index/$totalCountries"
    (Get-Content "$(Get-Location)\RawGeolocationResults_$date.tmp") -notmatch $country | Set-Content "$(Get-Location)\RawGeolocationResults_$date.tmp"
}

#Remove all empty lines from CSV, remove temporary files.
Write-Host; Write-Host "Trimming Whitespace. - $(Get-Date -Format T)" -ForegroundColor "Cyan"; Write-Host
(gc "$(Get-Location)\RawGeolocationResults_$date.tmp") | ? {$_.trim() -ne "" } | Set-Content "$(Get-Location)\ProcessedGeolocationResults_$date.txt"

Remove-Item "$(Get-Location)\RawGeolocationResults_$date.tmp"

Write-Host; Write-Host "All steps have completed successfully. - $(Get-Date -Format T)" -ForegroundColor "Green"; Write-Host
Write-Host "*************************************************" -ForegroundColor Green
Write-Host; Read-Host -Prompt "Press Enter to open the results"
Start-Process 'C:\windows\system32\notepad.exe' "$(Get-Location)\ProcessedGeolocationResults_$date.txt"
exit 0