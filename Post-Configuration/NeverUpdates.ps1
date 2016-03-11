# Used to control Microsoft automatic updates
function NeverUpdates() 
{
$updateObj = New-Object -ComObject Microsoft.Update.AutoUpdate
# ' 1 =  Never Check for Updates
# ' 2 =  Prompt for Update and Prompt for Installation
# ' 3 =  Prompt for Update and Prompt for Installation
# ' 4 =  Install automatically
$updateObj.Settings.NotificationLevel = 1
$updateObj.Settings.Save()
Write-Host "Automatic Updates is set to NEVER check."
}
