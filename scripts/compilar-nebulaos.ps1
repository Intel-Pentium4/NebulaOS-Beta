$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'Compilador de NebulaOS - nube'

Write-Host ''
Write-Host '==============================================' -ForegroundColor Cyan
Write-Host '       COMPILADOR WEB DE NEBULAOS 0.1' -ForegroundColor Cyan
Write-Host '==============================================' -ForegroundColor Cyan
Write-Host 'No instala Debian ni modifica los discos del PC.'
Write-Host 'La ISO se construye en los servidores de GitHub.'
Write-Host ''

$repo = Read-Host 'Escribe el repositorio GitHub (usuario/repositorio)'
if ($repo -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') {
    Write-Host 'El formato debe ser usuario/repositorio.' -ForegroundColor Yellow
    Write-Host 'Primero crea el repositorio y sube el CONTENIDO de la carpeta NebulaOS-0.1 a su raiz.'
    Start-Process 'https://github.com/new'
    exit 1
}

Write-Host ''
Write-Host '1. Gaming (incluye herramientas de juego)' 
Write-Host '2. Minimal (menos aplicaciones preinstaladas)'
$selection = Read-Host 'Elige 1 o 2'
switch ($selection) {
    '1' { $profile = 'gaming' }
    '2' { $profile = 'minimal' }
    default { Write-Host 'Opcion no valida.' -ForegroundColor Yellow; exit 1 }
}

$workflowUrl = "https://github.com/$repo/actions/workflows/build-iso.yml"
$gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $gh) {
    Write-Host ''
    Write-Host 'No encuentro GitHub CLI (gh). Abrire el constructor web.' -ForegroundColor Yellow
    Write-Host 'En la pagina, selecciona Run workflow, elige el perfil y confirma.'
    Write-Host 'Cuando termine, abre el resultado y descarga el artefacto NebulaOS-...-ISO.'
    Start-Process $workflowUrl
    exit 0
}

# Sign-in is handled by GitHub CLI and its official browser flow; no token is stored here.
& gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'Necesitas iniciar sesion con GitHub CLI. Sigue sus instrucciones en pantalla.' -ForegroundColor Yellow
    & gh auth login
    if ($LASTEXITCODE -ne 0) {
        Start-Process $workflowUrl
        exit 1
    }
}

$previousRun = (& gh run list --repo $repo --workflow build-iso.yml --event workflow_dispatch --limit 1 --json databaseId --jq '.[0].databaseId' 2>$null | Out-String).Trim()
Write-Host ''
Write-Host "Solicitando la compilacion del perfil $profile..." -ForegroundColor Cyan
& gh workflow run build-iso.yml --repo $repo --ref main -f "profile=$profile"
if ($LASTEXITCODE -ne 0) {
    Write-Host 'No se pudo iniciar el flujo. Comprueba que el repositorio usa la rama main y que el workflow ya esta subido.' -ForegroundColor Yellow
    Start-Process $workflowUrl
    exit 1
}

$runId = $null
for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 3
    $candidate = (& gh run list --repo $repo --workflow build-iso.yml --event workflow_dispatch --limit 1 --json databaseId --jq '.[0].databaseId' 2>$null | Out-String).Trim()
    if ($candidate -and $candidate -ne 'null' -and $candidate -ne $previousRun) {
        $runId = $candidate
        break
    }
}

if (-not $runId) {
    Write-Host 'La solicitud se envio, pero no pude detectar el identificador de la ejecucion.' -ForegroundColor Yellow
    Start-Process $workflowUrl
    exit 1
}

Write-Host "Compilacion iniciada (ejecucion $runId). Se mostrara el progreso..." -ForegroundColor Cyan
& gh run watch $runId --repo $repo --exit-status
if ($LASTEXITCODE -ne 0) {
    Write-Host 'La compilacion ha fallado. Abriendo los registros para ver el error.' -ForegroundColor Red
    Start-Process $workflowUrl
    exit 1
}

$outDir = Join-Path $PSScriptRoot '..\SALIDA_NEBULAOS'
$outDir = [System.IO.Path]::GetFullPath($outDir)
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
& gh run download $runId --repo $repo --name "NebulaOS-$profile-ISO" --dir $outDir
if ($LASTEXITCODE -ne 0) {
    Write-Host 'La ISO se compilo, pero no pude descargar el artefacto automaticamente.' -ForegroundColor Yellow
    Start-Process $workflowUrl
    exit 1
}

Write-Host ''
Write-Host 'Terminado. Busca binary.iso en:' -ForegroundColor Green
Write-Host $outDir -ForegroundColor Green
Write-Host 'Verifica binary.iso.sha256 antes de grabar la ISO en un USB.'
