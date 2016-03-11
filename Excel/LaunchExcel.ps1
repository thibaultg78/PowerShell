#################################################
# 2013-06-26 - TGI
# Downloaded on http://blog.akril.net
# Free to use as you want
#################################################

<#
Bug pour l'utilisation de la méthode Add
- http://depsharee.blogspot.fr/2011/08/powershell-and-excel-bug.html
- http://support.microsoft.com/default.aspx?scid=kb;en-us;320369
#>

[Threading.Thread]::CurrentThread.CurrentCulture = 'en-US'

# Lancement de MS Excel
$excel = New-Object -ComObject "Excel.Application"            

# Excel se lance en mode visible
$excel.Visible = $True

# Excel ne donnera aucune alerte ou ne vous demandera aucune confirmation dans vos actions
$excel.DisplayAlerts = $False       

# Ajouter une feuille au document Excel
$workbook = $excel.Workbooks.Add()

# On passe en active la première feuille de notre document Excel
$sheet = $workbook.Worksheets.Item(1)
$sheet.Activate() | Out-Null

# On sauvegarde notre fichier Excel
$workbook.SaveAs("C:\test.xlsx")

# On quitte Excel
$excel.Quit()

#################################################
# END OF PROGRAM
#################################################
