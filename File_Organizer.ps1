<#
.SYNOPSIS
    Automated File Sorter - Organizador de Arquivos por Extensão.

.DESCRIPTION
    Script destinado à manutenção de estações de trabalho.
    Varre um diretório especificado, identifica tipos de arquivos e os organiza
    em pastas temáticas (Documentos, Imagens, Instaladores) para manter o
    ambiente limpo e organizado.

.NOTES
    Ideal para limpeza de pastas de Downloads ou diretórios de Logs de servidores.

.AUTHOR
    Enchanted
#>

# --- FUNÇÃO 1: MOVER ARQUIVOS/GERAR PASTAS (CORE) ---
function AccessDownloadFolder {

    $FolderOrganizer = Get-ChildItem -Path $HOME\Downloads -File 
    
    foreach ($ArquivoUnico in $FolderOrganizer) {
        

        $PathFolder = ""
        if ($ArquivoUnico.Extension -in @(".jpg", ".png", ".jpeg", ".gif", ".bmp", ".webp")){
            
            $PathFolder = "$Home\Downloads\Image\Folder$($ArquivoUnico.Extension)"
        }else  {
            $PathFolder = "$Home\Downloads\Folder$($ArquivoUnico.Extension)"
        }
        if (-not (Test-Path $PathFolder)) {
            
            Write-Host "Criando nova pasta: $PathFolder" -ForegroundColor Yellow
            New-Item -Path $PathFolder -ItemType Directory -Force | Out-Null
        }
        Write-Host "Processando: $($ArquivoUnico.Name)" -ForegroundColor Gray
        Move-Item -Path $ArquivoUnico.FullName -Destination $PathFolder   
 }

}



# --- EXECUÇÃO PRINCIPAL (MAIN) ---

Clear-Host
Write-Host "=====================================" -ForegroundColor DarkBlue
Write-Host "    Accessing Downloads Folders...   " -ForegroundColor DarkBlue
Write-Host "=====================================" -ForegroundColor DarkBlue
Write-Host ""


Write-Host "=====================================" -ForegroundColor DarkBlue
Write-Host "    Creating Folders to Organize...   " -ForegroundColor DarkBlue 
Write-Host "=====================================" -ForegroundColor DarkBlue

Write-Host "                                     " -ForegroundColor DarkBlue
Write-Host "=====================================" -ForegroundColor DarkBlue
Write-Host "      Folders Verified/Created.      " -ForegroundColor DarkGreen
Write-Host "=====================================" -ForegroundColor DarkBlue
Write-Host ""


AccessDownloadFolder

Write-Host ""
Write-Host "Organization Completed! " -ForegroundColor Magenta