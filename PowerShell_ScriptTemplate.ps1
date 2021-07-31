#requires -version 5
#region - about_requires
<#
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_requires
#Requires -Version <N>[.<n>]
#Requires -PSSnapin <PSSnapin-Name> [-Version <N>[.<n>]]
#Requires -Modules { <Module-Name> | <Hashtable> }
#Requires -PSEdition <PSEdition-Name>
#Requires -ShellId <ShellId> -PSSnapin <PSSnapin-Name> [-Version <N>[.<n>]]
#Requires -RunAsAdministrator
#>
#endregion - about_requires

#region - Github
# Latest version of this template can be found at https://github.com/andyzib/Templates
#endregion - Github

#region - Comment Based Help
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help
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
Author: <Name> <email>

 
.EXAMPLE
<Example goes here. Repeat this attribute for more than one example>
#>
#endregion - Comment Based Help

#region - Parameters
# Enable -Debug, -Verbose Parameters. Write-Debug and Write-Verbose!
#[CmdletBinding()]
 
# Advanced Parameters: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
# Be sure to edit this to meet the validatations required as the allows and validate lines below may conflict with each other.  
<#
Param (
    [Parameter(Mandatory=$true,
    ValueFromPipeline=$true,
    Position=0,
    HelpMessage="Enter a help message for this parameter.")]
    [alias("Para0","Parameter0")]
    [AllowNull()] # Allows value of a mandatory parameter to be $null
    [AllowEmptyString()] # Allows value of a mandatory parameter to be an empty string ("")
    [AllowEmptyCollection()] # Allows value of a mandatory paramenter to be an empty collection @()
    [ValidateNotNull()] # Specifies that the parameter value cannot be $null
    [ValidateNotNullOrEmpty()] # Specifies that the parameter value cannot be $null and cannot be an empty string "". 
    [ValidateCount(1,5)] # Specifices the minimum and maximum number of parameter values a parameter accepts. Example: Computer1,Computer2,Computer3,Computer4,Computer5
    [ValidateLength(1,10)] # Specifies the minimum and maximum number of characters in a parameter or variable value. 
    [ValidatePattern("[0-9][0-9][0-9][0-9]")] # Specifies a regular expression that is compared to the parameter or variable value. 
    [ValidateRange(0,10)] # Specifies a numeric range for each parameter or variable value. 
    [ValidateScript({$_ -ge (Get-Date)})] # Specifies a script that is used to validate a parameter or variable value.
    [ValidateSet("Chocolate", "Strawberry", "Vanilla")] # Specifies a set of valid values for a parameter or variable.
    [string]$Param0,
    # Don't forget a comma between parameters. 
    [Parameter(Mandatory=$true,
    ValueFromPipeline=$true,
    Position=1,
    HelpMessage="Enter a help message for this parameter.")]
    [alias("Para1","Parameter1")]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [ValidateCount(1,5)]
    [ValidateLength(1,10)]
    [ValidatePattern("[0-9][0-9][0-9][0-9]")]
    [ValidateRange(0,10)]
    [ValidateScript({$_ -ge (Get-Date)})]
    [ValidateSet("Chocolate", "Strawberry", "Vanilla")]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [string]$Param1
)
#>
#endregion - Parameters
 
#region - Additional Parameter Validation and Cleanup
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
#endregion - Additional Parameter Validation and Cleanup

#region - Initializations
 
#Set Error Action to Silently Continue
#$ErrorActionPreference = "SilentlyContinue"
 
#Import-Module activedirectory -ErrorAction Stop

# Speed up Invoke-WebRequest in PowerShell 5. Not needed in 6 and up. 
<#
If ($PSVersionTable.PSVersion.Major -eq 5) {
  $ProgressPreference = 'SilentlyContinue'
}
#>

#endregion - Initializations

#regioin - Declarations

# ISO 8601 Date Format. Accept no substitutes! 
$iso8601 = Get-Date -Format s
# Colon (:) isn't a valid character in file names.
$iso8601 = $iso8601.Replace(":","_")
# Just YYYY-MM-DD
#$datestamp = $iso8601.Substring(0,10)

# Cross platform path for transcript file for PowerShell 6, 7, and hopefully beyond. 
# On a non-domain joined Windows PC, this is C:\Users\Username\YYYY-MM-DDTHH-MM-SS_PowershellTranscript.txt
# For Mac/Linux this will be ~/YYYY-MM-DDTHH-MM-SS_PowershellTranscript.txt
if ($PSVersionTable.PSVersion.Major -gt 5) {
  if (-Not $IsWindows) {
      $MyHome = $env:HOME # Linux and MacOS
  } else {
      $MyHome = Join-Path -Path $env:HOMEDRIVE -ChildPath $env:HOMEPATH # Windows
  }
} else {
  $MyHome = Join-Path -Path $env:HOMEDRIVE -ChildPath $env:HOMEPATH # Windows
}
$MyScriptName = (Split-Path -Path $PSCommandPath -Leaf).Replace(".ps1","")
$TranscriptFile = Join-Path -Path $MyHome -ChildPath "$($iso8601)_$($MyScriptName).txt"


#endregioin - Declarations

#region - Functions
 
<#
 
Function <FunctionName>{
  Param()
#>

# Make sure we stop the PowerShell Transcript and display it if needed. 
# Also reduce code redundancy. 
Function Invoke-CleanExit {
  <#
  .SYNOPSIS
  Exits the script cleanly, showing exit message and stoping and showing the transcript.
  
  .DESCRIPTION
  Exits the script cleanly, showing exit message and stoping and showing the transcript.
  
  .PARAMETER Messages
  One or more messages strings to display. Separate mutiple strings with a comma: Example: "MessageOne","MessageTwo"
  
  .PARAMETER OutputObject
  If passed, this will be writtn to the console with Write-Output. 

  .PARAMETER ExitOnError
  Switch parameter. Use when exiting on an error. 
  
  .EXAMPLE
  Invoke-CleanExit -Messages "Unable to process your request.","The operation failed" -OutputObject $result -ExitOnError
  #>    
  Param(
      [Parameter(Mandatory=$true,
      Position=0)]
      [alias("Message")]
      [string[]]$Messages, # [String[]] allows for an array of strings. 
      [Parameter(Mandatory=$false,
      Position=1)]
      $OutputObject=$null, # Object that will be written to the console. Not specifiying type. 
      [Parameter(Mandatory=$false,
      Position=2)]
      [Switch]$ExitOnError=$false, # Use this when exiting on an error.
      [Parameter(Mandatory=$false,
      Position=3)]
      [Switch]$ShowTranscript=$false
  )
  if ($ExitOnError) { $Color = 'Red' }
  else { $Color = 'Green' }

  Foreach ($Message in $Messages) {
      Write-Host $Message -ForegroundColor $Color
  }

  if ($ExitOnError) {
      Write-Host "Unable to continue." -ForegroundColor $Color
  }

  if ($null -ne $OutputObject) {
      if ($null -ne $result.StatusCode) {
          Write-Host "HTTP Status $($OutputObject.StatusCode): $($OutputObject.StatusDescription)" -ForegroundColor $Color
      }
      Write-Host "Dumping result to console and exiting." -ForegroundColor $Color
      Write-Output $OutputObject
  }

  Stop-Transcript
  if ($ShowTranscript) { 
      if (Test-Path -Path $TranscriptFile) { # Make sure the file exists as I might have commented out the Start-Transcript line. 
          Invoke-Item -Path $TranscriptFile # Opens the text file in default application. 
      }
  }
  # Exit
  Exit
}

#endregion - Functions

#region - Execution
 
Start-Transcript -Path $TranscriptFile
 
<# Pseudocode
 
Logic, flow, etc.
 
End Pseudocode #>

Stop-Transcript
#endregion - Execution