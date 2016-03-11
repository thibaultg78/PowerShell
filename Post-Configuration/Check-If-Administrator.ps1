#===============================================================================
# Function : Check-If-Administrator
#===============================================================================
# Verifie si PowerShell est lance avec privileges Admin
# Return : Return 0 if not admin 1 if admin OK
#-------------------------------------------------------------------------------
function Check-If-Administrator() {
    #$user = [Security.Principal.WindowsIdentity]::GetCurrent();
    #$result =(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
	#return $result
	$myIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
	$wp = New-Object Security.Principal.WindowsPrincipal($myIdentity)
	
	if (-not $wp.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
		return 0
	}
	
	else {
		return 1
	}
}
