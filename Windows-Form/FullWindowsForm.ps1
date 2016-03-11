#################################################
# 2013-04-07 - TGI
# Downloaded on http://blog.akril.net
# Free to use as you want
#################################################

# Chargement des Windows Form
#region
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
#endregion            

#################################################
# CONFIGURATION DE LA WINDOWS FORM
#################################################

# Creation de la form principale
$form = New-Object Windows.Forms.Form

# Pour bloquer le resize du form et supprimer les icones Minimize and Maximize
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $False
$form.MinimizeBox = $False

# Choix du titre
$form.Text = "Hello world... oui pas très innovant, je sais !"

# Choix de la taille
$form.Size = New-Object System.Drawing.Size(400,370)

#################################################
# AJOUT DES COMPOSANTS
#################################################

# Bouton OK
$button_ok = New-Object System.Windows.Forms.Button
$button_ok.Text = "OK"
$button_ok.Size = New-Object System.Drawing.Size(355,40)
$button_ok.Location = New-Object System.Drawing.Size(20,230)

# Bouton Quitter
$button_quit = New-Object System.Windows.Forms.Button
$button_quit.Text = "Fermer"
$button_quit.Size = New-Object System.Drawing.Size(355,40)
$button_quit.Location = New-Object System.Drawing.Size(20,280)

# Label 1
$label_prez = New-Object System.Windows.Forms.Label
$label_prez.AutoSize = $true
$label_prez.Location = New-Object System.Drawing.Point(20,20)
$label_prez.Size = New-Object System.Drawing.Size(100,20)
$label_prez.Text = "May the force be with you... Choose your side : "

# CheckBox x2
$checkbox_un = New-Object System.Windows.Forms.CheckBox
$checkbox_un.AutoSize = $true
$checkbox_un.Location = New-Object System.Drawing.Point(30,70)
$checkbox_un.Name = 'checkbox_un'
$checkbox_un.Size = New-Object System.Drawing.Size(80,20)
$checkbox_un.Text = 'Light side'

$checkbox_deux = New-Object System.Windows.Forms.CheckBox
$checkbox_deux.AutoSize = $true
$checkbox_deux.Location = New-Object System.Drawing.Point(30,90)
$checkbox_deux.Name = 'checkbox_deux'
$checkbox_deux.Size = New-Object System.Drawing.Size(80,20)
$checkbox_deux.Text = 'Dark side'

# Label 2
$label_un = New-Object System.Windows.Forms.Label
$label_un.AutoSize = $true
$label_un.Location = New-Object System.Drawing.Point(20,130)
$label_un.Name = 'label_password'
$label_un.Size = New-Object System.Drawing.Size(100,20)
$label_un.Text = "a simple Label"

# TextBox
$textbox_yoda = New-Object System.Windows.Forms.TextBox
$textbox_yoda.AutoSize = $true
$textbox_yoda.Location = New-Object System.Drawing.Point(150,125)
$textbox_yoda.Name = 'textbox_sw'
$textbox_yoda.Size = New-Object System.Drawing.Size(220,20)
$textbox_yoda.Text = "Do or do not. There is no try !"

# Label 3
$label_deux = New-Object System.Windows.Forms.Label
$label_deux.AutoSize = $true
$label_deux.Location = New-Object System.Drawing.Point(20,160)
$label_deux.Name = 'label_complex'
$label_deux.Size = New-Object System.Drawing.Size(100,20)
$label_deux.Text = "Yet another simple Label... and a progress bar :"

# Barre de progression
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = New-Object System.Drawing.Point(20,185)
$progress.Name = 'progressBar'
$progress.Size = New-Object System.Drawing.Size(350,23)

#################################################
# GESTION DES EVENEMENTS
#################################################

# Gestion event quand on clique sur le bouton Fermer
$button_quit.Add_Click(
{
$form.Close();
})

# Gestion event quand on clique sur le bouton OK
# Pour tester, on modifie le textBox et on rempli la barre de progression
$button_ok.Add_Click(
{
    $textbox_yoda.Text = 'Stop de cliquer partout !'
    $progress.Value = 100
})

#################################################
# INSERTION DES COMPOSANTS
#################################################

# Ajout des composants a la Form
$form.Controls.Add($label_prez)
$form.Controls.Add($checkbox_un)
$form.Controls.Add($checkbox_deux)
$form.Controls.Add($label_un)
$form.Controls.Add($label_deux)
$form.Controls.Add($textbox_yoda)
$form.Controls.Add($progress)
$form.Controls.Add($button_ok)
$form.Controls.Add($button_quit)

# Affichage de la Windows
$form.ShowDialog()

#################################################
# END OF PROGRAM
#################################################
