#!/bin/bash

export DISPLAY=:1

# Ask user to click target window
echo "🎯 Click on the terminal window you want to record..."
info=$(xwininfo -int)

X=$(echo "$info" | grep "Absolute upper-left X" | awk '{print $NF}')
Y=$(echo "$info" | grep "Absolute upper-left Y" | awk '{print $NF}')

WIDTH=$(echo "$info" | grep "Width:" | awk '{print $2}')
HEIGHT=$(echo "$info" | grep "Height:" | awk '{print $2}')

WIDTH=$(( WIDTH / 2 * 2 ))
HEIGHT=$(( HEIGHT / 2 * 2 ))

filename="recording_$(date +%Y%m%d_%H%M%S).mp4"

echo "📽️  Recording ${WIDTH}x${HEIGHT} at +${X},${Y} to $filename"
echo "⌨️  Use the other terminal to run commands. Press [q] here to stop recording."

ffmpeg -video_size ${WIDTH}x${HEIGHT} -framerate 30 \
-f x11grab \
-i ${DISPLAY}.0+${X},${Y} \
-c:v libx264 \
-preset veryfast \
-profile:v baseline \
-level 3.0 \
-pix_fmt yuv420p "$filename"

