Param(
	[Parameter(Mandatory=$True)]
	[string]$Path
)


#################################################################################
#List all TRUSTED IP Addresses here. Each line, except the last, must end with `#
#################################################################################
$trustedIPs = `
"104.129.196.125" `
,"104.129.196.202" `
,"104.129.196.79"
#################################################################################


clear
$ErrorActionPreference = "Stop" #Automatically exit script in the event of an unhandled exception.
Write-Host "Welcome to the Netstat Processing Script. - $(Get-Date -Format T)" -ForegroundColor "Green"; Write-Host


If (-Not (Test-Path -Path $Path)) {
	"File '$Path' not found!" | Write-Error
	Exit 1
}


Write-Host "Importing Dataset - $(Get-Date -Format T)" -ForegroundColor "Cyan"; Write-Host
$rawDataset = Import-Csv $Path


Write-Host "Processing Dataset - $(Get-Date -Format T)" -ForegroundColor "Cyan"; Write-Host
foreach ($i in $trustedIPs){
    
    $rawDataset = $rawDataset | where {$_."Foreign IP Address" -notcontains $i}

}


Write-Host "Exporting Dataset - $(Get-Date -Format T)" -ForegroundColor "Cyan"; Write-Host
$processedDataset = $rawDataset
$processedDataset | Export-Csv -Path C:\Users\$(env:USERNAME)\Desktop\Parsed_Dataset.csv -Encoding ascii


Write-Host "Enumerating Untrusted IPs - $(Get-Date -Format T)" -ForegroundColor "Cyan"; Write-Host
$numIPs = $($processedDataset | Measure-Object).Count


Write-Host "Processing is complete. $numIPs Untrusted IP Addresses Were Detected. Please review resulting CSV dataset. - $(Get-Date -Format T)" -ForegroundColor "Green"; Write-Host
Write-Host "*************************************************" -ForegroundColor "Green"
Write-Host; Read-Host -Prompt "Press Enter to exit"
