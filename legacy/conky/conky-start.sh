#!/bin/bash

feh --bg-scale "`grep 'wallpaper=' ~/.kde/share/config/plasma-desktop-appletsrc | tail --bytes=+11`"

conky &
