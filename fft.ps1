Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Dane systemowe ---
$OSName = (Get-CimInstance Win32_OperatingSystem).Caption
$IsActivated = [bool](Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND LicenseStatus = 1")
$StatusText = if ($IsActivated) { "Aktywny" } else { "Nieaktywny" }
$StatusColor = if ($IsActivated) { "Green" } else { "Red" }

# --- Sprawdzanie BitLockera ---
$BLStatusText = "Nieznany / Wymaga Admina"
$BLStatusColor = "Orange"
try {
    $sysDrive = $env:SystemDrive
    $BLVol = Get-CimInstance -Namespace "root\CIMV2\Security\MicrosoftVolumeEncryption" -ClassName Win32_EncryptableVolume -Filter "DriveLetter='$sysDrive'" -ErrorAction Stop
    if ($BLVol.ProtectionStatus -eq 1 -or $BLVol.ProtectionStatus -eq 2) {
        $BLStatusText = "Włączony"
        $BLStatusColor = "Green"
    } else {
        $BLStatusText = "Wyłączony"
        $BLStatusColor = "Red"
    }
} catch {
    $BLStatusText = "Brak uprawnień Admina"
    $BLStatusColor = "Orange"
}

# --- Główne okno ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "FoxFix - ToolKit"
$Form.Size = New-Object System.Drawing.Size(420, 780)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [System.Drawing.Color]::FromArgb(243, 243, 243)
$Form.FormBorderStyle = "FixedDialog"
$Form.MaximizeBox = $false

# --- Nagłówek ---
$LabelIcon = New-Object System.Windows.Forms.Label
$LabelIcon.Text = "🦊"
$LabelIcon.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 40)
$LabelIcon.Location = New-Object System.Drawing.Point(70, 20)
$LabelIcon.Size = New-Object System.Drawing.Size(70, 70)
$Form.Controls.Add($LabelIcon)

$LabelTitle = New-Object System.Windows.Forms.Label
$LabelTitle.Text = "FoxFix"
$LabelTitle.Font = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
$LabelTitle.ForeColor = [System.Drawing.Color]::FromArgb(211, 84, 0)
$LabelTitle.Location = New-Object System.Drawing.Point(145, 25)
$LabelTitle.Size = New-Object System.Drawing.Size(200, 45)
$Form.Controls.Add($LabelTitle)

$LabelSub = New-Object System.Windows.Forms.Label
$LabelSub.Text = "ToolKit"
$LabelSub.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$LabelSub.ForeColor = [System.Drawing.Color]::Gray
$LabelSub.Location = New-Object System.Drawing.Point(148, 65)
$Form.Controls.Add($LabelSub)

# --- Sekcja Status ---
$LabelStatusTitle = New-Object System.Windows.Forms.Label
$LabelStatusTitle.Text = "Status Systemu"
$LabelStatusTitle.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$LabelStatusTitle.Location = New-Object System.Drawing.Point(30, 110)
$Form.Controls.Add($LabelStatusTitle)

$PanelStatus = New-Object System.Windows.Forms.Panel
$PanelStatus.Location = New-Object System.Drawing.Point(30, 135)
$PanelStatus.Size = New-Object System.Drawing.Size(345, 85)
$Form.Controls.Add($PanelStatus)

$LabelOS = New-Object System.Windows.Forms.Label
$LabelOS.Text = "System: $OSName"
$LabelOS.Location = New-Object System.Drawing.Point(10, 5)
$LabelOS.Size = New-Object System.Drawing.Size(320, 20)
$PanelStatus.Controls.Add($LabelOS)

$LabelLic = New-Object System.Windows.Forms.Label
$LabelLic.Text = "Licencja: $StatusText"
$LabelLic.ForeColor = [System.Drawing.Color]::FromName($StatusColor)
$LabelLic.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$LabelLic.Location = New-Object System.Drawing.Point(10, 30)
$LabelLic.Size = New-Object System.Drawing.Size(320, 20)
$PanelStatus.Controls.Add($LabelLic)

$LabelBLVal = New-Object System.Windows.Forms.Label
$LabelBLVal.Text = "BitLocker: $BLStatusText"
$LabelBLVal.ForeColor = [System.Drawing.Color]::FromName($BLStatusColor)
$LabelBLVal.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$LabelBLVal.Location = New-Object System.Drawing.Point(10, 55)
$LabelBLVal.Size = New-Object System.Drawing.Size(320, 20)
$PanelStatus.Controls.Add($LabelBLVal)

# --- Lista Opcji (Kolejność: Tech -> Moje -> System -> Ikony) ---

# Sekcja 1: Tech / Aktywacja
$Check1 = New-Object System.Windows.Forms.CheckBox
$Check1.Text = "WinUtil (Chris Titus)"
$Check1.Location = New-Object System.Drawing.Point(40, 240); $Check1.Size = New-Object System.Drawing.Size(320, 30)
$Form.Controls.Add($Check1)

$Check2 = New-Object System.Windows.Forms.CheckBox
$Check2.Text = "Aktywator Windows (MAS)"
$Check2.Location = New-Object System.Drawing.Point(40, 270); $Check2.Size = New-Object System.Drawing.Size(320, 30)
$Form.Controls.Add($Check2)

# Odstęp
$Check3 = New-Object System.Windows.Forms.CheckBox
$Check3.Text = "Ustawienia OEM (FoxFix.it)"
$Check3.Location = New-Object System.Drawing.Point(40, 315); $Check3.Size = New-Object System.Drawing.Size(320, 30)
$Form.Controls.Add($Check3)

$Check5 = New-Object System.Windows.Forms.CheckBox
$Check5.Text = "Winget: Instalacja pakietu aplikacji"
$Check5.Location = New-Object System.Drawing.Point(40, 345); $Check5.Size = New-Object System.Drawing.Size(320, 30)
$Form.Controls.Add($Check5)

# Odstęp
$Check6 = New-Object System.Windows.Forms.CheckBox
$Check6.Text = "Otwórz ustawienia UAC"
$Check6.Location = New-Object System.Drawing.Point(40, 390); $Check6.Size = New-Object System.Drawing.Size(320, 30)
$Form.Controls.Add($Check6)

$Check7 = New-Object System.Windows.Forms.CheckBox
$Check7.Text = "Otwórz Panel Sterowania"
$Check7.Location = New-Object System.Drawing.Point(40, 420); $Check7.Size = New-Object System.Drawing.Size(320, 30)
$Form.Controls.Add($Check7)

$Check10 = New-Object System.Windows.Forms.CheckBox
$Check10.Text = "Zarządzaj BitLocker (Włącz/Wyłącz)"
$Check10.Location = New-Object System.Drawing.Point(40, 450); $Check10.Size = New-Object System.Drawing.Size(320, 30)
$Form.Controls.Add($Check10)

# Odstęp
$Check8 = New-Object System.Windows.Forms.CheckBox
$Check8.Text = "Utwórz folder 'Programy' na pulpicie"
$Check8.Location = New-Object System.Drawing.Point(40, 495); $Check8.Size = New-Object System.Drawing.Size(320, 30)
$Form.Controls.Add($Check8)

$Check9 = New-Object System.Windows.Forms.CheckBox
$Check9.Text = "Pokaż ikonę 'Mój komputer'"
$Check9.Location = New-Object System.Drawing.Point(40, 525); $Check9.Size = New-Object System.Drawing.Size(320, 30)
$Form.Controls.Add($Check9)

$Check4 = New-Object System.Windows.Forms.CheckBox
$Check4.Text = "Usuń 'Dowiedz się więcej o tym obrazie'"
$Check4.Location = New-Object System.Drawing.Point(40, 555); $Check4.Size = New-Object System.Drawing.Size(320, 30)
$Form.Controls.Add($Check4)

# --- Przyciski ---
$BtnAll = New-Object System.Windows.Forms.Button
$BtnAll.Text = "Zaznacz wszystko"
$BtnAll.Location = New-Object System.Drawing.Point(30, 650)
$BtnAll.Size = New-Object System.Drawing.Size(130, 40)
$BtnAll.FlatStyle = "Flat"
$BtnAll.BackColor = [System.Drawing.Color]::LightGray
$BtnAll.Add_Click({ 
    $Check1.Checked = $Check2.Checked = $Check3.Checked = $Check4.Checked = $Check5.Checked = $Check6.Checked = $Check7.Checked = $Check8.Checked = $Check9.Checked = $Check10.Checked = $true 
})
$Form.Controls.Add($BtnAll)

$BtnExe = New-Object System.Windows.Forms.Button
$BtnExe.Text = "Wykonaj"
$BtnExe.Location = New-Object System.Drawing.Point(245, 650)
$BtnExe.Size = New-Object System.Drawing.Size(130, 40)
$BtnExe.FlatStyle = "Flat"
$BtnExe.BackColor = [System.Drawing.Color]::FromArgb(211, 84, 0)
$BtnExe.ForeColor = [System.Drawing.Color]::White
$BtnExe.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$BtnExe.Add_Click({
    if (-not ($Check1.Checked -or $Check2.Checked -or $Check3.Checked -or $Check4.Checked -or $Check5.Checked -or $Check6.Checked -or $Check7.Checked -or $Check8.Checked -or $Check9.Checked -or $Check10.Checked)) {
        [System.Windows.Forms.MessageBox]::Show("Nic nie zaznaczono!", "FoxFix - Błąd")
        return
    }

    $res = [System.Windows.Forms.MessageBox]::Show("Czy chcesz uruchomić zaznaczone zadania?", "Potwierdzenie", "YesNo", "Question")
    if ($res -eq "Yes") {
        try {
            if ($Check1.Checked) { Start-Process powershell.exe -ArgumentList "-NoProfile -NoExit -Command `"irm 'https://christitus.com/win' | iex`"" -Verb RunAs }
            if ($Check2.Checked) { Start-Process powershell.exe -ArgumentList "-NoProfile -NoExit -Command `"irm 'https://get.activated.win' | iex`"" -Verb RunAs }
            if ($Check3.Checked) {
                $oemScript = "@echo off`nreg add `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation`" /v Manufacturer /t REG_SZ /d `"FoxFix.it`" /f`nreg add `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation`" /v SupportPhone /t REG_SZ /d `"572 571 704`" /f`nreg add `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation`" /v SupportURL /t REG_SZ /d `"https://foxfix.it/`" /f`npause"
                $batPath = "$env:TEMP\FoxFix_OEM.bat"; Set-Content -Path $batPath -Value $oemScript -Encoding UTF8
                Start-Process cmd.exe -ArgumentList "/c `"$batPath`"" -Verb RunAs
            }
            if ($Check4.Checked) {
                $regScript = "@echo off`nREG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {2cc5ca98-6485-489a-920e-b3e88a6ccce3} /t REG_DWORD /d 1 /f`npause"
                $batPath = "$env:TEMP\FoxFix_Reg.bat"; Set-Content -Path $batPath -Value $regScript -Encoding UTF8
                Start-Process cmd.exe -ArgumentList "/c `"$batPath`"" -Verb RunAs
            }
            if ($Check5.Checked) {
                $wingetScript = "@echo off`nwinget install Google.Chrome --silent --accept-package-agreements`nwinget install CodecGuide.K-LiteCodecPack.Standard --silent`nwinget install Giorgiotani.Peazip --silent`nwinget install OnlyOffice.DesktopEditors --silent`npause"
                $batPath = "$env:TEMP\FoxFix_Winget.bat"; Set-Content -Path $batPath -Value $wingetScript -Encoding UTF8
                Start-Process cmd.exe -ArgumentList "/c `"$batPath`"" -Verb RunAs
            }
            if ($Check6.Checked) { Start-Process "UserAccountControlSettings.exe" }
            if ($Check7.Checked) { Start-Process "control.exe" }
            if ($Check10.Checked) { Start-Process "control.exe" -ArgumentList "/name Microsoft.BitLockerDriveEncryption" }
            if ($Check8.Checked) {
                $programsFolder = Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath "Programy"
                if (-not (Test-Path $programsFolder)) { New-Item -ItemType Directory -Path $programsFolder | Out-Null }
            }
            if ($Check9.Checked) {
                $regScriptPC = "@echo off`nREG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /t REG_DWORD /d 0 /f`npause"
                $batPathPC = "$env:TEMP\FoxFix_PC.bat"; Set-Content -Path $batPathPC -Value $regScriptPC -Encoding UTF8
                Start-Process cmd.exe -ArgumentList "/c `"$batPathPC`"" -Verb RunAs
            }
        } catch { [System.Windows.Forms.MessageBox]::Show("Błąd: $_", "Błąd") }
    }
})
$Form.Controls.Add($BtnExe)

$Form.ShowDialog() | Out-Null
