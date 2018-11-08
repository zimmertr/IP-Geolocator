# IP Geolocator

## Summary

Have a lot of abnormal traffic on your network? Able to retrieve their IP Addresses? IP Geolocator is a Geo-Location script used for Netstat Auditing.

## Instructions

1) Generate a CSV file with the heading `Foreign IP Address` that contains a list of IP Addresses to geolocate.

2) Execute script and pass your CSV as arguement: `.\ip_geolocator.ps1 .\dataset.csv`
  
3) The script will geolocate each IP and save it to a temporary file. This file will be compared against the trusted countries provided in an array list in the source code.

4) All rows in the CSV containing a trusted country will be removed. 

5) The resultant dataset as well as the raw datasets will be left in the same directory from which you executed this script. 

6) Optionally modify the array in `parse_netstat_report.ps1` to contain a list of IP Addresses you consider to be whitelisted.

6) Pass the geolocated dataset as a parameter to the next script: `.\parse_netstat_report.ps1 .\ProcessedGeolocationResults_##.csv`

7) This script will parse your geolocation results and remove all whitelisted entries. And created a final dataset named `Parsed_Dataset.csv` that you can view to continue your audit.
