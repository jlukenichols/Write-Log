<#
.SYNOPSIS
  Name: Write-Log.ps1
  The purpose of this script is to write data from a script to a log file
  
.DESCRIPTION
  This script will log 

.NOTES
    Release Date: 2019-12-16T09:22
    Last Updated: 2021-08-13T10:00
    Author: Luke Nichols

    Parameter explanations:
        $LogString is the string that will be submitted to the log file. It is automatically timestamped so do not include date/time info.
        $LogFilePath is the full path to the log **file**, not a folder. Make sure to include the full log file path.
            Note that the log rotation part of the function only expects log files with a file type extension of *.log or *.txt so use one of those.
        $LogRotateDays is the maximum allowed age of a log file before it is deleted. If you do not specify, the default is to never delete log files.
            If you specify 0, it will never delete log files.
            It doesn't really make sense to call this param every time you log a string, so it is recommended to call this at the opening or the closing of the log file only.

.EXAMPLE
  Write-Log -LogString "LastWriteTime of destinationCourseFile: $dateString" -LogFilePath "$LogFileDir\$($currentYear)-$($currentMonth)-$($currentDay)T$($currentHour)$($currentMinute)$($currentSecond).txt" -LogRotateDays 30
#>

#$debugMode = $true

#Define the function that we use for writing to the log file
function Write-Log {
    Param ([string]$LogString, [string]$LogFilePath, [int32]$LogRotateDays)

    #Check to see if the log file path exists. If not, create it.
    if (Test-Path (Split-Path $LogFilePath -Parent)) {
        #Do nothing, folder already exists
    } else {
        $LogFileFolderFullPath = (Split-Path $LogFilePath -Parent)
        $AboveLogFileFolder = (Split-Path $LogFileFolderFullPath -Parent)
        $LogFileFolderOnly = (Split-Path $LogFileFolderFullPath -Leaf)

        New-Item -Path $AboveLogFileFolder -Name $LogFileFolderOnly -ItemType "directory"
    }

    if ($LoggingMode -ne $false) {
        #Generate fresh date info for logging dates/times into log
        $mostCurrentYear = (Get-Date).Year
        $mostCurrentMonth = ((Get-Date).Month).ToString("00")
        $mostCurrentDay = ((Get-Date).Day).ToString("00")
        $mostCurrentHour = ((Get-Date).Hour).ToString("00")
        $mostCurrentMinute = ((Get-Date).Minute).ToString("00")
        $mostCurrentSecond = ((Get-Date).Second).ToString("00")
  
        #Log the content
        $LogContent = "$mostCurrentYear-$mostCurrentMonth-$($mostCurrentDay)T$($mostCurrentHour):$($mostCurrentMinute):$($mostCurrentSecond),$logString"
        Add-Content $LogFilePath -value $LogContent
    }

    if ((!($LogRotateDays)) -or ($LogRotateDays -eq 0)) {
        #Do nothing, log rotation is disabled
    } else {
        #Fetch the current date minus $NumberOfDays
        [DateTime]$limit = (Get-Date).AddDays(-$LogRotateDays)

        #Delete files older than $limit.
        Get-ChildItem -Path $LogFileFolderFullPath | Where-Object { (($_.CreationTime -le $limit) -and (($_.Name -like "*.log*") -or ($_.Name -like "*.txt*"))) } | Remove-Item -Force
    }
}