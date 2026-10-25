#!/usr/bin/env bash
set -u

direction="${1:-}"
duration="${2:-8}"
probe=1.1.1.1
parallel=8
url_count=3
upload_chunk_bytes=$((32 * 1024 * 1024))
fast_token="YXNkZmFzZGxmbnNkYWZoYXNkZmhrYWxm"
fast_api="https://api.fast.com/netflix/speedtest/v2?https=true&token=${fast_token}&urlCount=${url_count}"

case "$direction" in
    down) counter=rx_bytes ;;
    up) counter=tx_bytes ;;
    *)
        echo "usage: net_speedtest.sh down|up [seconds]" >&2
        exit 2
        ;;
esac

if [[ ! $duration =~ ^[1-9][0-9]*$ ]]; then
    echo "Invalid duration: $duration" >&2
    exit 2
fi

iface=$(ip route get "$probe" 2>/dev/null | awk '{ for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit } }')
stats="/sys/class/net/${iface}/statistics/${counter}"

if [[ -z $iface || ! -r $stats ]]; then
    echo "No active network interface" >&2
    exit 1
fi

mapfile -t urls < <(curl -fsS --max-time 10 "$fast_api" 2>/dev/null | jq -r '.targets[]?.url // empty' 2>/dev/null)

if (( ${#urls[@]} == 0 )); then
    echo "Could not reach fast.com" >&2
    exit 1
fi

workers=()

cleanup() {
    local pid
    for pid in "${workers[@]}"; do
        pkill -TERM -P "$pid" 2>/dev/null
        kill "$pid" 2>/dev/null
    done
    wait 2>/dev/null
}

trap cleanup EXIT
trap 'exit 143' TERM INT HUP

worker() {
    local idx=$RANDOM url
    while true; do
        url=${urls[idx % ${#urls[@]}]}
        if [[ $direction == down ]]; then
            curl -fsS -o /dev/null "$url" 2>/dev/null || return
        else
            head -c "$upload_chunk_bytes" /dev/zero | curl -fsS -o /dev/null -X POST --data-binary @- "$url" 2>/dev/null || return
        fi
        idx=$((idx + 1))
    done
}

alive() {
    local pid
    for pid in "${workers[@]}"; do
        kill -0 "$pid" 2>/dev/null && return 0
    done
    return 1
}

for (( i = 0; i < parallel; i++ )); do
    worker &
    workers+=("$!")
done

before=$(<"$stats")
started=$EPOCHREALTIME

for (( second = 0; second < duration; second++ )); do
    sleep 1
    if ! alive; then
        echo "Lost connection to the test server" >&2
        exit 1
    fi
    after=$(<"$stats")
    now=$EPOCHREALTIME
    awk -v before="$before" -v after="$after" -v from="$started" -v to="$now" 'BEGIN {
        elapsed = to - from
        bits = after > before ? (after - before) * 8 : 0
        printf "%.2f\n", (elapsed > 0 ? bits / elapsed / 1000000 : 0)
    }'
    before=$after
    started=$now
done
