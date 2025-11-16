# WAHA WhatsApp Monitoring Example

This repository shows how to:

- Install and run the WAHA WhatsApp HTTP API  
- Connect your WhatsApp number  
- Create a test Docker container  
- Monitor that container every minute with a cronjob  
- Send WhatsApp alerts when the container stops  
- Log all monitoring events  

Perfect for learning WAHA or building your own automation system.

---

## 1. Install WAHA

Clone the folder on your server and run:

```bash
docker pull devlikeapro/waha
```

## 2. Initialize WAHA Credentials
Inside your working directory (ex: `~/waha`):

```bash
docker run --rm -v "$(pwd)":/app/env devlikeapro/waha init-waha /app/env
```

This generates a `.env` file containing:

- WAHA_API_KEY  
- Dashboard credentials  
- Swagger credentials  

---

## 3. Create Sessions Folder

```bash
mkdir sessions
```

---

## 4. Run WAHA

```bash
docker run -d \
  --env-file "$(pwd)/.env" \
  -v "$(pwd)/sessions:/app/.sessions" \
  -p 3000:3000 \
  --name waha \
  devlikeapro/waha
```

---

## 5. Connect to Dashboard
Open in your browser:

```
http://YOUR_SERVER_IP:3000/dashboard
```

1. Login using username/password from `.env`  
2. Enter your API Key  
3. Start the **default** session  
4. Click the camera icon  
5. Scan the QR code with WhatsApp  

Once the session shows **WORKING**, you're connected.

---

## 6. Test Send Message in Swagger

Go to:

```
http://YOUR_SERVER_IP:3000
```

Click **Authorize** → paste your API key → **Close**

Use the endpoint:

```
POST /api/sendText
```

Example body:

```json
{
  "chatId": "YOUR_PHONE_NUMBER@c.us",
  "text": "Testing WAHA!",
  "session": "default"
}
```

---

## 7. Create Test Container to Monitor

```bash
docker run -d --name test-crash busybox tail -f /dev/null
```

This container runs forever until you manually stop/kill it.

---

## 8. Monitoring Script

Create `check_container.sh`:

```bash
#!/bin/bash

CONTAINER="test-crash"
LOGFILE="/home/daniel/container_monitor.log"

# WAHA API CONFIG
WAHA_URL="http://localhost:3000/api/sendText"
API_KEY="16eda988cc034017b7fe85b5c7fa7c85"
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
```

Make it executable:

```bash
chmod +x check_container.sh
```

---

## 9. Add Cronjob (Runs Every Minute)

Open cron:

```bash
crontab -e
```

Add this line:

```
* * * * * /home/daniel/check_container.sh
```

Save and exit.

Cron now checks the container every minute.

---

## 10. Test the Alert

Manually kill the container:

```bash
docker kill test-crash
```

Within one minute, you will receive a WhatsApp message:

```
ALERT: Docker container 'test-crash' is DOWN! Status: exited
```

Logs will appear here:

```
/home/daniel/container_monitor.log
```

---

## Summary

This setup demonstrates:

- Full WAHA setup  
- WhatsApp API messaging  
- Automated container monitoring  
- Cron-based notifications  
- Logging for debugging and audit  

Can be expanded into:

- Monitoring all containers  
- Monitoring databases  
- Telegram + Discord + WhatsApp unified alerts  
- APISIX integrations  
- And much more.

