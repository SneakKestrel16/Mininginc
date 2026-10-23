# Installing Heartwake

Heartwake runs on Windows 10 or 11 (64-bit). The launcher downloads the game and keeps it up to
date: every time you start it, it checks for a new version first.

## Install

1. Download **[Heartwake-Launcher.zip](https://github.com/SneakKestrel16/Mininginc/releases/latest/download/Heartwake-Launcher.zip)**.
2. Right-click the zip, choose **Extract All**, and extract it to a folder you will keep, such as
   `Documents\Heartwake`. Do not run it from inside the zip.
3. Double-click **`Heartwake.cmd`**. The first run downloads the game into a `game` folder next to
   it and starts it.

If Windows shows "Windows protected your PC", click **More info**, then **Run anyway**. The game
is not code-signed, so Windows warns about every build the first time.

## Playing and updating

Always start the game with **`Heartwake.cmd`**, not `game\Heartwake.exe`, so updates install. A
console window opens briefly, prints the version, and closes when the game starts.

Your save is stored in `%APPDATA%\Godot\app_userdata\Heartwake`, outside the launcher folder, so
updates never touch it.

## Troubleshooting

| You see | Do this |
|---|---|
| `Update failed`, and then the game starts | The old version still works. Close any running Heartwake and start the launcher again. Without internet the launcher just starts the installed version. |
| `Heartwake is not installed and the download failed` | The first download needs internet. Check your connection and try again. |
| The console window closes and nothing starts | Open `game\` and run `Heartwake.exe` directly to see whether the game itself fails to start. Send a screenshot to the developer. |

To uninstall, delete the launcher folder and `%APPDATA%\Godot\app_userdata\Heartwake`.

## For the developer: publishing an update

From Git Bash at the repo root, with everything committed and pushed:

```bash
tools/release.sh v0.1.0 "What changed"
```

The script exports `build/windows/Heartwake.exe` with the `Windows Desktop` preset, zips it as
`Heartwake-windows.zip`, and publishes a GitHub release with that zip and `Heartwake-Launcher.zip`.
Launchers install whichever release is marked latest, so the next time a friend starts the
launcher they get the new version. Use a new tag for every release: the launcher compares tags,
not numbers.
