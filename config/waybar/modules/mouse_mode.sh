#!/bin/bash

STATUS_FILE="/tmp/mouse_mode_status"

if [ -f "$STATUS_FILE" ]; then
  STATUS=$(cat "$STATUS_FILE")
else
  STATUS="off"
fi

if [ "$STATUS" == "on" ]; then
  echo '{"text": "🖱️", "tooltip": "マウスモードON"}'
else
  echo '{"text": "⌨️", "tooltip": "マウスモードOFF"}'
fi
