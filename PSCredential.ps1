<#
$mycredentials = Get-Credential
 
When you have to provide credentials in non-interactive mode, you can create a PSCredential object in the following way.
 
$secpasswd = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("username", $secpasswd)
 
You can now pass $mycreds to any -PSCredential input parameter
 
#>