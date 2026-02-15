#!/bin/bash
set -euo pipefail

# KeePassXC fuzzy search wrapper
# Requires: keepassxc-cli, fzf, tmux

: "${KP_DB:?KP_DB environment variable must be set to your .kdbx file path}"
KP_KEYFILE="${KP_KEYFILE:-}"
KP_TIMEOUT="${KP_TIMEOUT:-300}"

# --lock: clear cached password and exit
if [[ "${1:-}" == "--lock" ]]; then
    tmux set-environment -u KPDB_PASS 2>/dev/null || true
    tmux set-environment -u KPDB_PASS_TIME 2>/dev/null || true
    echo "Cleared cached password."
    exit 0
fi

# --- Password caching via tmux environment ---
get_cached_pass() {
    local cached_pass cached_time now
    cached_pass="$(tmux show-environment KPDB_PASS 2>/dev/null | sed 's/^KPDB_PASS=//')" || return 1
    cached_time="$(tmux show-environment KPDB_PASS_TIME 2>/dev/null | sed 's/^KPDB_PASS_TIME=//')" || return 1
    now="$(date +%s)"
    if (( now - cached_time < KP_TIMEOUT )); then
        printf '%s' "$cached_pass"
        return 0
    fi
    return 1
}

prompt_pass() {
    local pass
    read -rsp "KeePassXC password: " pass
    echo >&2
    printf '%s' "$pass"
}

build_cli_args() {
    local args=()
    if [[ -n "$KP_KEYFILE" ]]; then
        args+=(--key-file "$KP_KEYFILE")
    fi
    printf '%s\n' "${args[@]}"
}

validate_pass() {
    local pass="$1"
    local cli_args=()
    while IFS= read -r arg; do
        [[ -n "$arg" ]] && cli_args+=("$arg")
    done < <(build_cli_args)
    if ! printf '%s' "$pass" | keepassxc-cli ls "${cli_args[@]}" "$KP_DB" >/dev/null 2>&1; then
        return 1
    fi
    return 0
}

# Get or prompt for password
if ! PASS="$(get_cached_pass)"; then
    PASS="$(prompt_pass)"
    if ! validate_pass "$PASS"; then
        echo "Invalid password." >&2
        exit 1
    fi
    tmux set-environment KPDB_PASS "$PASS"
    tmux set-environment KPDB_PASS_TIME "$(date +%s)"
fi

# --- Build keepassxc-cli extra args ---
CLI_ARGS=()
while IFS= read -r arg; do
    [[ -n "$arg" ]] && CLI_ARGS+=("$arg")
done < <(build_cli_args)

# --- List entries and fuzzy select ---
ENTRIES="$(printf '%s' "$PASS" | keepassxc-cli ls -R -f "${CLI_ARGS[@]}" "$KP_DB" 2>/dev/null)"

FZF_ARGS=(--select-1 --exit-0)
if [[ -n "${1:-}" ]]; then
    FZF_ARGS+=(--query "$1")
fi

SELECTED="$(echo "$ENTRIES" | fzf "${FZF_ARGS[@]}")" || { echo "No entry selected." >&2; exit 1; }

# --- Show entry details ---
SHOW_OUTPUT="$(printf '%s' "$PASS" | keepassxc-cli show -s "${CLI_ARGS[@]}" "$KP_DB" "$SELECTED" 2>/dev/null)"

PASSWORD="$(echo "$SHOW_OUTPUT" | grep -m1 '^Password:' | sed 's/^Password: //')"
USERNAME="$(echo "$SHOW_OUTPUT" | grep -m1 '^UserName:' | sed 's/^UserName: //')"
URL="$(echo "$SHOW_OUTPUT" | grep -m1 '^URL:' | sed 's/^URL: //')"

# --- Copy password via OSC 52 ---
if [[ -n "$PASSWORD" ]]; then
    ENCODED="$(printf '%s' "$PASSWORD" | base64)"
    # Use tmux passthrough if inside tmux
    if [[ -n "${TMUX:-}" ]]; then
        printf '\ePtmux;\e\e]52;c;%s\a\e\\' "$ENCODED"
    else
        printf '\e]52;c;%s\a' "$ENCODED"
    fi
    echo "Password copied to clipboard via OSC 52."
else
    echo "No password found for entry." >&2
fi

# --- Print reference info ---
[[ -n "$USERNAME" ]] && echo "Username: $USERNAME"
[[ -n "$URL" ]] && echo "URL: $URL"
