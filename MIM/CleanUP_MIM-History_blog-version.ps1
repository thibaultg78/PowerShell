################################################################################################
# - CleanUpMimHistory - Parameters : None - It should be called one time by 1 month
# (to keep the last 15 days of logs ). This will allow to keep logs for the previous runs but will
# clean up the too much logs on the server.
################################################################################################
# Examples of calls :
#
# $return = CleanUpMimHistory
# $return
#
################################################################################################

function CleanUpMimHistory ()
{
    $computerName = "."
    $MIMHistory = Get-Wmiobject -Class 'MIIS_RunHistory' -namespace “root\MicrosoftIdentityIntegrationServer”
    $MIMServer = Get-Wmiobject -Class "MIIS_Server" -Namespace "root\MicrosoftIdentityIntegrationServer" -ComputerName $computerName -ErrorAction SilentlyContinue
    
    # I configured the number of days in a separated XML file but for the example we will set up in the function
    $daysBeforeHistoryPurge = 15 #$XmlDocument.MIM.'global-settings'.daysBeforeHistoryPurge 
    
    $endingBefore = [System.DateTime]::UtcNow.AddDays(-$daysBeforeHistoryPurge).ToString("yyyy-MM-dd HH:mm:ss.fff")

	# Clear MA runs History
    try
    {
        Write-Host ("[DEBUG] - Clearing MIM run history older than " + $daysBeforeHistoryPurge + " days")
        $clearRunHistory = $MIMServer.ClearRuns($endingBefore)
        Write-Host ("[DEBUG] - Status of the clearing operation : " + $clearRunHistory.ReturnValue)
    }
    catch
    {
        # Problem : displaying the Exception and Breaking the execution
        Write-Host $($_.Exception.Message)
        Write-Host ("[ERROR] - Problem during the clear of the MIM runs history")
        Break
    }
}


cls

CleanUpMimHistory
