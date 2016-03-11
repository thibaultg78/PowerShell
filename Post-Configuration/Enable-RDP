#===============================================================================
# Function : Enable-RDP
#===============================================================================
# Active RDP
# Return : nothing
#-------------------------------------------------------------------------------
function Enable-RDP() {
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0
	Write-Log "RDP est maintenant active" $LogInfo
	# Only on Windows Server 2012 R2 to create an exception in MS Windows Firewall
	# Set-NetFirewallRule -DisplayGroup 'Remote Desktop' -Enabled True
}
