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
$sheet.Cells.Item($row,$column)= 'Name'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ # On passe à la colonne suivante


$sheet.Cells.Item($row,$column)= 'State'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ # On passe à la colonne suivante

$sheet.Cells.Item($row,$column)= 'Uptime'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ # On passe à la colonne suivante

$sheet.Cells.Item($row,$column)= 'Status'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ # On passe à la colonne suivante

# On passe à la seconde ligne et on revient à la colonne 1 (A2)
$row = 2
$Column = 1

# Récupération de la liste des VM sur la machine hôte
$entries = Get-VM

# Pour chaque entrée (aka chaque disque dur) on parcourt le fichier Excel et on affiche les informations
foreach ($entry in $entries)  {

    $sheet.Cells.Item($row,$column) = $entry.Name
    $column++

    $sheet.Cells.Item($row,$column) = $entry.State
    $column++
    
    $sheet.Cells.Item($row,$column) = $entry.Uptime.ToString()
    $column++

    $sheet.Cells.Item($row,$column) = $entry.Status
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
