#!/usr/bin/env bash
# Claude Code status line — styled after the oh-my-zsh "crunch" theme.
# Receives JSON on stdin from Claude Code.
#
# Dependencies: jq (https://jqlang.org) — for JSON parsing

input=$(cat)

# --- data extraction ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_day_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
git_branch=$(git -C "$cwd" --git-dir="$cwd/.git" symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

# --- ANSI colours (crunch palette) ---
WHITE='\033[0;37m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# --- time block: {HH:MM} ---
time_block="${WHITE}{${YELLOW}$(date +%H:%M)${WHITE}}${RESET}"

# --- directory (tilde-contracted) ---
home_dir="$HOME"
short_dir="${cwd/#$home_dir/\~}"
dir_block="${CYAN}${short_dir}${RESET}"

# --- git branch ---
if [ -n "$git_branch" ]; then
    git_block="${WHITE}:${GREEN}${git_branch}${RESET}"
else
    git_block=""
fi

# --- model block ---
if [ -n "$model" ]; then
    model_block="${WHITE}[${MAGENTA}${model}${WHITE}]${RESET}"
else
    model_block=""
fi

# --- context usage ---
if [ -n "$used" ]; then
    ctx_pct=$(printf '%.0f' "$used")
    ctx_block="${WHITE}ctx:${YELLOW}${ctx_pct}%${RESET}"
else
    ctx_block=""
fi

# --- helper: format seconds as compact "Xh Ym" or "Ym" ---
fmt_remaining() {
    local reset_epoch="$1"
    [ -z "$reset_epoch" ] && return
    local now secs_left
    now=$(date +%s)
    secs_left=$(( reset_epoch - now ))
    [ "$secs_left" -le 0 ] && return
    local hours=$(( secs_left / 3600 ))
    local mins=$(( (secs_left % 3600) / 60 ))
    if [ "$hours" -gt 0 ]; then
        printf '%dh%dm' "$hours" "$mins"
    else
        printf '%dm' "$mins"
    fi
}

# --- session rate limits ---
limits_block=""
if [ -n "$five_hour" ]; then
    five_pct=$(printf '%.0f' "$five_hour")
    five_remaining=$(fmt_remaining "$five_hour_reset")
    if [ -n "$five_remaining" ]; then
        limits_block="${WHITE}5h:${YELLOW}${five_pct}%(${five_remaining})${RESET}"
    else
        limits_block="${WHITE}5h:${YELLOW}${five_pct}%${RESET}"
    fi
fi
if [ -n "$seven_day" ]; then
    week_pct=$(printf '%.0f' "$seven_day")
    week_remaining=$(fmt_remaining "$seven_day_reset")
    if [ -n "$week_remaining" ]; then
        week_str="${WHITE}7d:${YELLOW}${week_pct}%(${week_remaining})${RESET}"
    else
        week_str="${WHITE}7d:${YELLOW}${week_pct}%${RESET}"
    fi
    if [ -n "$limits_block" ]; then
        limits_block="${limits_block} ${week_str}"
    else
        limits_block="${week_str}"
    fi
fi

# --- assemble ---
line="${time_block} ${dir_block}${git_block} ${model_block}"
[ -n "$ctx_block" ]    && line="${line} ${ctx_block}"
[ -n "$limits_block" ] && line="${line} ${limits_block}"
printf '%b' "$line"
