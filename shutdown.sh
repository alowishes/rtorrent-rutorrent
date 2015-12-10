#!/bin/bash
pkill -u rtorrent rtorrent
while pgrep -u rtorrent rtorrent > /dev/null; do sleep 1; done
echo "You can stop the container now."
