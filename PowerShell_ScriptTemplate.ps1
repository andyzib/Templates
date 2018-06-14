#requires -version 5
<#
.SYNOPSIS
<Overview of script>
 
.DESCRIPTION
<Brief description of script>
 
.PARAMETER <Parameter_Name>
<Brief description of parameter input required. Repeat this attribute if required>
 
.INPUTS
<Inputs if any, otherwise state None>
 
.OUTPUTS
<Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
 
.NOTES
Version:        0.1
Author:         <Name>
Creation Date:  <Date>
Purpose/Change: Initial script development
 
.EXAMPLE
<Example goes here. Repeat this attribute for more than one example>
#>
 
#-------------[Parameters]-----------------------------------------------------
# Enable -Debug, -Verbose Parameters. Write-Debug and Write-Verbose!
#[CmdletBinding()]
 
<#
Param (
    [Parameter(Mandatory=$true)][string]$csv = $( Read-Host "Enter path and filename to CSV file"),
    [Parameter()][string]$outdir = "$($env:USERPROFILE)\Documents",
    [Parameter()][string]$outstring = "Example"
)
#>
 
#-------------[Parameter Validation]-------------------------------------------
# Sanitize User Input
 
<#
# Check that the CSV file exists.
$csv = $csv.Trim()
if (-Not (Test-Path -PathType Leaf -Path $csv)) {
    Throw "CSV not found: $csv"
}
#>
 
<#
# Strip trailing \ from $outdir
$outdir = $outdir.Trim()
$outdir = $outdir.TrimEnd("\")
# Check that outdir exists.
if (-Not (Test-Path -PathType Container -Path $outdir)) {
    Throw "Output directory note found: $outdir"
}
#>
 
<#
# Strip illegal file name characters with a RegEx.
# https://gallery.technet.microsoft.com/scriptcenter/Remove-Invalid-Characters-39fa17b1
$outstring = [RegEx]::Replace($outstring, "[{0}]" -f ([RegEx]::Escape([String][System.IO.Path]::GetInvalidFileNameChars())), '')
#>
 
#-------------[Initializations]------------------------------------------------
 
#Set Error Action to Silently Continue
#$ErrorActionPreference = "SilentlyContinue"
 
#Import-Module activedirectory -ErrorAction Stop
 
#-------------[Declarations]---------------------------------------------------
 
#Script Version
#$sScriptVersion = "0.1"
 
#Log File Info
#$sLogPath = "C:\Windows\Temp"
#$sLogName = "<script_name>.log"
#$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
 
# ISO 8601 Date Format. Accept no substitutes! 
$iso8601 = Get-Date -Format s
# Colon (:) isn't a valid character in file names.
$iso8601 = $iso8601.Replace(":","_")
# Just YYYY-MM-DD
#$datestamp = $iso8601.Substring(0,10)
 
#-------------[Functions]------------------------------------------------------
 
<#
 
Function <FunctionName>{
  Param()
 
  Begin{
    Log-Write -LogPath $sLogFile -LineValue "<description of what is going on>..."
  }
 
  Process{
    Try{
      <code goes here>
    }
   
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
 
  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
    }
  }
}
 
#>
 
#-------------[Execution]------------------------------------------------------
 
Start-Transcript -Path "$($env:USERPROFILE) + \$($iso8601)_PowershellTranscript.txt"
 
<# Pseudocode
 
Logic, flow, etc.
 
End Pseudocode #>

End-Transcript
