#################################################
# 2013-06-26 - TGI
# Downloaded on https://akril.net
# Free to use as you want
#################################################

<#
Bug pour l'utilisation de la méthode Add
http://depsharee.blogspot.fr/2011/08/powershell-and-excel-bug.html
http://support.microsoft.com/default.aspx?scid=kb;en-us;320369
#>
[Threading.Thread]::CurrentThread.CurrentCulture = 'en-US'

# Lancement d'une instance de MS Excel
$excel = New-Object -ComObject "Excel.Application"            
$excel.Visible = $True
$excel.DisplayAlerts = $False

# Création d'une feuille Excel + activation de la feuille en cours   
$workbook = $excel.Workbooks.Add()
$sheet = $workbook.Worksheets.Item(1)
$sheet.Activate() | Out-Null

# On se positionne en A1 sur Excel (ligne=1/colonne=1)
# La première ligne corresponddra aux titres des colonnes
$row = 1
$Column = 1

# Saisie des données dans Excel
$sheet.Cells.Item($row,$column)= 'Device ID'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ # On passe à la colonne suivante

$sheet.Cells.Item($row,$column)= 'Volume Name'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ # On passe à la colonne suivante

$sheet.Cells.Item($row,$column)= 'Free space (in GB)'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ # On passe à la colonne suivante

# On passe à la seconde ligne et on revient à la colonne 1 (A2)
$row = 2
$Column = 1

# Récupération des données sur les disques locaux : on récupère 3 informations : DeviceID, VolumeName, Espace libre en Go
$entries = Get-WmiObject -Class Win32_LogicalDisk | Select -Property DeviceID,VolumeName, @{Name='Free Space GB';Expression={$_.FreeSpace/1GB} }

# Pour chaque entrée (aka chaque disque dur) on parcourt le fichier Excel et on affiche les informations
foreach ($entry in $entries)  {

    $sheet.Cells.Item($row,$column) = $entry.DeviceID
    $column++

    $sheet.Cells.Item($row,$column) = $entry.VolumeName
    $column++
    
    $sheet.Cells.Item($row,$column) = $entry.'Free Space GB'
    $column++
    
    $row++
    $column=1
}

# Optionnel : vous pouvez vouloir sauvegarder le fichier que vous venez de générer
#$workbook.SaveAs("D:\test.xlsx")
#$excel.Quit()

#################################################
# END OF PROGRAM
#################################################
