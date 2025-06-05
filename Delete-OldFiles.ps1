<#
.SYNOPSIS
  Name: Delete-OldFiles.ps1
  The purpose of this script is to clean up old log files
  
.DESCRIPTION
  This script will look at the logs in $PathToLogs and delete any older than $NumberOfDays

.NOTES
    Release Date: 2018-08-14T09:36:00-4
    Last Updated: 2025-06-05T17:35:00Z
   
    Author: Luke Nichols

.EXAMPLE
  Delete-OldFiles -NumberOfDays 90 -PathToFiles "$($myPSScriptRoot)\logs" -FileTypeExtensions @(".csv",".log",".txt")
#>

#Define the function to clean up old log files
Function Delete-OldFiles {
    param (
      # Maximum age of a file, in days, before we delete it
      [int]$NumberOfDays,
      # Path to the folder containing the files
      [string]$PathToFiles,
      # Array of filetype extensions to find and delete, MUST include the "."
      ## NOTE: This pattern is a fuzzy match both before and after, so if you pass in ".txt" it will match on a filename like "file.txt.old".
      ## ... This was not a problem for my use case, but it might be for yours.
      [string[]]$FileTypeExtensions = @(".log",".txt")
    )

    #Fetch the current date minus $NumberOfDays
    [DateTime]$limit = (Get-Date).AddDays(-$NumberOfDays)

    # Build our regex pattern
    [regex]$Regex = "($(($FileTypeExtensions.ForEach({[regex]::escape($_)}) –join '|')))"

    #Delete files older than $limit.
    Get-ChildItem -Path $PathToFiles | Where-Object {(($_.CreationTime -le $limit) -and ($_.Name -match "$Regex"))} | Remove-Item -Force
}
