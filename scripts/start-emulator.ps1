param(
    [switch]$Headless,
    [switch]$Check,
    [switch]$CreateOnly,
    [string]$Name = 'appium_ts_api35',
    [string]$SdkPath = $env:ANDROID_HOME,
    [int]$Port = 5556
)

$ErrorActionPreference = 'Stop'
if ($Name -notmatch '^[A-Za-z0-9_-]+$') { throw 'Invalid AVD name.' }
if ($Port -lt 5554 -or $Port -gt 5682 -or $Port % 2 -ne 0) {
    throw 'Port must be an even number between 5554 and 5682.'
}
$projectRoot = Split-Path $PSScriptRoot -Parent
if (-not $SdkPath) { $SdkPath = [Environment]::GetEnvironmentVariable('ANDROID_HOME', 'User') }
if (-not $SdkPath) { throw 'Set ANDROID_HOME to your Android SDK directory, or pass -SdkPath.' }
$env:ANDROID_HOME = $SdkPath
if (-not $env:JAVA_HOME) { $env:JAVA_HOME = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'User') }
if ($env:JAVA_HOME) { $env:Path = "$env:JAVA_HOME\bin;$env:Path" }

# AVD state belongs to this project, even when the SDK is shared.
$env:ANDROID_AVD_HOME = Join-Path $projectRoot '.android-avd'
$emulatorPath = Join-Path $SdkPath 'emulator\emulator.exe'
$image = 'system-images;android-35;google_apis;x86_64'
if (-not (Test-Path -LiteralPath $emulatorPath)) { throw "Missing emulator: $emulatorPath" }
if (-not (Test-Path -LiteralPath (Join-Path $SdkPath 'system-images\android-35\google_apis\x86_64\package.xml'))) {
    throw "Install $image using Android Studio SDK Manager first."
}
Write-Host "Project: $projectRoot"
Write-Host "SDK (shared tools): $SdkPath"
Write-Host "AVD directory: $env:ANDROID_AVD_HOME"
Write-Host "Device: emulator-$Port; Headless: $Headless"
if ($Check) { return }

New-Item -ItemType Directory -Force -Path $env:ANDROID_AVD_HOME | Out-Null
if (-not (Test-Path -LiteralPath (Join-Path $env:ANDROID_AVD_HOME "$Name.ini"))) {
    $manager = Join-Path $SdkPath 'cmdline-tools\latest\bin\avdmanager.bat'
    if (-not (Test-Path -LiteralPath $manager)) {
        $candidate = Get-ChildItem -LiteralPath (Join-Path $SdkPath 'cmdline-tools') -Directory |
            Sort-Object Name -Descending |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'bin\avdmanager.bat') } |
            Select-Object -First 1
        if (-not $candidate) { throw 'Install Android SDK Command-line Tools first.' }
        $manager = Join-Path $candidate.FullName 'bin\avdmanager.bat'
    }
    'no' | & $manager create avd --name $Name --package $image --device 'pixel_2'
    if ($LASTEXITCODE -ne 0) { throw 'Could not create the project AVD.' }
}
if ($CreateOnly) { return }
$emulatorArgs = @('-avd', $Name, '-port', "$Port", '-no-boot-anim', '-no-snapshot', '-gpu', 'swiftshader')
if ($Headless) { $emulatorArgs += '-no-window' }
& $emulatorPath @emulatorArgs
if ($LASTEXITCODE -ne 0) { throw 'Emulator failed. Stop an existing instance of this AVD before restarting.' }
