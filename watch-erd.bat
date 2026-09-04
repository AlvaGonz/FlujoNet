@echo off
REM watch-erd.bat - Watch for PostgreSQL schema changes and auto-update ERD
REM Usage: watch-erd.bat [interval_seconds]

set INTERVAL=%1
if "%INTERVAL%"=="" set INTERVAL=10

echo Watching for schema changes every %INTERVAL% seconds...
echo Press Ctrl+C to stop
echo.

powershell -ExecutionPolicy Bypass -Command "& { while($true) { Start-Sleep -Seconds %INTERVAL%; $pgRunning = docker ps --format '{{.Names}}' | Select-String 'flujonet-postgres'; if($pgRunning) { $output = docker exec flujonet-postgres-1 pg_dump --schema-only --no-privileges --no-owner -U postgres -d flujonet 2>$null; $currentHash = ($output | Out-String).GetHashCode(); $lastHash = Get-Content erd-out\.last-hash -ErrorAction SilentlyContinue; if($currentHash -ne $lastHash) { Write-Host \"[$(Get-Date -Format 'HH:mm:ss')] Schema changed, updating ERD...\" -ForegroundColor Cyan; powershell -ExecutionPolicy Bypass -File erd-out\update-erd.ps1; $currentHash | Out-File erd-out\.last-hash -NoNewline } else { Write-Host \"[$(Get-Date -Format 'HH:mm:ss')] No changes\" -ForegroundColor Gray } } else { Write-Host \"[$(Get-Date -Format 'HH:mm:ss')] PostgreSQL not running\" -ForegroundColor Yellow } } }"
