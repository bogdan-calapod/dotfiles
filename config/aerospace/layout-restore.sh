#!/bin/bash
# Restore WS 3 layout: [Slack] | [Discord + ChatGPT (accordion)]

aerospace workspace 3
sleep 0.3

slack=$(aerospace list-windows --workspace 3 --format '%{window-id} %{app-bundle-id}' 2>/dev/null | grep 'slackmacgap' | awk '{print $1}')
discord=$(aerospace list-windows --workspace 3 --format '%{window-id} %{app-bundle-id}' 2>/dev/null | grep 'Discord' | awk '{print $1}')
chatgpt=$(aerospace list-windows --workspace 3 --format '%{window-id} %{app-bundle-id}' 2>/dev/null | grep 'openai' | awk '{print $1}')

[ -z "$slack" ] || [ -z "$discord" ] || [ -z "$chatgpt" ] && exit 0

# Reset to flat tiles
aerospace flatten-workspace-tree
sleep 0.3

# Push Slack to the leftmost position
aerospace focus --window-id "$slack"
for i in {1..5}; do aerospace move left 2>/dev/null; done
sleep 0.3

# Push ChatGPT to the rightmost position
aerospace focus --window-id "$chatgpt"
for i in {1..5}; do aerospace move right 2>/dev/null; done
sleep 0.3

# Now layout is: [Slack | Discord | ChatGPT]
# Join ChatGPT with Discord (left neighbor) into a container
aerospace focus --window-id "$chatgpt"
aerospace join-with left
sleep 0.2

# Set the Discord+ChatGPT container to accordion
aerospace layout accordion
