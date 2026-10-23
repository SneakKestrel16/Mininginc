# Heartwake launcher: installs or updates the game from the latest GitHub release, then starts it.
# The game lives in .\game next to this script; save data lives in %APPDATA%\Godot, so replacing
# .\game never touches saves.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'  # Invoke-WebRequest is many times slower with the progress bar on

$repo = 'SneakKestrel16/Mininginc'
$asset_name = 'Heartwake-windows.zip'
$game = Join-Path $PSScriptRoot 'game'
$version_file = Join-Path $game 'version.txt'
$installed = if (Test-Path $version_file) { (Get-Content $version_file -Raw).Trim() } else { '' }

try {
    $release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest" -Headers @{ 'User-Agent' = 'Heartwake-Launcher' } -TimeoutSec 15
    if ($release.tag_name -ne $installed) {
        $asset = $release.assets | Where-Object name -eq $asset_name | Select-Object -First 1
        if (-not $asset) { throw "release $($release.tag_name) has no $asset_name" }
        Write-Host "Updating Heartwake $(if ($installed) { $installed } else { '(not installed)' }) -> $($release.tag_name)..."
        $zip = Join-Path $env:TEMP $asset_name
        $staged = Join-Path $PSScriptRoot 'game.new'
        $old = Join-Path $PSScriptRoot 'game.old'
        Invoke-WebRequest $asset.browser_download_url -OutFile $zip -UseBasicParsing
        Remove-Item $staged, $old -Recurse -Force -ErrorAction SilentlyContinue
        Expand-Archive $zip $staged
        Set-Content (Join-Path $staged 'version.txt') $release.tag_name
        # Rename, never delete in place: a running game locks its exe, so the rename fails whole
        # and the installed copy survives intact.
        if (Test-Path $game) { Rename-Item $game 'game.old' }
        Rename-Item $staged 'game'
        Remove-Item $old, $zip -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Updated to $($release.tag_name)."
    } else {
        Write-Host "Heartwake $installed is up to date."
    }
} catch {
    Write-Warning "Update failed: $($_.Exception.Message)"
    Write-Warning 'Close Heartwake if it is running. Starting the installed version.'
}

$exe = Join-Path $game 'Heartwake.exe'
if (-not (Test-Path $exe)) {
    Write-Host 'Heartwake is not installed and the download failed. Check your connection and try again.'
    Read-Host 'Press Enter to close'
    exit 1
}
Start-Process $exe -WorkingDirectory $game
