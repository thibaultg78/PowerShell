#===============================================================================
# Function : Disable-RDP
#===============================================================================
# Active RDP
# Return : nothing
#-------------------------------------------------------------------------------
function Disable-RDP() {
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 1
	Write-Host "RDP est maintenant desactive" $LogInfo
	# Only on Windows Server 2012 R2 to create an exception in MS Windows Firewall
	# Set-NetFirewallRule -DisplayGroup 'Remote Desktop' -Enabled True
}
