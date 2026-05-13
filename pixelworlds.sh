#!/bin/bash

# Launch Steam utama
steam &
sleep 8

# Launch Steam firejail
firejail --private=$HOME/steam-account2 steam &
