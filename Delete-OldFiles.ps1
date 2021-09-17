<#
.SYNOPSIS
  Name: Delete-OldFiles.ps1
  The purpose of this script is to clean up old log files
  
.DESCRIPTION
  This script will look at the logs in $PathToLogs and delete any older than $NumberOfDays

.NOTES
    Release Date: 2018-08-14T09:36
    Last Updated: 2019-09-06T14:02
   
    Author: Luke Nichols

.EXAMPLE
  Delete-OldFiles -NumberOfDays 90 -PathToLogs "$($myPSScriptRoot)\logs"
#>

#Define the function to clean up old log files
Function Delete-OldFiles {
    param ([int]$NumberOfDays, [string]$PathToLogs)

    #Fetch the current date minus $NumberOfDays
    [DateTime]$limit = (Get-Date).AddDays(-$NumberOfDays)

    #Delete files older than $limit.
    Get-ChildItem -Path $PathToLogs | Where-Object { (($_.CreationTime -le $limit) -and (($_.Name -like "*.log*") -or ($_.Name -like "*.txt*"))) } | Remove-Item -Force
}