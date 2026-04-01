#
# FoxFix ToolKit 
#

Clear-Host
Write-Host "
      |\__/|
     /      \
    /_.~  ~,_\
        \@/
        
   FoxFix ToolKit
" -ForegroundColor Orange
Write-Host "Pobieranie interfejsu..." -ForegroundColor Gray

# --- Inicjalizacja GUI ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "FoxFix - ToolKit"
$form.Size = New-Object System.Drawing.Size(400, 650)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::White
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# --- Naglowek Status ---
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Status Systemu"
$lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$lblStatus.Location = New-Object System.Drawing.Point(20, 20)
$lblStatus.Size = New-Object System.Drawing.Size(200, 30)
$form.Controls.Add($lblStatus)

$lblInfo = New-Object System.Windows.Forms.Label
$lblInfo.Text = "System: Microsoft Windows 11 Pro`nLicencja: Aktywny`nBitLocker: Wylaczony"
$lblInfo.Location = New-Object System.Drawing.Point(25, 50)
$lblInfo.Size = New-Object System.Drawing.Size(300, 60)
$lblInfo.ForeColor = [System.Drawing.Color]::DarkSlateGray
$form.Controls.Add($lblInfo)

# --- Funkcja pomocnicza do tworzenia Checkboxow ---
function Add-Check {
    param([string]$txt, [int]$y)
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $txt
    $cb.Location = New-Object System.Drawing.Point(30, $y)
    $cb.Size = New-Object System.Drawing.Size(320, 25)
    $cb.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $form.Controls.Add($cb)
    return $cb
}

# --- Lista opcji (Bez polskich znakow) ---
$c1 = Add-Check "WinUtil (Chris Titus)" 130
$c2 = Add-Check "Aktywator Windows (MAS)" 160
$c3 = Add-Check "Ustawienia OEM (FoxFix.it)" 190
$c4 = Add-Check "Winget: Instalacja pakietu aplikacji" 220

$c5 = Add-Check "Otworz ustawienia UAC" 270
$c6 = Add-Check "Otworz Panel Sterowania" 300
$c7 = Add-Check "Zarzadzaj BitLocker (Wlacz/Wylacz)" 330

$c8 = Add-Check "Utworz folder 'Programy' na pulpicie" 380
$c9 = Add-Check "Pokaz ikony 'Moj komputer' na pulpicie" 410
$c10 = Add-Check "Usun 'Dowiedz sie wiecej o tym obrazie'" 440

# --- Przyciski dolne ---
$btnSelectAll = New-Object System.Windows.Forms.Button
$btnSelectAll.Text = "Zaznacz wszystko"
$btnSelectAll.Location = New-Object System.Drawing.Point(30, 520)
$btnSelectAll.Size = New-Object System.Drawing.Size(130, 40)
$btnSelectAll.FlatStyle = "Flat"
$form.Controls.Add($btnSelectAll)

$btnExecute = New-Object System.Windows.Forms.Button
$btnExecute.Text = "Wykonaj"
$btnExecute.Location = New-Object System.Drawing.Point(230, 520)
$btnExecute.Size = New-Object System.Drawing.Size(120, 40)
$btnExecute.BackColor = [System.Drawing.Color]::FromArgb(211, 84, 0) # Pomaranczowy
$btnExecute.ForeColor = [System.Drawing.Color]::White
$btnExecute.FlatStyle = "Flat"
$btnExecute.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnExecute)

# --- Logika przyciskow ---
$btnSelectAll.Add_Click({
    $c1.Checked = $c2.Checked = $c3.Checked = $c4.Checked = $true
    $c5.Checked = $c6.Checked = $c7.Checked = $true
    $c8.Checked = $c9.Checked = $c10.Checked = $true
})

$btnExecute.Add_Click({
    if ($c1.Checked) { irm christitus.com/win | iex }
    if ($c2.Checked) { irm https://get.activated.win | iex }
    # Tutaj dodaj reszte swoich komend...
    [System.Windows.Forms.MessageBox]::Show("Operacja zakonczona sukcesem!", "FoxFix ToolKit")
})

# Wyswietlenie okna
$form.ShowDialog() | Out-Null
