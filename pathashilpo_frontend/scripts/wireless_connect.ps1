<#
.SYNOPSIS
  Pairs and connects to a phone over wireless ADB using values from .env,
  then optionally installs and launches the release APK.

.DESCRIPTION
  Reads pathashilpo_frontend\.env (see .env.example for the format and where
  each value comes from on your phone). Never hardcodes an IP, port, pairing
  code, or SDK path - every developer keeps their own .env locally and it is
  git-ignored.

.EXAMPLE
  .\scripts\wireless_connect.ps1
      Pair + connect only.

.EXAMPLE
  .\scripts\wireless_connect.ps1 -InstallApk
      Pair + connect, then install and launch the release APK.
#>

param(
    [switch]$InstallApk
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$EnvFile = Join-Path $RepoRoot '.env'

if (-not (Test-Path $EnvFile)) {
    Write-Host "No .env found at $EnvFile" -ForegroundColor Red
    Write-Host "Copy .env.example to .env and fill in your own pairing/connect values." -ForegroundColor Yellow
    exit 1
}

# --- load .env into a hashtable (simple KEY=VALUE, ignores blank lines and #) ---
$config = @{}
Get-Content $EnvFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq '' -or $line.StartsWith('#')) { return }
    $parts = $line -split '=', 2
    if ($parts.Count -eq 2) { $config[$parts[0].Trim()] = $parts[1].Trim() }
}

function Require($key) {
    if (-not $config.ContainsKey($key) -or [string]::IsNullOrWhiteSpace($config[$key])) {
        Write-Host "Missing $key in .env - copy .env.example and fill it in from your phone's Wireless debugging screen." -ForegroundColor Red
        exit 1
    }
    return $config[$key]
}

$pairHost    = Require 'ADB_PAIR_HOST'
$pairPort    = Require 'ADB_PAIR_PORT'
$pairCode    = Require 'ADB_PAIR_CODE'
$connectHost = Require 'ADB_CONNECT_HOST'
$connectPort = Require 'ADB_CONNECT_PORT'
$appId       = if ($config.ContainsKey('APP_ID') -and $config['APP_ID']) { $config['APP_ID'] } else { 'com.example.pathashilpa' }

# --- locate adb: explicit SDK root in .env, else common install locations ---
$adb = $null
if ($config.ContainsKey('ANDROID_SDK_ROOT') -and $config['ANDROID_SDK_ROOT']) {
    $candidate = Join-Path $config['ANDROID_SDK_ROOT'] 'platform-tools\adb.exe'
    if (Test-Path $candidate) { $adb = $candidate }
}
if (-not $adb) {
    foreach ($p in @(
        "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe",
        "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
        "$env:USERPROFILE\AppData\Local\Android\sdk\platform-tools\adb.exe"
    )) {
        if (Test-Path $p) { $adb = $p; break }
    }
}
if (-not $adb) {
    $cmd = Get-Command adb -ErrorAction SilentlyContinue
    if ($cmd) { $adb = $cmd.Source }
}
if (-not $adb) {
    Write-Host "Could not find adb. Set ANDROID_SDK_ROOT in .env to your Android SDK folder." -ForegroundColor Red
    exit 1
}

Write-Host "Using adb: $adb" -ForegroundColor DarkGray

Write-Host ("Pairing with {0}:{1} ..." -f $pairHost, $pairPort) -ForegroundColor Cyan
& $adb pair "$($pairHost):$($pairPort)" $pairCode
if ($LASTEXITCODE -ne 0) {
    Write-Host "Pairing failed - the pairing code/port are shown fresh each time you open 'Pair device with pairing code' on the phone. Update .env and retry." -ForegroundColor Red
    exit 1
}

Write-Host ("Connecting to {0}:{1} ..." -f $connectHost, $connectPort) -ForegroundColor Cyan
& $adb connect "$($connectHost):$($connectPort)"

Write-Host ""
Write-Host "Devices:" -ForegroundColor Cyan
& $adb devices -l

if ($InstallApk) {
    $apk = Join-Path $RepoRoot 'build\app\outputs\flutter-apk\app-release.apk'
    if (-not (Test-Path $apk)) {
        Write-Host ""
        Write-Host "No release APK at $apk - run 'flutter build apk --release' first." -ForegroundColor Yellow
        exit 1
    }
    $device = "$($connectHost):$($connectPort)"
    Write-Host ""
    Write-Host "Installing $apk to $device ..." -ForegroundColor Cyan
    & $adb -s $device install -r $apk
    Write-Host "Launching $appId ..." -ForegroundColor Cyan
    & $adb -s $device shell monkey -p $appId -c android.intent.category.LAUNCHER 1 | Out-Null
    Write-Host "Done." -ForegroundColor Green
}
