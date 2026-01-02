#!/usr/bin/env bash
# Simple NordVPN OpenVPN connector (safer version)
# Usage: nordconnect us1234 [udp|tcp]

set -u  # treat unset vars as error

SERVER="${1:-}"
PROTOCOL="${2:-udp}"   # default: udp

CONFIG_DIR="$HOME/ovpn/$PROTOCOL"
CONFIG_FILE="$CONFIG_DIR/${SERVER}.nordvpn.com.${PROTOCOL}.ovpn"
AUTH_FILE="/etc/openvpn/nordvpn-auth.txt"
LOG_FILE="/tmp/openvpn.log"

# ---------- helper: usage ----------
usage() {
    echo "Usage: $0 <server_id> [udp|tcp]"
    echo "Example: $0 us1234 udp"
    exit 1
}

# ---------- 1. validate args ----------
if [[ -z "$SERVER" ]]; then
    echo "❌ Missing server ID."
    usage
fi

if [[ "$PROTOCOL" != "udp" && "$PROTOCOL" != "tcp" ]]; then
    echo "❌ Invalid protocol: $PROTOCOL (must be 'udp' or 'tcp')"
    usage
fi

# ---------- 2. check dependencies ----------
if ! command -v openvpn >/dev/null 2>&1; then
    echo "❌ 'openvpn' binary not found in PATH."
    echo "   Install it, e.g.: sudo apt install openvpn"
    exit 1
fi

# ---------- 3. check files & paths ----------
if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "❌ Config directory not found: $CONFIG_DIR"
    exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    exit 1
fi

if [[ ! -f "$AUTH_FILE" ]]; then
    echo "❌ Auth file not found: $AUTH_FILE"
    echo "   Expected format:"
    echo "      username"
    echo "      password"
    exit 1
fi

if [[ ! -r "$AUTH_FILE" ]]; then
    echo "❌ Auth file exists but is not readable: $AUTH_FILE"
    echo "   Try: sudo chmod 600 $AUTH_FILE"
    exit 1
fi

# ---------- 4. ensure auth-user-pass line is correct ----------
# normalize any existing auth-user-pass line (even with spaces) or append if missing
if grep -Eq '^[[:space:]]*auth-user-pass\b' "$CONFIG_FILE"; then
    # Replace existing auth-user-pass line
    sudo sed -i "s|^[[:space:]]*auth-user-pass.*|auth-user-pass $AUTH_FILE|" "$CONFIG_FILE"
else
    # Append if not present
    echo "auth-user-pass $AUTH_FILE" | sudo tee -a "$CONFIG_FILE" >/dev/null
fi

# ---------- 5. kill any previous OpenVPN using this config ----------
# (optional but nice)
if pgrep -f "openvpn --config $CONFIG_FILE" >/dev/null 2>&1; then
    echo "⚠️  Existing OpenVPN process using this config found. Stopping it..."
    sudo pkill -f "openvpn --config $CONFIG_FILE" || true
    sleep 1
fi

# ---------- 6. start OpenVPN ----------
echo "🌍 Connecting to NordVPN server $SERVER via $PROTOCOL..."
sudo openvpn --config "$CONFIG_FILE" --daemon --log "$LOG_FILE"

# Give it a moment to start
sleep 3

# ---------- 7. verify it actually started ----------
if ! pgrep -f "openvpn --config $CONFIG_FILE" >/dev/null 2>&1; then
    echo "❌ OpenVPN failed to start."
    echo "Last log lines from $LOG_FILE:"
    sudo tail -n 20 "$LOG_FILE" 2>/dev/null || echo "   (no log file)"
    exit 1
fi

# ---------- 8. check for tun0 ----------
if ip addr show tun0 >/dev/null 2>&1; then
    echo "✅ OpenVPN appears connected (tun0 is up)."
    echo "   Check external IP with: curl ifconfig.me"
else
    echo "⚠️ OpenVPN process is running, but tun0 is not present."
    echo "   There may be an error; last log lines from $LOG_FILE:"
    sudo tail -n 20 "$LOG_FILE" 2>/dev/null || echo "   (no log file)"
    exit 1
fi

