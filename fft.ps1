Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

# ============================================================
#  FoxFix - ToolKit
#  Skrypt konfiguracyjny do przygotowania nowych komputerow
#  Windows 10 / 11 i nowsze - czysty WinForms
# ============================================================

# --- Paleta marki ---
$ColBrand   = [System.Drawing.Color]::FromArgb(211, 84, 0)
$ColBrandDk = [System.Drawing.Color]::FromArgb(170, 66, 0)
$ColWhite   = [System.Drawing.Color]::White
$ColText    = [System.Drawing.Color]::FromArgb(40, 40, 40)
$ColOk      = [System.Drawing.Color]::FromArgb(30, 130, 30)
$ColErr     = [System.Drawing.Color]::FromArgb(190, 30, 30)
$ColWarn    = [System.Drawing.Color]::FromArgb(200, 120, 0)
$ColLine    = [System.Drawing.Color]::FromArgb(230, 230, 230)
$FontUI     = "Segoe UI"

# --- Dane systemowe ---
$OSName       = (Get-CimInstance Win32_OperatingSystem).Caption
$IsActivated  = [bool](Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND LicenseStatus = 1")
$StatusText   = if ($IsActivated) { "Aktywny" } else { "Nieaktywny" }
$StatusColor  = if ($IsActivated) { $ColOk } else { $ColErr }

# --- BitLocker ---
$BLStatusText  = "Nieznany / wymaga admina"
$BLStatusColor = $ColWarn
try {
    $sysDrive = $env:SystemDrive
    $BLVol = Get-CimInstance -Namespace "root\CIMV2\Security\MicrosoftVolumeEncryption" -ClassName Win32_EncryptableVolume -Filter "DriveLetter='$sysDrive'" -ErrorAction Stop
    if ($BLVol.ProtectionStatus -in 1,2) { $BLStatusText = "Wlaczony"; $BLStatusColor = $ColOk }
    else { $BLStatusText = "Wylaczony"; $BLStatusColor = $ColErr }
} catch {
    $BLStatusText = "Brak uprawnien admina"; $BLStatusColor = $ColWarn
}

$WingetOk = [bool](Get-Command winget -ErrorAction SilentlyContinue)

# --- Katalog aplikacji do instalacji ---
# Id = pakiet winget. Url = brak sensownego pakietu winget - otwiera stronic producenta
# (AMD Adrenalin: sterownik zalezny od sprzetu, Microsoft nie ma dla niego oficjalnego
#  pakietu w winget, wiec bezpieczniej jest otworzyc auto-detekcje AMD).
$AppCatalog = @(
    @{ Name = "Google Chrome";                          Id = "Google.Chrome";                       Default = $true  }
    @{ Name = "K-Lite Codec Pack Standard";              Id = "CodecGuide.K-LiteCodecPack.Standard"; Default = $true  }
    @{ Name = "PeaZip";                                  Id = "Giorgiotani.Peazip";                  Default = $true  }
    @{ Name = "OnlyOffice Desktop Editors";              Id = "ONLYOFFICE.DesktopEditors";           Default = $true  }
    @{ Name = "7-Zip";                                   Id = "7zip.7zip";                           Default = $false }
    @{ Name = "Mozilla Firefox";                         Id = "Mozilla.Firefox";                     Default = $false }
    @{ Name = "Adobe Acrobat Reader";                    Id = "Adobe.Acrobat.Reader.64-bit";         Default = $false }
    @{ Name = "VLC Media Player";                        Id = "VideoLAN.VLC";                        Default = $false }
    @{ Name = "IObit Driver Booster";                    Id = "IObit.DriverBooster";                 Default = $false }
    @{ Name = "NVIDIA GeForce Experience";               Id = "Nvidia.GeForceExperience";             Default = $false }
    @{ Name = "AMD Software: Adrenalin (auto-detekcja)"; Url = "https://www.amd.com/en/support";     Default = $false }
)

# --- ASCII lis (art: Todd Vargo, ascii-art.de) ---
$AsciiArt = @"
  /\   /\
 //\\_//\\     ____
 \_     _/    /   /
  / * * \    /^^^]
  \_\O/_/    [   ]
   /   \_    [   /
   \     \_  /  /
    [ [ /  \/ _/
   _[ [ \  /_/
"@

# ============================================================
#  GLOWNE OKNO - 3 stale sekcje: Naglowek (Top) / Zakladki (Fill) / Przyciski+Log (Bottom)
# ============================================================
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "FoxFix - ToolKit"
$Form.ClientSize = New-Object System.Drawing.Size(560, 760)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = $ColWhite
$Form.FormBorderStyle = "FixedDialog"
$Form.MaximizeBox = $false

function New-Label {
    param($Text, $X, $YPos, $W, $H, $Size = 9, $Bold = $false, $Color = $ColText, $Font = $FontUI, $Align = "TopLeft")
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $Text
    $style = if ($Bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $lbl.Font = New-Object System.Drawing.Font($Font, $Size, $style)
    $lbl.ForeColor = $Color
    $lbl.Location = New-Object System.Drawing.Point($X, $YPos)
    $lbl.Size = New-Object System.Drawing.Size($W, $H)
    $lbl.TextAlign = [System.Drawing.ContentAlignment]::$Align
    $lbl.BackColor = [System.Drawing.Color]::Transparent
    return $lbl
}

function New-CategoryHeader {
    # Naglowek kategorii + cienka linia pod spodem. Zwraca nowa pozycje Y.
    param($Text, $X, $YPos, $Parent, $W = 480)
    $Parent.Controls.Add((New-Label $Text $X $YPos $W 18 9.5 $true $ColBrandDk))
    $line = New-Object System.Windows.Forms.Panel
    $line.Location = New-Object System.Drawing.Point($X, ($YPos + 19))
    $line.Size = New-Object System.Drawing.Size($W, 1)
    $line.BackColor = $ColLine
    $Parent.Controls.Add($line)
    return ($YPos + 27)
}

function New-Chk {
    param($Text, $X, $YPos, $Parent)
    $c = New-Object System.Windows.Forms.CheckBox
    $c.Text = $Text
    $c.Font = New-Object System.Drawing.Font($FontUI, 9)
    $c.ForeColor = $ColText
    $c.Location = New-Object System.Drawing.Point($X, $YPos)
    $c.Size = New-Object System.Drawing.Size(485, 24)
    $Parent.Controls.Add($c)
    return $c
}

# --- SEKCJA 1: Naglowek ---
$HeaderPanel = New-Object System.Windows.Forms.Panel
$HeaderPanel.Dock = "Top"
$HeaderPanel.Height = 100
$HeaderPanel.BackColor = $ColBrand
$Form.Controls.Add($HeaderPanel)

$LabelAscii = New-Label $AsciiArt 20 8 190 88 8 $false $ColWhite "Consolas"
$HeaderPanel.Controls.Add($LabelAscii)
$LabelTitle = New-Label "FoxFix" 215 18 250 42 22 $true $ColWhite
$HeaderPanel.Controls.Add($LabelTitle)
$LabelSub = New-Label "ToolKit - konfiguracja komputera" 218 58 320 20 10 $false ([System.Drawing.Color]::FromArgb(255,225,205))
$HeaderPanel.Controls.Add($LabelSub)

# --- SEKCJA 3: Dol (stale widoczne przyciski + log) ---
$BottomPanel = New-Object System.Windows.Forms.Panel
$BottomPanel.Dock = "Bottom"
$BottomPanel.Height = 280
$BottomPanel.BackColor = $ColWhite
$Form.Controls.Add($BottomPanel)

# --- SEKCJA 2: Zakladki ---
$Tabs = New-Object System.Windows.Forms.TabControl
$Tabs.Dock = "Fill"
$Tabs.Font = New-Object System.Drawing.Font($FontUI, 9.5)
$Form.Controls.Add($Tabs)
$Form.Controls.SetChildIndex($Tabs, 0)

$Tab1 = New-Object System.Windows.Forms.TabPage
$Tab1.Text = "Konfiguracja systemu"
$Tab1.BackColor = $ColWhite
$Tabs.TabPages.Add($Tab1)

$Tab2 = New-Object System.Windows.Forms.TabPage
$Tab2.Text = "Aplikacje (Winget)"
$Tab2.BackColor = $ColWhite
$Tab2.AutoScroll = $true
$Tabs.TabPages.Add($Tab2)

# ------------------ TAB 1a: Status systemu - PRZYPIETY na gorze, sie nie przewija ------------------
$StatusPanel = New-Object System.Windows.Forms.Panel
$StatusPanel.Dock = "Top"
$StatusPanel.Height = 110
$StatusPanel.BackColor = $ColWhite
$Tab1.Controls.Add($StatusPanel)

$GbStatus = New-Object System.Windows.Forms.GroupBox
$GbStatus.Text = "Status systemu"
$GbStatus.Font = New-Object System.Drawing.Font($FontUI, 9, [System.Drawing.FontStyle]::Bold)
$GbStatus.ForeColor = $ColText
$GbStatus.Location = New-Object System.Drawing.Point(15, 10)
$GbStatus.Size = New-Object System.Drawing.Size(505, 95)
$StatusPanel.Controls.Add($GbStatus)

$GbStatus.Controls.Add((New-Label "System: $OSName" 15 25 475 20 9))
$GbStatus.Controls.Add((New-Label "Licencja: $StatusText" 15 47 220 20 9 $true $StatusColor))
$GbStatus.Controls.Add((New-Label "BitLocker: $BLStatusText" 250 47 240 20 9 $true $BLStatusColor))
if (-not $WingetOk) {
    $GbStatus.Controls.Add((New-Label "Winget NIEDOSTEPNY - zainstaluj 'App Installer' z Microsoft Store" 15 69 475 20 8 $true $ColErr))
} else {
    $GbStatus.Controls.Add((New-Label "Winget: dostepny" 15 69 200 20 8 $true $ColOk))
}

# ------------------ TAB 1b: Zadania systemowe w kategoriach - przewijane pod statusem ------------------
$TaskPanel = New-Object System.Windows.Forms.Panel
$TaskPanel.Dock = "Fill"
$TaskPanel.AutoScroll = $true
$TaskPanel.BackColor = $ColWhite
$Tab1.Controls.Add($TaskPanel)
$Tab1.Controls.SetChildIndex($TaskPanel, 0)

$cy = 12
$cy = New-CategoryHeader "Aktywacja i system" 15 $cy $TaskPanel
$Check1  = New-Chk "WinUtil (Chris Titus)" 15 $cy $TaskPanel;             $cy += 27
$Check2  = New-Chk "Aktywator Windows (MAS)" 15 $cy $TaskPanel;           $cy += 27
$Check3  = New-Chk "Ustawienia OEM (FoxFix.it)" 15 $cy $TaskPanel;        $cy += 27
$cy += 10

$cy = New-CategoryHeader "Windows Update" 15 $cy $TaskPanel
$CheckWuBlock   = New-Chk "Zablokuj aktualizacje Windows (ok. 30 lat)" 15 $cy $TaskPanel; $cy += 27
$CheckWuUnblock = New-Chk "Aktywuj aktualizacje Windows (odblokuj)" 15 $cy $TaskPanel;    $cy += 27
$cy += 10

$cy = New-CategoryHeader "Wydajnosc i prywatnosc" 15 $cy $TaskPanel
$CheckPower   = New-Chk "Plan zasilania: Wysoka wydajnosc" 15 $cy $TaskPanel; $cy += 27
$CheckDebloat = New-Chk "Debloat Windows" 15 $cy $TaskPanel;                 $cy += 27
$cy += 10

$cy = New-CategoryHeader "Bezpieczenstwo" 15 $cy $TaskPanel
$Check10 = New-Chk "Otworz panel BitLocker" 15 $cy $TaskPanel;   $cy += 27
$Check6  = New-Chk "Otworz ustawienia UAC" 15 $cy $TaskPanel;    $cy += 27
$cy += 10

$cy = New-CategoryHeader "Pulpit i personalizacja" 15 $cy $TaskPanel
$Check8 = New-Chk "Utworz folder 'Programy' na pulpicie" 15 $cy $TaskPanel;        $cy += 27
$Check9 = New-Chk "Pokaz ikone 'Moj komputer'" 15 $cy $TaskPanel;                  $cy += 27
$Check4 = New-Chk "Usun 'Dowiedz sie wiecej o tym obrazie'" 15 $cy $TaskPanel;      $cy += 27
$cy += 10

$cy = New-CategoryHeader "Narzedzia i raporty" 15 $cy $TaskPanel
$Check7       = New-Chk "Otworz Panel Sterowania" 15 $cy $TaskPanel;               $cy += 27
$CheckBattery = New-Chk "Generuj raport baterii (Pulpit)" 15 $cy $TaskPanel;        $cy += 27

# ------------------ TAB 2: Aplikacje ------------------
$AppList = New-Object System.Windows.Forms.CheckedListBox
$AppList.Location = New-Object System.Drawing.Point(15, 15)
$AppList.Size = New-Object System.Drawing.Size(510, 320)
$AppList.Font = New-Object System.Drawing.Font($FontUI, 9)
$AppList.CheckOnClick = $true
$AppList.BorderStyle = "FixedSingle"
$AppList.Enabled = $WingetOk
foreach ($app in $AppCatalog) {
    $idx = $AppList.Items.Add($app.Name)
    if ($app.Default) { $AppList.SetItemChecked($idx, $true) }
}
$Tab2.Controls.Add($AppList)
if (-not $WingetOk) {
    $Tab2.Controls.Add((New-Label "Winget niedostepny - zainstaluj 'App Installer' z Microsoft Store." 15 345 480 20 8 $true $ColErr))
}

# ------------------ Zawartosc dolu (stale widoczne) ------------------
$by = 10
$BtnAll = New-Object System.Windows.Forms.Button
$BtnAll.Text = "Zaznacz wszystko (konfiguracja)"
$BtnAll.Location = New-Object System.Drawing.Point(15, $by)
$BtnAll.Size = New-Object System.Drawing.Size(245, 36)
$BtnAll.FlatStyle = "Flat"
$BtnAll.FlatAppearance.BorderColor = [System.Drawing.Color]::LightGray
$BtnAll.BackColor = [System.Drawing.Color]::FromArgb(235,235,235)
$BtnAll.ForeColor = $ColText
$BtnAll.Font = New-Object System.Drawing.Font($FontUI, 8.5)
# Dotyczy TYLKO pierwszej zakladki (Konfiguracja systemu)
$BtnAll.Add_Click({
    foreach ($c in @($Check1,$Check2,$Check3,$Check4,$Check6,$Check7,$Check8,$Check9,$Check10,$CheckBattery,$CheckPower,$CheckDebloat,$CheckWuBlock,$CheckWuUnblock)) {
        $c.Checked = $true
    }
})
$BottomPanel.Controls.Add($BtnAll)

$BtnNone = New-Object System.Windows.Forms.Button
$BtnNone.Text = "Odznacz wszystko"
$BtnNone.Location = New-Object System.Drawing.Point(270, $by)
$BtnNone.Size = New-Object System.Drawing.Size(255, 36)
$BtnNone.FlatStyle = "Flat"
$BtnNone.FlatAppearance.BorderColor = [System.Drawing.Color]::LightGray
$BtnNone.BackColor = [System.Drawing.Color]::FromArgb(235,235,235)
$BtnNone.ForeColor = $ColText
$BtnNone.Font = New-Object System.Drawing.Font($FontUI, 8.5)
# Czysci WSZYSTKO - obie zakladki
$BtnNone.Add_Click({
    foreach ($c in @($Check1,$Check2,$Check3,$Check4,$Check6,$Check7,$Check8,$Check9,$Check10,$CheckBattery,$CheckPower,$CheckDebloat,$CheckWuBlock,$CheckWuUnblock)) {
        $c.Checked = $false
    }
    for ($i = 0; $i -lt $AppList.Items.Count; $i++) { $AppList.SetItemChecked($i, $false) }
})
$BottomPanel.Controls.Add($BtnNone)
$by += 44

$BtnExe = New-Object System.Windows.Forms.Button
$BtnExe.Text = "Wykonaj"
$BtnExe.Location = New-Object System.Drawing.Point(15, $by)
$BtnExe.Size = New-Object System.Drawing.Size(510, 46)
$BtnExe.FlatStyle = "Flat"
$BtnExe.FlatAppearance.BorderSize = 0
$BtnExe.BackColor = $ColBrand
$BtnExe.ForeColor = $ColWhite
$BtnExe.Font = New-Object System.Drawing.Font($FontUI, 11, [System.Drawing.FontStyle]::Bold)
$BottomPanel.Controls.Add($BtnExe)
$by += 56

$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Location = New-Object System.Drawing.Point(15, $by)
$ProgressBar.Size = New-Object System.Drawing.Size(510, 16)
$BottomPanel.Controls.Add($ProgressBar)
$by += 22

$StatusLabel = New-Label "Gotowy." 15 $by 510 18 8.5 $true $ColBrandDk
$BottomPanel.Controls.Add($StatusLabel)
$by += 22

$LogBox = New-Object System.Windows.Forms.RichTextBox
$LogBox.Location = New-Object System.Drawing.Point(15, $by)
$LogBox.Size = New-Object System.Drawing.Size(510, 100)
$LogBox.ReadOnly = $true
$LogBox.BackColor = [System.Drawing.Color]::FromArgb(250,250,250)
$LogBox.BorderStyle = "FixedSingle"
$LogBox.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$BottomPanel.Controls.Add($LogBox)

# ============================================================
#  FUNKCJE POMOCNICZE
# ============================================================

function Write-Log {
    param([string]$Msg, [string]$Level = "info")
    $color = switch ($Level) { "ok" { $ColOk }; "err" { $ColErr }; default { $ColText } }
    $LogBox.SelectionStart = $LogBox.TextLength
    $LogBox.SelectionColor = $color
    $LogBox.AppendText("$Msg`r`n")
    $LogBox.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

function Step {
    param([string]$Name, [scriptblock]$Action)
    $StatusLabel.Text = "Trwa: $Name ..."
    [System.Windows.Forms.Application]::DoEvents()
    try {
        & $Action
        Write-Log "[OK]   $Name" "ok"
    } catch {
        Write-Log "[BLAD] $Name -> $($_.Exception.Message)" "err"
    } finally {
        $ProgressBar.Style = "Blocks"
        $ProgressBar.Value = [Math]::Min($ProgressBar.Maximum, $ProgressBar.Value + 1)
        [System.Windows.Forms.Application]::DoEvents()
    }
}

function Install-WingetApp {
    # Przechwytuje na biezaco stdout wingetu i wrzuca to do logu (z lekkim wciecie),
    # dzieki czemu widac DOKLADNIE co robi w danej chwili (pobieranie, weryfikacja,
    # instalacja...), a nie tylko sam licznik sekund.
    param([string]$Name, [string]$Id)

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "winget"
    $psi.Arguments = "install --id $Id -e --silent --accept-package-agreements --accept-source-agreements"
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    $proc.Start() | Out-Null

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $ProgressBar.Style = "Marquee"
    $lastLine = ""

    while (-not $proc.HasExited) {
        while ($proc.StandardOutput.Peek() -ge 0) {
            $clean = $proc.StandardOutput.ReadLine().Trim()
            if ($clean -and $clean -ne $lastLine) {
                Write-Log "      $clean"
                $lastLine = $clean
            }
        }
        $secs = [Math]::Floor($sw.Elapsed.TotalSeconds)
        $StatusLabel.Text = "Trwa instalacja: $Name ... (${secs}s)"
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 150
    }
    # dobierz resztke bufora po zakonczeniu procesu
    while ($proc.StandardOutput.Peek() -ge 0) {
        $clean = $proc.StandardOutput.ReadLine().Trim()
        if ($clean -and $clean -ne $lastLine) {
            Write-Log "      $clean"
            $lastLine = $clean
        }
    }

    if ($proc.ExitCode -ne 0) {
        $errText = $proc.StandardError.ReadToEnd().Trim()
        $suffix = if ($errText) { " -> $errText" } else { "" }
        throw "winget zakonczyl instalacje '$Name' kodem $($proc.ExitCode)$suffix"
    }
}

function Set-RegDword {
    param([string]$Path, [string]$Name, [int]$Value)
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
}

function Block-WindowsUpdate {
    try { Set-Service -Name wuauserv -StartupType Disabled -ErrorAction Stop } catch {}
    try { Stop-Service -Name wuauserv -Force -ErrorAction Stop } catch {}
    Set-RegDword "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 1
    $farFuture = (Get-Date).AddYears(30).ToString("yyyy-MM-ddTHH:mm:ssZ")
    $p = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
    if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
    Set-ItemProperty -Path $p -Name "PauseUpdatesExpiryTime" -Value $farFuture -Force
    Set-ItemProperty -Path $p -Name "PauseFeatureUpdatesEndTime" -Value $farFuture -Force
    Set-ItemProperty -Path $p -Name "PauseQualityUpdatesEndTime" -Value $farFuture -Force
}

function Unblock-WindowsUpdate {
    Set-RegDword "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 0
    $p = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
    foreach ($n in @("PauseUpdatesExpiryTime","PauseFeatureUpdatesEndTime","PauseQualityUpdatesEndTime")) {
        try { Remove-ItemProperty -Path $p -Name $n -ErrorAction SilentlyContinue } catch {}
    }
    try { Set-Service -Name wuauserv -StartupType Manual -ErrorAction Stop } catch {}
    try { Start-Service -Name wuauserv -ErrorAction Stop } catch {}
}

function Set-HighPerformancePlan {
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
}

function Invoke-Debloat {
    foreach ($p in @("$env:SystemRoot\System32\OneDriveSetup.exe","$env:SystemRoot\SysWOW64\OneDriveSetup.exe")) {
        if (Test-Path $p) { Start-Process $p -ArgumentList "/uninstall" -Wait -ErrorAction SilentlyContinue }
    }
    $bloatPatterns = @("*Xbox*","*BingNews*","*BingWeather*","*ZuneMusic*","*ZuneVideo*","*SolitaireCollection*","*GetHelp*","*Getstarted*","*3DBuilder*","*MixedReality*","*People*")
    foreach ($pat in $bloatPatterns) {
        Get-AppxPackage -Name $pat -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
    }
    $cdm = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    foreach ($n in @("SubscribedContent-338388Enabled","SilentInstalledAppsEnabled","SystemPaneSuggestionsEnabled","ContentDeliveryAllowed","OemPreInstalledAppsEnabled","PreInstalledAppsEnabled")) {
        Set-RegDword $cdm $n 0
    }
    Set-RegDword "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
}

# ============================================================
#  WYKONANIE
# ============================================================
$BtnExe.Add_Click({
    $sysTasksChecked = @($Check1,$Check2,$Check3,$Check4,$Check6,$Check7,$Check8,$Check9,$Check10,$CheckBattery,$CheckPower,$CheckDebloat,$CheckWuBlock,$CheckWuUnblock) | Where-Object { $_.Checked }
    $appsChecked = @()
    for ($i = 0; $i -lt $AppList.Items.Count; $i++) {
        if ($AppList.GetItemChecked($i)) { $appsChecked += $AppCatalog[$i] }
    }

    if ($sysTasksChecked.Count -eq 0 -and $appsChecked.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Nic nie zaznaczono!", "FoxFix - Blad")
        return
    }
    if ($CheckWuBlock.Checked -and $CheckWuUnblock.Checked) {
        [System.Windows.Forms.MessageBox]::Show("Zaznaczono jednoczesnie blokade i aktywacje aktualizacji - odznacz jedno z nich.", "FoxFix - Blad")
        return
    }

    $res = [System.Windows.Forms.MessageBox]::Show("Czy chcesz uruchomic zaznaczone zadania?", "Potwierdzenie", "YesNo", "Question")
    if ($res -ne "Yes") { return }

    $LogBox.Clear()
    $BtnExe.Enabled = $false
    $BtnAll.Enabled = $false
    $BtnNone.Enabled = $false
    $ProgressBar.Style = "Blocks"
    $ProgressBar.Value = 0
    $ProgressBar.Maximum = [Math]::Max(1, $sysTasksChecked.Count + $appsChecked.Count)

    if ($Check1.Checked) { Step "WinUtil (Chris Titus)" { Start-Process powershell.exe -ArgumentList "-NoProfile -NoExit -Command `"irm 'https://christitus.com/win' | iex`"" } }
    if ($Check2.Checked) { Step "Aktywator Windows (MAS)" { Start-Process powershell.exe -ArgumentList "-NoProfile -NoExit -Command `"irm 'https://get.activated.win' | iex`"" } }
    if ($Check3.Checked) {
        Step "Ustawienia OEM (FoxFix.it)" {
            $p = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"
            if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
            Set-ItemProperty -Path $p -Name "Manufacturer" -Value "FoxFix.it" -Force
            Set-ItemProperty -Path $p -Name "SupportPhone" -Value "572 571 704" -Force
            Set-ItemProperty -Path $p -Name "SupportURL" -Value "https://foxfix.it/" -Force
        }
    }
    if ($Check4.Checked) {
        Step "Usun 'Dowiedz sie wiecej o tym obrazie'" {
            Set-RegDword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}" 1
        }
    }
    if ($Check6.Checked) { Step "Otwarcie ustawien UAC" { Start-Process "UserAccountControlSettings.exe" } }
    if ($Check7.Checked) { Step "Otwarcie Panelu Sterowania" { Start-Process "control.exe" } }
    if ($Check10.Checked) { Step "Otwarcie panelu BitLocker" { Start-Process "control.exe" -ArgumentList "/name Microsoft.BitLockerDriveEncryption" } }
    if ($CheckBattery.Checked) {
        Step "Raport baterii" {
            $reportPath = "$env:USERPROFILE\Desktop\Battery_Report.html"
            Start-Process powercfg -ArgumentList "/batteryreport /output `"$reportPath`"" -NoNewWindow -Wait
            if (Test-Path $reportPath) { Start-Process $reportPath }
        }
    }
    if ($Check8.Checked) {
        Step "Folder 'Programy' na pulpicie" {
            $programsFolder = Join-Path ([Environment]::GetFolderPath("Desktop")) "Programy"
            if (-not (Test-Path $programsFolder)) { New-Item -ItemType Directory -Path $programsFolder | Out-Null }
        }
    }
    if ($Check9.Checked) {
        Step "Pokazanie ikony 'Moj komputer'" {
            Set-RegDword "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" 0
        }
    }
    if ($CheckPower.Checked) { Step "Plan zasilania: Wysoka wydajnosc" { Set-HighPerformancePlan } }
    if ($CheckDebloat.Checked) { Step "Debloat Windows" { Invoke-Debloat } }
    if ($CheckWuBlock.Checked) { Step "Blokada aktualizacji Windows (~30 lat)" { Block-WindowsUpdate } }
    if ($CheckWuUnblock.Checked) { Step "Aktywacja aktualizacji Windows" { Unblock-WindowsUpdate } }

    if ($appsChecked.Count -gt 0) {
        Write-Log "--- Winget: odswiezanie zrodel ---"
        $StatusLabel.Text = "Odswiezanie zrodel winget..."
        [System.Windows.Forms.Application]::DoEvents()
        try { winget source update | Out-Null } catch {}
        foreach ($app in $appsChecked) {
            if ($app.Id) {
                Step "Instalacja: $($app.Name)" { Install-WingetApp -Name $app.Name -Id $app.Id }
            } elseif ($app.Url) {
                Step "Otwarcie strony: $($app.Name)" { Start-Process $app.Url }
            }
        }
    }

    $StatusLabel.Text = "Zakonczono."
    Write-Log "--- Zakonczono ---"
    $BtnExe.Enabled = $true
    $BtnAll.Enabled = $true
    $BtnNone.Enabled = $true
    [System.Windows.Forms.MessageBox]::Show("Wszystkie zadania zostaly wykonane. Szczegoly w logu.", "FoxFix - Gotowe")
})

$Form.ShowDialog() | Out-Null
