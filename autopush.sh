#!/bin/bash
# Auto-push daemon for weave_apps
# Watches for changes and pushes every 10 seconds

REPO_DIR="/tmp/weave_apps"
INTERVAL=10
PID_FILE="/tmp/weave_apps_autopush.pid"

start() {
    if [ -f "$PID_FILE" ]; then
        if kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            echo "Autopush already running (PID: $(cat $PID_FILE))"
            exit 1
        fi
    fi

    echo "Starting autopush daemon..."

    (
        while true; do
            cd "$REPO_DIR"

            # Check if there are changes
            if ! git diff --quiet || ! git diff --staged --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
                echo "[$(date '+%H:%M:%S')] Changes detected, pushing..."

                git add -A
                git commit -m "Auto-update $(date '+%Y-%m-%d %H:%M:%S')

Build By WEAVE" 2>/dev/null

                git push 2>/dev/null && echo "[$(date '+%H:%M:%S')] ✅ Pushed!" || echo "[$(date '+%H:%M:%S')] ❌ Push failed"
            fi

            sleep $INTERVAL
        done
    ) &

    echo $! > "$PID_FILE"
    echo "Autopush started (PID: $!)"
}

stop() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            rm "$PID_FILE"
            echo "Autopush stopped"
        else
            rm "$PID_FILE"
            echo "Autopush was not running"
        fi
    else
        echo "Autopush is not running"
    fi
}

status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            echo "Autopush is running (PID: $PID)"
        else
            rm "$PID_FILE"
            echo "Autopush is not running (stale PID file removed)"
        fi
    else
        echo "Autopush is not running"
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        sleep 1
        start
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
