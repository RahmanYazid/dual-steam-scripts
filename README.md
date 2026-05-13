# Dual Steam — Pixel Worlds Split Screen on Hyprland

Run two Steam accounts side by side on a single monitor using Firejail, Gamescope, and Hyprland window rules.

---

## Requirements

- Arch Linux (or any Arch-based distro)
- Hyprland (Wayland compositor)
- Steam
- Firejail
- Gamescope

### Install dependencies

```bash
sudo pacman -S steam firejail gamescope
```

---

## Setup

### 1. Create a separate home directory for the second account

```bash
mkdir -p ~/steam-account2
```

This directory acts as an isolated home for the Firejail Steam instance so both accounts run independently without detecting each other.

### 2. Pre-create Steam path files inside the Firejail home

Without these files, Firejail blocks Steam from writing to the home directory, which causes Gamescope to fail applying the correct resolution.

```bash
touch ~/steam-account2/.steampath
touch ~/steam-account2/.steampid
```

### 3. Clone this repo

```bash
git clone git@github.com:YOUR_USERNAME/dual-steam-scripts.git
cd dual-steam-scripts
chmod +x pixelworlds.sh tidy.sh game.sh
```

### 4. Add Hyprland window rules

Add the following to `~/.config/hypr/hyprland.conf` to allow moving and resizing windows with the mouse:

```ini
# Allow moving and resizing floating windows
bindm = SUPER, mouse:272, movewindow
bindm = SUPER, mouse:273, resizewindow
```

Reload Hyprland:

```bash
hyprctl reload
```

---

## Usage

### Step 1 — Launch both Steam clients

```bash
~/dual-steam-scripts/pixelworlds.sh
```

This opens the main account Steam normally, waits 8 seconds, then opens the second account Steam via Firejail. Log in to both accounts before continuing.

### Step 2 — Launch both games with Gamescope

```bash
~/dual-steam-scripts/game.sh
```

This launches Pixel Worlds for both accounts using Gamescope at 960x600 resolution. There is a 35-second delay between launches to ensure the first instance is fully ready before the second starts.

### Step 3 — Arrange workspace

Once both games are open and running:

```bash
~/dual-steam-scripts/tidy.sh
```

This automatically:
- Moves both game windows to workspace 3
- Moves all Steam clients and terminals to workspace 9
- Focuses workspace 3 so you see both games side by side

To get back to your terminals: press `SUPER + 9`

---

## Troubleshooting

### Only one Steam opens

Steam detects an existing instance and refuses to launch a second one. Make sure you are using Firejail with `--private` pointing to a separate home directory:

```bash
firejail --private=$HOME/steam-account2 steam
```

Never launch both instances without isolation — Steam will silently ignore the second launch.

### Game resolution stuck at 1368x768 inside Firejail

Firejail blocks Steam from writing `.steampath` and `.steampid` to the home directory, which breaks Gamescope's ability to apply the correct resolution.

Fix:

```bash
touch ~/steam-account2/.steampath
touch ~/steam-account2/.steampid
```

Then always launch the game using Gamescope **outside** of Firejail, with Firejail wrapping only Steam:

```bash
gamescope -w 960 -h 600 -W 960 -H 600 -e -- firejail --private=$HOME/steam-account2 steam -applaunch 636040
```

Do **not** put Gamescope inside the Firejail sandbox — it cannot access the display correctly from inside.

### Game windows float on top of each other

Hyprland treats some Steam game windows as dialogs and floats them by default. Force tile them manually:

```bash
# Get addresses of floating game windows
hyprctl clients -j | python3 -c "
import json,sys
clients = json.load(sys.stdin)
for c in clients:
    if c['floating'] and 'steam_app' in c['class']:
        print(c['address'])
"

# Tile each one
hyprctl dispatch settiled address:0xADDRESS
```

Or just run `tidy.sh` which handles this automatically.

### Main Steam window floating and can't be moved

Steam sometimes spawns its main window as a floating dialog. Force tile it:

```bash
hyprctl dispatch settiled address:0xADDRESS
```

Or focus the window and press `SUPER + V` to toggle floating.

### `tidy.sh` only moves one game window

Both game windows share the same class (`steam_app_636040`), so `movetoworkspace class:` only moves one. The `tidy.sh` script handles this by fetching all matching addresses dynamically and moving each one individually.

### Gamescope exits immediately

Do not pipe Gamescope output to `head` — it kills the process before the game launches. Always run Gamescope without piping when launching for real.

---

## Gamescope settings

| Flag | Value | Description |
|------|-------|-------------|
| `-w` | 960 | Game render width |
| `-h` | 600 | Game render height |
| `-W` | 960 | Output window width |
| `-H` | 600 | Output window height |
| `-e` | — | Nested/embedded mode (required for Wayland/Hyprland) |

To change resolution, edit the values in `game.sh`.

---

## File overview

| File | Description |
|------|-------------|
| `pixelworlds.sh` | Launches both Steam clients |
| `game.sh` | Launches both Pixel Worlds instances via Gamescope |
| `tidy.sh` | Moves games to workspace 3, everything else to workspace 9 |
