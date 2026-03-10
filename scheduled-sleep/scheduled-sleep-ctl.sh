#!/bin/bash
set -euo pipefail

LABEL="com.local.scheduled-sleep"
PLIST_NAME="${LABEL}.plist"
PLIST_SRC="$(cd "$(dirname "$0")" && pwd)/${PLIST_NAME}"
PLIST_DST="/Library/LaunchDaemons/${PLIST_NAME}"

usage() {
    echo "Usage: $0 {start|stop|status}"
    exit 1
}

require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Error: this command requires root. Run with sudo."
        exit 1
    fi
}

do_start() {
    require_root

    if [[ ! -f "$PLIST_SRC" ]]; then
        echo "Error: plist not found at $PLIST_SRC"
        exit 1
    fi

    # Copy plist to LaunchDaemons
    cp "$PLIST_SRC" "$PLIST_DST"
    chown root:wheel "$PLIST_DST"
    chmod 644 "$PLIST_DST"

    # Load the daemon
    launchctl load "$PLIST_DST" 2>/dev/null || true
    # Also bootstrap for modern launchctl
    launchctl bootstrap system "$PLIST_DST" 2>/dev/null || true

    echo "✅ Scheduled sleep daemon loaded."
    echo "   Mac will sleep at 01:00 every night."
    echo ""
    echo "⚠️  Don't forget to set the wake schedule:"
    echo "   sudo pmset repeat wake MTWRFSU 05:30:00"
}

do_stop() {
    require_root

    # Unload the daemon
    launchctl bootout system/"$LABEL" 2>/dev/null || true
    launchctl unload "$PLIST_DST" 2>/dev/null || true

    # Remove plist
    if [[ -f "$PLIST_DST" ]]; then
        rm "$PLIST_DST"
    fi

    echo "✅ Scheduled sleep daemon removed."
}

do_status() {
    echo "=== Scheduled Sleep Status ==="
    echo ""

    # Check if plist is installed
    if [[ -f "$PLIST_DST" ]]; then
        echo "Plist:   installed at $PLIST_DST"
    else
        echo "Plist:   not installed"
    fi

    # Check if daemon is loaded
    if sudo launchctl list "$LABEL" &>/dev/null; then
        echo "Daemon:  loaded ✅"
        # Show last exit status
        local exit_status
        exit_status=$(sudo launchctl list "$LABEL" 2>/dev/null | grep '"LastExitStatus"' | grep -o '[0-9]*' || echo "N/A")
        echo "Last exit status: $exit_status"
    else
        echo "Daemon:  not loaded ❌"
    fi

    echo ""

    # Show pmset wake schedule
    echo "=== Wake Schedule (pmset) ==="
    pmset -g sched 2>/dev/null || echo "(no schedule set)"
}

case "${1:-}" in
    start)  do_start ;;
    stop)   do_stop ;;
    status) do_status ;;
    *)      usage ;;
esac
