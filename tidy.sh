#!/bin/bash

# Ambil address kedua game otomatis
GAME_ADDRESSES=$(hyprctl clients -j | python3 -c "
import json,sys
clients = json.load(sys.stdin)
for c in clients:
    if 'steam_app_636040' in c['class']:
        print(c['address'])
")

# Ambil address semua Steam client otomatis
STEAM_ADDRESSES=$(hyprctl clients -j | python3 -c "
import json,sys
clients = json.load(sys.stdin)
for c in clients:
    if c['class'] == 'steam':
        print(c['address'])
")

# Ambil address semua kitty
KITTY_ADDRESSES=$(hyprctl clients -j | python3 -c "
import json,sys
clients = json.load(sys.stdin)
for c in clients:
    if c['class'] == 'kitty':
        print(c['address'])
")

# Pindah semua game ke workspace 3
for addr in $GAME_ADDRESSES; do
    hyprctl dispatch movetoworkspacesilent 3,address:$addr
done

# Pindah semua Steam ke workspace 9
for addr in $STEAM_ADDRESSES; do
    hyprctl dispatch movetoworkspacesilent 9,address:$addr
done

# Pindah semua kitty ke workspace 9
for addr in $KITTY_ADDRESSES; do
    hyprctl dispatch movetoworkspacesilent 9,address:$addr
done

# Fokus ke workspace 3
hyprctl dispatch workspace 3
