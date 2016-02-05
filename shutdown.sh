#!/bin/bash
pkill -INT -u rtorrent rtorrent
while pgrep -u rtorrent rtorrent > /dev/null; do sleep 3; done
echo "You can stop the container now."
