<#
.SYNOPSIS
  Function to write logs to HTML file for general error handling @ Sharp HealthCare.
.DESCRIPTION
  Standardized Log Writting Function for Sharp HealthCare
.PARAMETER <Parameter_Name>
  -Level (Mandatory)
        Available Levels : INFO WARN ERROR FATAL DEBUG SUCCES
  -Message (Mandatory)
        String containing Message to write to log
  -LogName (Mandatory)
        Name for logfile being generated. Default Directory c:\ldlogs
  -ComputerName (Optional)
        Specify Remote HostName. Current HostName will be used if not provided.   
.OUTPUTS
  Log file stored in C:\LDlogs\$LogName.html>
.NOTES
  Version:        1.0
  Author:         Thomas Dobson
  Creation Date:  12/12/2017
  Purpose/Change: Initial script development
  
.EXAMPLE
  Log-It "WARN" "INSTALL FAILED. UNABLE TO WRITE TO DIRECTORY" "MyInstaller"
  Log-IT "SUCCESS" "File Copied SuccessFully." "MyInstaller" "IS1713922"
#>
Function Log-It {

	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, Position = 0, HelpMessage = "Log Level")]
		[ValidateSet("INFO", "WARN", "ERROR", "FATAL", "DEBUG", "SUCCESS")]
		[string]$Level = "INFO",
		[Parameter(Mandatory = $true, Position = 1, HelpMessage = "Message to be written to the log")]
		[string]$Message,
		[Parameter(Mandatory = $true, Position = 2, HelpMessage = "Log file location and name")]
		[string]$LogName,
        [Parameter(Mandatory = $false, Position = 3, HelpMessage = "Target PC Asset Tag / Hostname")]
        [String]$computerName
	)

BEGIN {

$initiatingUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>$logName</title>
<link rel="stylesheet" href="C:\LDLogs\Css\logstyle.css">
<script src="script.js"></script>
</head>
<body>
<span class=`"InitHead`">$Stamp $logName Initialied by $initiatingUser</span><br>
</body></html>
"@

$css = @"
.INFO{
  font: 20px;
  font-weight: bold;
  color: Black;
}
.WARN{
  font: 20px;
  font-weight: bold;
  color: RED;
}
.ERROR{
  font: 20px;
  font-weight: bold;
  color: RED;
}
.FATAL{
  font: 20px;
  font-weight: bold;
  color: RED;
}
.DEBUG{
  font: 20px;
  font-weight: bold;
  color: ORANGE;
}
.SUCCESS{
  font: 20px;
  font-weight: bold;
  color: GREEN;
}

.InitHead{
  font-size: 150%;
  font-weight: bold;
}
"@

    	$Stamp = (Get-Date).toString("HH:mm:ss MM/dd/yyyy")

        If(!$computerName){
            $computerName = $env:computername
        }

        $logPath = "\\$computerName\C$\LDLogs\$LogName.html"
        $CSSPath = "\\$computerName\C$\LDLogs\css\logstyle.css"

        If(!(Test-Path($logPath))) {
            New-Item -Path "\\$computerName\C$\LDLogs" -Name "$LogName.html" -ItemType File
            $html | Out-File $logPath
        }

         If(!(Test-Path($CSSPath))) {
            New-Item -Path "\\$computerName\C$\LDLogs\CSS" -Name "logstyle.css" -ItemType File
            $css | Out-File $CSSPath
        }

    }
    PROCESS {
    	If ($logPath) { 

            Switch($Level) {
                "INFO" {AppendToHTMLLog}
                "WARN" {AppendToHTMLLog}
                "ERROR" {AppendToHTMLLog}
                "FATAL" {AppendToHTMLLog}
                "DEBUG" {AppendToHTMLLog}
                "SUCCESS" {AppendToHTMLLog}
            }
	    } Else {
		    Write-Output $Line
	    }
    }
    END {}   
}

Function AppendToHTMLLog {
            
$rawLog = Get-Content $logPath
$rawLog.Replace("</body></html>","$Stamp <span class=`"$level`">$level</span> $message<br></body></html>") | Out-File $logPath

}