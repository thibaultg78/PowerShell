#===============================================================================
# Function : Set-TimeZoneFR
#===============================================================================
# Configure TimeZone to France
# In Paris/France : it's UTC +1 - Time zone called "Romance Standard Time"
# By default, we'll take the France UTC+1  Time Zone called "Romance Standard Time"
# Return : nothing
#-------------------------------------------------------------------------------
function Set-TimeZoneFR([string]$timezone = "Romance Standard Time") {
	# [string]$TimeZone = "Romance Standard Time"
	$process = New-Object System.Diagnostics.Process 
	$process.StartInfo.WindowStyle = "Hidden" 
	$process.StartInfo.FileName = "tzutil.exe" 
	$process.StartInfo.Arguments = "/s `"$TimeZone`"" 
	$process.Start() | Out-Null
	Write-Host "Fuseau horaire configure avec succes sur(UTC+1) - France/Paris"
}
