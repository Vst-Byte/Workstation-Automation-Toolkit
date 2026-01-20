<#
.SYNOPSIS
    Workstation Automation Toolkit - Diagnóstico, Manutenção e Organização.

.DESCRIPTION
    Suíte de automação CLI desenvolvida para suporte técnico e administração de sistemas.
    Centraliza rotinas essenciais de manutenção preventiva e corretiva em um único menu interativo.
    
    Funcionalidades incluídas:
    1. Organização Inteligente de Arquivos (Downloads).
    2. Limpeza de Arquivos Temporários e Cache (%TEMP%).
    3. Coleta de Inteligência do Sistema (Hardware, Serial, Rede e Uptime).
    4. Reparo de Conectividade de Rede (DNS Flush/IP Renew).
    5. Análise de Logs de Erros Críticos do Windows.

.NOTES
    Version:    1.2.0
    Author:     Enchanted
    Target:     Windows 10/11 & Windows Server
    Ideal for:  Helpdesk, Field Service e Manutenção Preventiva de Workstations.

.AUTHOR
    Enchanted
#>
# ===============================================
#              Ferramentas Visuais
# ===============================================
function Write-Center {
    param(
        [string]$Texto,
        [ConsoleColor]$Cor = "Yellow",
        [ConsoleColor]$Fundo = "Black" 
    )

    $LarguraJanela = $Host.UI.RawUI.WindowSize.Width
    
    $EspacosEsquerda = [math]::Max(0, [int](($LarguraJanela - $Texto.Length) / 2))
    
    $TextoCentralizado = (" " * $EspacosEsquerda) + $Texto

    Write-Host $TextoCentralizado -ForegroundColor $Cor -BackgroundColor $Fundo
}
function Write-Center-Detail {
    param(
        [string]$Label,   
        [string]$Value,   
        [ConsoleColor]$CorLabel = "Green", 
        [ConsoleColor]$CorValue = "White"  
    )

    $TextoCompleto = "$Label $Value"
    
    $LarguraJanela = $Host.UI.RawUI.WindowSize.Width
    
    $EspacosEsquerda = [math]::Max(0, [int](($LarguraJanela - $TextoCompleto.Length) / 2))
    $Margem = " " * $EspacosEsquerda


    Write-Host $Margem -NoNewline

    Write-Host "$Label " -ForegroundColor $CorLabel -NoNewline
    
    Write-Host $Value -ForegroundColor $CorValue
}
function Push-ToCenter {
    param(
        [int]$TamanhoDoMenu = 12
    )

    $AlturaJanela = $Host.UI.RawUI.WindowSize.Height
    
    $EspacosTopo = [math]::Max(0, [int](($AlturaJanela - $TamanhoDoMenu) / 2))
    
    for ($i = 0; $i -lt $EspacosTopo; $i++) {
        Write-Host ""
    }
}
function Read-Center {
    param(
        [string]$Mensagem
    )
    $LarguraJanela = $Host.UI.RawUI.WindowSize.Width
    
    $EspacosEsquerda = [math]::Max(0, [int](($LarguraJanela - $Mensagem.Length) / 2))
    
    $Margem = " " * $EspacosEsquerda
    
    return Read-Host "$Margem$Mensagem"
}
# ==========================================
#       ÁREA DE FUNÇÕES (FERRAMENTAS)
# ==========================================

function AccessDownloadFolder {
    Write-Center ""
    Write-Center "=====================================" -ForegroundColor Cyan
    Write-Center "    Accessing Downloads Folders...   " -ForegroundColor Cyan
    Write-Center "=====================================" -ForegroundColor Cyan
    Write-Center ""
    Start-Sleep -Seconds 1

    Write-Center "Organizing all the Files..." -ForegroundColor Cyan
    Start-Sleep -Seconds 1

    $FolderOrganizer = Get-ChildItem -Path $HOME\Downloads -File 
    
    foreach ($ArquivoUnico in $FolderOrganizer) {
        
        $PathFolder = ""
        
        # Lógica para separar imagens
        if ($ArquivoUnico.Extension -in @(".jpg", ".png", ".jpeg", ".gif", ".bmp", ".webp")){
            $PathFolder = "$Home\Pictures\Folder$($ArquivoUnico.Extension)"
        } else {
            $PathFolder = "$Home\Downloads\Folder$($ArquivoUnico.Extension)"
        }

        # Verifica e cria pasta se necessário
        if (-not (Test-Path $PathFolder)) {
            Write-Center ""
            Write-Center "Creating New Folder: $PathFolder" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            New-Item -Path $PathFolder -ItemType Directory -Force | Out-Null
        }
        Write-Center ""
        Write-Center "Processing: $($ArquivoUnico.Name)" -ForegroundColor Gray
        Start-Sleep -Seconds 1
        Move-Item -Path $ArquivoUnico.FullName -Destination $PathFolder   
    }
    Write-Center ""
    Write-Center "Organization Completed!" -cor Green
    Write-Center ""
}

function CleanTempFiles {
    Write-Center ""
    Write-Center "Accessing Temp Files..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1

    $FileCleaner = Get-ChildItem -Path $env:TEMP -File -Recurse -ErrorAction SilentlyContinue
    
    if ($FileCleaner) {
    Write-Center ""
    Write-Center "Found $($FileCleaner.Count) files in Temp." -ForegroundColor Cyan 
    Write-Center ""
    Start-Sleep -Seconds 1
    Write-Center "Cleaning Now..." -ForegroundColor Cyan 
    Start-Sleep -Seconds 1

    }else{
    Write-Center "Temp folder is mostly clean or locked." -ForegroundColor Gray
    }
   
    remove-item -Path $env:temp -Recurse -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Write-Center ""
    Write-Center "Cleanup finished! (Locked files were skipped)" -Cor Green
    Write-Center ""
}
function Get-SystemInfo {
    Write-Host ""
    Write-Center "Colecting System data..." -Cor Yellow
    Write-Host ""

    $OS = Get-CimInstance Win32_OperatingSystem
    $CPU = Get-CimInstance Win32_Processor
    $Disco = Get-Volume -DriveLetter C
    $BIOS = Get-CimInstance Win32_BIOS 
    $GPU = Get-CimInstance Win32_VideoController
    
    try {
        $Rede = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -First 1
        $IPAddress = $Rede.IPv4Address.IPAddress
    } catch {
        $IPAddress = "Not Detected"
    }

    $MemoriaTotal = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
    $MemoriaLivre = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)
    $DiscoLivre   = [math]::Round($Disco.SizeRemaining / 1GB, 2)
    $DiscoTotal = [math]::Round($Disco.Size / 1GB, 2)

    Write-Center-Detail -Label "Hostname:" -Value "$($OS.CSName)" 
    Write-Center-Detail ""
    Start-Sleep -Seconds 1
    Write-Center-Detail -Label "Serial Number:" -Value "$($BIOS.SerialNumber)" 
    Write-Center-Detail ""
    Start-Sleep -Seconds 1
    Write-Center-Detail -Label "IP Address:" -Value "$IPAddress" 
    Write-Center-Detail ""
    Start-Sleep -Seconds 1
    Write-Center-Detail -Label "System:" -Value "$($OS.Caption) ($($OS.OSArchitecture))" 
    Write-Center-Detail ""
    Start-Sleep -Seconds 1
    Write-Center-Detail -Label "CPU:" -Value "$($CPU.Name)" 
    Write-Center-Detail ""
    Start-Sleep -Seconds 1
    Write-Center-Detail -Label "RAM:" -Value "${MemoriaLivre} GB Free from ${MemoriaTotal} GB" 
    Write-Center-Detail ""
    Start-Sleep -Seconds 1
    Write-Center-Detail -Label "GPU:" -Value "$($GPU.Name)" 
    Write-Center-Detail ""
    Start-Sleep -Seconds 1
    Write-Center-Detail -Label "Disk (C:):" -Value "${DiscoLivre} GB Free from: ${DiscoTotal}" 
    Write-Center-Detail ""
    Start-Sleep -Seconds 1
    $Uptime = (Get-Date) - $OS.LastBootUpTime
    Write-Center -Label "Time On:" -Value "$($Uptime.Days) days, $($Uptime.Hours) hours, $($Uptime.Minutes) min" 
    
    Write-Center ""
}
function Repair-Network {
    Write-Center ""
    Write-Center "EXECUTING NETWORK REPAIR..." -Cor Yellow
    Write-Center ""
    Start-Sleep -Seconds 1
    Write-Center-Detail -label "1." -Value "Clearing DNS Cache..."
    Write-Center ""
    Start-Sleep -Seconds 1
    Clear-DnsClientCache
    Write-Center "[OK] Cache Cleared." -Cor Green
    Write-Center ""
    Start-Sleep -Seconds 1
    
    Write-Center-Detail -label "2." -Value  "Renewing IP Address..." 
    Write-Center ""
    Write-Center "Disclaimer: This may cause a brief disconnection)" -Cor Red
    Write-Center ""
    ipconfig /renew | Out-Null
    Write-Center "[OK] IP Renewed." -Cor Green

    Write-Host ""
}
function Get-ErrorLogs {
    Write-Center ""
    Write-Center "SCANNING SYSTEM ERROR LOGS..." -Cor Yellow
    Write-Center ""

    $Errors = Get-EventLog -LogName System -EntryType Error -Newest 5 -ErrorAction SilentlyContinue

    if ($Errors) {
        foreach ($E in $Errors) {
            Write-Center "Time: $($E.TimeGenerated)" -Cor Cyan
            Write-Center ""
            Write-Center "Source: $($E.Source)" -Cor White
            Write-Center ""
            Write-Center "Message: $($E.Message)" -Cor Gray
            Write-Center ""
            Write-Center "---------------------------------" -Cor DarkGray
            Write-Center ""
        }
    } else {
        Write-Center "No critical errors found recently. System is healthy!" -Cor Green
    }

    Write-Host ""
}

# ==========================================
#         EXECUÇÃO PRINCIPAL (MENU)
# ==========================================

$Sair = $False 

do {
    Clear-Host

    Push-ToCenter -TamanhoDoMenu 12
    
    Write-Center "=========================================" 
    Write-Center "           Workstation-Automated         " 
    Write-Center "=========================================" 
    Write-Center ""
    Write-Center "  1. Organize Files (Downloads)            "
    Write-Center ""
    Write-Center "  2. Clean Files (%Temp%)                  "
    Write-Center ""
    Write-Center "  3. Collect System Data                   "
    Write-Center ""
    Write-Center "  4. Repair Network Connection             "
    Write-Center ""
    Write-Center "  5. Collect ErrorLogs                     "
    Write-Center ""
    Write-Center "  6. Exit                                  "
    Write-Center "-----------------------------------------"
    Write-Center ""
    
    $Opcao = Read-Center " Choose an Option " -Cor White
    
    switch ($Opcao) {
        "1" { 
            AccessDownloadFolder
            Read-Center "Press ENTER to return to the menu..." -Cor Gray
        }
        "2" { 
            CleanTempFiles
            Read-Center "Press ENTER to return to the menu..." -Cor Gray
        }
        "3"{
            Get-SystemInfo
            Read-Center "Press ENTER to return to the menu..." -Cor Gray
        }
        "4"{
            Repair-Network
            Read-Center "Press ENTER to return to the menu..." -Cor Gray
        }
        "5"{
            Get-ErrorLogs
            Read-Center "Press ENTER to return to the menu..." -Cor Gray
        }
        "6" { 
            Write-Center ""
            Write-Center "Closing..." -Cor Red
            Start-Sleep -Seconds 1
            $Sair = $True 
        } 
      
        Default { 
            Write-Center ""
            Write-Center "Invalid Option!" -Cor Red
            Start-Sleep -Seconds 1
        }
    }

} until ($Sair -eq $True)
