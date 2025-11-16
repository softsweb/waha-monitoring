#!/bin/bash

CONTAINER="test-crash"
LOGFILE="YOUR_HOME/container_monitor.log"

# WAHA API CONFIG
WAHA_URL="http://localhost:3000/api/sendText"
API_KEY="YOUR_API_KEY"
CHAT_ID="YOUR_PHONE_NUMBER@c.us"
SESSION="default"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

STATUS=$(docker inspect -f '{{.State.Status}}' $CONTAINER 2>/dev/null)

if [ "$STATUS" != "running" ]; then
    MESSAGE="ALERT: Docker container '$CONTAINER' is DOWN! Status: $STATUS"
    log "$MESSAGE"

    curl -s -X POST "$WAHA_URL" \
      -H "Content-Type: application/json" \
      -H "X-Api-Key: $API_KEY" \
      -d "{
           \"chatId\": \"$CHAT_ID\",
           \"text\": \"$MESSAGE\",
           \"session\": \"$SESSION\"
          }" >/dev/null

else
    log "OK: $CONTAINER is running."
fi
