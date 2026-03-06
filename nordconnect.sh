#!/usr/bin/env bash
set -euo pipefail

SERVER="${1:-}"
PROTOCOL="${2:-udp}"

CONFIG_DIR="$HOME/ovpn/$PROTOCOL"
CONFIG_FILE="$CONFIG_DIR/${SERVER}.nordvpn.com.${PROTOCOL}.ovpn"
AUTH_FILE="/etc/openvpn/nordvpn-auth.txt"
LOG_FILE="/tmp/openvpn-${SERVER}-${PROTOCOL}.log"
PID_FILE="/tmp/openvpn-${SERVER}-${PROTOCOL}.pid"

usage() {
    echo "Usage: $0 <server_id> [udp|tcp]"
    echo "Example: $0 us1234 udp"
    exit 1
}

fail() {
    echo "❌ $1"
    if [[ -f "$LOG_FILE" ]]; then
        echo
        echo "Last log lines from $LOG_FILE:"
        sudo tail -n 30 "$LOG_FILE" || true
    fi
    exit 1
}

if [[ -z "$SERVER" ]]; then
    echo "❌ Missing server ID."
    usage
fi

if [[ "$PROTOCOL" != "udp" && "$PROTOCOL" != "tcp" ]]; then
    echo "❌ Invalid protocol: $PROTOCOL (must be 'udp' or 'tcp')"
    usage
fi

command -v openvpn >/dev/null 2>&1 || fail "'openvpn' binary not found in PATH. Install it with: sudo apt install openvpn"

[[ -d "$CONFIG_DIR" ]] || fail "Config directory not found: $CONFIG_DIR"
[[ -f "$CONFIG_FILE" ]] || fail "Config file not found: $CONFIG_FILE"
[[ -f "$AUTH_FILE" ]] || fail "Auth file not found: $AUTH_FILE"
[[ -r "$AUTH_FILE" ]] || fail "Auth file exists but is not readable: $AUTH_FILE"

# Good hygiene; not fatal if it fails
sudo chmod 600 "$AUTH_FILE" 2>/dev/null || true
sudo chown root:root "$AUTH_FILE" 2>/dev/null || true

# Clean up old process for this specific pidfile, if any
if [[ -f "$PID_FILE" ]]; then
    oldpid="$(cat "$PID_FILE" 2>/dev/null || true)"
    if [[ -n "${oldpid:-}" ]] && sudo kill -0 "$oldpid" 2>/dev/null; then
        echo "⚠️  Stopping existing OpenVPN process (PID $oldpid)..."
        sudo kill "$oldpid" || true
        sleep 1
    fi
fi

sudo rm -f "$LOG_FILE" "$PID_FILE"

echo "🌍 Connecting to NordVPN server $SERVER via $PROTOCOL..."

sudo openvpn \
  --config "$CONFIG_FILE" \
  --auth-user-pass "$AUTH_FILE" \
  --writepid "$PID_FILE" \
  --log "$LOG_FILE" \
  --daemon

# Wait up to 25 seconds for a real outcome
timeout_secs=25
for ((i=1; i<=timeout_secs; i++)); do
    sleep 1

    # Did OpenVPN give us a pid?
    if [[ ! -f "$PID_FILE" ]]; then
        continue
    fi

    pid="$(cat "$PID_FILE" 2>/dev/null || true)"
    if [[ -z "$pid" ]]; then
        continue
    fi

    # Process died
    if ! sudo kill -0 "$pid" 2>/dev/null; then
        fail "OpenVPN exited during startup."
    fi

    # Real success signal
    if sudo grep -q "Initialization Sequence Completed" "$LOG_FILE" 2>/dev/null; then
        echo "✅ OpenVPN connected successfully."
        if ip addr show tun0 >/dev/null 2>&1; then
            echo "✅ tun0 is present."
        else
            echo "⚠️  Connected according to OpenVPN log, but tun0 was not found."
        fi
        echo "   Check external IP with: curl ifconfig.me"
        exit 0
    fi

    # Fatal-ish patterns worth surfacing early
    if sudo grep -Eqi "AUTH_FAILED|Exiting due to fatal error|Cannot open TUN/TAP dev|Options error|TLS Error|Connection reset|SIGUSR1\[soft," "$LOG_FILE" 2>/dev/null; then
        fail "OpenVPN reported an error during startup."
    fi
done

echo "⚠️  OpenVPN is still running, but connection is not established yet."
echo "   This often means the network is blocking or dropping $PROTOCOL VPN traffic."
echo "   Last log lines from $LOG_FILE:"
sudo tail -n 30 "$LOG_FILE" 2>/dev/null || echo "   (no log file)"
exit 1