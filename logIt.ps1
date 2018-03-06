#region Log-It Function
<#
.SYNOPSIS
  Function to write logs to HTML file for general error handling @ Sharp HealthCare.
.DESCRIPTION
  Standardized Log Writting Function for Sharp HealthCare
.PARAMETER <Parameter_Name>
  -Level (Mandatory)
        Available Levels : INFORM WARN ERROR FATAL DEBUG SUCCES
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
  Change Date:    3/6/2017
  Purpose/Change: Improved Logging. Bug Fixes.
  
.EXAMPLE
  Log-It "WARN" "INSTALL FAILED. UNABLE TO WRITE TO DIRECTORY""MyInstaller"
  Log-IT "SUCCESS" "File Copied SuccessFully." "MyInstaller" "IS1713922"
  Log-IT "FATAL" "This Error Happened" "MyScript" -intializeNewLog $true
#>
Function Log-It
{
	
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, Position = 0, HelpMessage = "Log Level")]
		[ValidateSet("INFORM", "WARN", "ERROR", "FATAL", "DEBUG", "SUCCESS")]
		[string]$Level = "INFORM",
		[Parameter(Mandatory = $true, Position = 1, HelpMessage = "Message to be written to the log")]
		[string]$Message,
		[Parameter(Mandatory = $true, Position = 2, HelpMessage = "Log file location and name")]
		[string]$LogName,
		[Parameter(Mandatory = $false, Position = 4, HelpMessage = "Target PC Asset Tag / Hostname")]
		[Bool]$intializeNewLog = $false,
		[Parameter(Mandatory = $false, Position = 3, HelpMessage = "Target PC Asset Tag / Hostname")]
		[String]$computerName
	)
	
	#region variables
	$initiatingUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name
	
	$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>$logName</title>
<link rel="stylesheet" href="C:\LDLogs\Css\logstyle.css">
</head>
<body>
</body></html>
"@
	
	$css = @"
/*v1.1*/

#INFORM{
  font: 20px;
  font-weight: bolder;
  color: BLACK;
}

#WARN{
  font: 20px;
  font-weight: bolder;
  color: ORANGE;
}

#ERROR{
  font: 20px;
  font-weight: bolder;
  color: RED;
}
#FATAL{
  font: 20px;
  font-weight: bolder;
  color: RED;
}

#DEBUG{
  font: 20px;
  font-weight: bolder;
  color: BLUE;
}

#SUCCESS{
  font: 20px;
  font-weight: bolder;
  color: GREEN;
}

#header{
  font-size: 1.5em;
  font-weight: bold;
}
"@
	
	$Stamp = (Get-Date).toString("HH:mm:ss MM/dd/yyyy")
	
	If (!$computerName)
	{
		$computerName = $env:computername
	}
	
	$logPath = "\\$computerName\C$\LDLogs\$LogName.html"
	$CSSPath = "\\$computerName\C$\LDLogs\css\logstyle.css"
	
	#endregion
	
	Function AppendToHTMLLog
	{
		
		$htmlClosure = "</body></html>"
		$htmlHeader = "<p id=`"header`">[$Stamp] $logName Initialied by $initiatingUser</p>"
		$htmlSpacers = "<p>****************************************************************************</p>"
		$htmlLogger = "[$Stamp]<span id=`"$level`">&nbsp&nbsp$level&nbsp&nbsp</span> $message<br>"
		
		$rawLog = Get-Content $logPath
		if ($intializeNewLog)
		{
			$rawLog.Replace("</body></html>", "$htmlSpacers$htmlHeader$htmlSpacers$htmlLogger$htmlClosure") | Out-File $logPath
		}
		else
		{
			$rawLog.Replace("</body></html>", "$htmlLogger$htmlClosure") | Out-File $logPath
		}
		
	}
	
	#Generate New CSS
	function createCSS
	{
		New-Item -Path "\\$computerName\C$\LDLogs\CSS" -Name "logstyle.css" -ItemType File
		$css | Out-File $CSSPath
	}
	
	
	#If specified logfile doesn't exist; create it.
	If (!(Test-Path($logPath)))
	{
		New-Item -Path "\\$computerName\C$\LDLogs" -Name "$LogName.html" -ItemType File
		$html | Out-File $logPath
	}
	
	#check logfile versioning. Remove old logs. Generate / Replace CSS.
	$cssExists = Test-Path($CSSPath)
	if ($cssExists)
	{
		
		$cssversion = (Get-Content C:\ldlogs\css\logstyle.css -First 1).Substring(3, 3)
		$currentVersion = "1.0"
		if ($cssversion -ne $currentVersion)
		{
			Remove-Item -Path $CSSPath -Force
			createCSS
		}
		
	}
	else
	{
		createCSS
	}
	
	#Write to Logs
	If ($logPath)
	{
		
		Switch ($Level)
		{
			"INFORM" { AppendToHTMLLog }
			"WARN" { AppendToHTMLLog }
			"ERROR" { AppendToHTMLLog }
			"FATAL" { AppendToHTMLLog }
			"DEBUG" { AppendToHTMLLog }
			"SUCCESS" { AppendToHTMLLog }
		}
	}
	Else
	{
		Write-Output $Line
	}
	
}



#endregion
