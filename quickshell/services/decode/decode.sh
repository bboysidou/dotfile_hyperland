#!/bin/sh
set -u

SYS="${QS_DECODE_SYSFS:-/sys}"
PROC="${QS_DECODE_PROCFS:-/proc}"
SAMPLE_SECONDS="${QS_DECODE_SAMPLE:-1}"
CPU_MIN_PERCENT=5
THREAD_PATTERN='^(av:[^:]+:(df|sw)[0-9]+|dav1d-worker|CodecWorker)$'
NVIDIA_VENDOR=0x10de

ticks_per_second() {
    getconf CLK_TCK 2>/dev/null || echo 100
}

now_ns() {
    date +%s%N
}

decoder_threads() {
    grep -sE "$THREAD_PATTERN" "$PROC"/[0-9]*/task/*/comm | while IFS=: read -r path name; do
        task=${path%/comm}
        rest=${path#"$PROC"/}
        stat=$(cat "$task/stat" 2>/dev/null) || continue
        case "$name" in
            dav1d-worker) codec=av1 ;;
            CodecWorker) codec=vpx ;;
            *) codec=${name#av:}; codec=${codec%%:*} ;;
        esac
        printf '%s %s %s %s %s\n' "$1" "${rest%%/*}" "${task##*/}" "$codec" "$(printf '%s' "${stat##*) }" | awk '{ print $12 + $13 }')"
    done
}

video_engines() {
    find "$PROC"/[0-9]*/fd -lname '/dev/dri/*' 2>/dev/null | sed 's|/fd/|/fdinfo/|' | xargs -r awk -v tag="$1" '
        function flush() {
            if (client != "" && pdev != "" && !seen[pid SUBSEP pdev SUBSEP client]++) {
                key = pid SUBSEP pdev
                work[key] += busy
                span[key] += total
                if (kind != "") kinds[key] = kind
            }
            client = ""
        }
        FNR == 1 { flush(); n = split(FILENAME, part, "/"); pid = part[n - 2]; client = pdev = kind = ""; busy = total = 0 }
        /^drm-client-id:/ { client = $2 }
        /^drm-pdev:/ { pdev = $2 }
        /^drm-engine-(dec|enc|jpeg|vcn|video)[^:]*:/ { busy += $2; kind = "ns" }
        /^drm-cycles-vcs:/ { busy += $2; kind = "cycles" }
        /^drm-total-cycles-vcs:/ { total += $2 }
        END {
            flush()
            for (key in work) {
                if (!(key in kinds)) continue
                split(key, field, SUBSEP)
                printf "%s %s %s %s %.0f %.0f\n", tag, field[1], field[2], kinds[key], work[key], span[key]
            }
        }' 2>/dev/null
}

nvidia_cards() {
    for dev in "$SYS"/bus/pci/devices/*; do
        [ "$(cat "$dev/vendor" 2>/dev/null)" = "$NVIDIA_VENDOR" ] || continue
        case "$(cat "$dev/class" 2>/dev/null)" in 0x03*) ;; *) continue ;; esac
        [ "$(cat "$dev/power/runtime_status" 2>/dev/null)" = suspended ] && continue
        echo "${dev##*/}"
    done
}

nvidia_decoders() {
    command -v nvidia-smi >/dev/null 2>&1 || return 0
    for pci in $(nvidia_cards); do
        nvidia-smi pmon -i "$pci" -c 1 -s u 2>/dev/null | awk -v pci="$pci" '
            /^# *gpu/ { for (i = 2; i <= NF; i++) column[$i] = i - 1; next }
            /^#/ || !("dec" in column) { next }
            $column["pid"] ~ /^[0-9]+$/ && $column["dec"] ~ /^[0-9]+$/ && $column["dec"] > 0 {
                printf "n %s %s %s\n", $column["pid"], pci, $column["dec"]
            }'
    done
}

summarise() {
    awk -v ticks="$(ticks_per_second)" -v cpuMin="$CPU_MIN_PERCENT" '
        $1 == "e" { elapsed = $2; next }
        $1 == "ta" { before[$3] = $5; next }
        $1 == "tb" {
            if (!($2 in codecs)) codecs[$2] = $4
            if (!($3 in before) || $5 < before[$3]) next
            spent = $5 - before[$3]
            cpu[$2] += spent
            if (spent > best[$2]) { best[$2] = spent; codecs[$2] = $4 }
            next
        }
        $1 == "va" { vwork[$2 SUBSEP $3] = $5; vspan[$2 SUBSEP $3] = $6; next }
        $1 == "vb" {
            key = $2 SUBSEP $3
            if (!(key in vwork)) next
            work = $5 - vwork[key]
            span = $4 == "cycles" ? $6 - vspan[key] : elapsed
            if (work > 0 && span > 0) gpu[key] = work / span * 100
            next
        }
        $1 == "n" { gpu[$2 SUBSEP $3] = $4; next }
        END {
            seconds = elapsed / 1000000000
            for (pid in cpu) {
                percent = seconds > 0 ? cpu[pid] / ticks / seconds * 100 : 0
                if (percent >= cpuMin) printf "cpu %s %s - %.0f\n", pid, codecs[pid], percent
            }
            for (key in gpu) {
                split(key, field, SUBSEP)
                load = gpu[key] > 100 ? 100 : gpu[key] < 1 ? 1 : gpu[key]
                printf "gpu %s %s %s %.0f\n", field[1], (field[1] in codecs ? codecs[field[1]] : "-"), field[2], load
            }
        }'
}

app_of() {
    exe=$(readlink "$PROC/$1/exe" 2>/dev/null)
    name=${exe##*/}
    [ -n "$name" ] || name=$(cat "$PROC/$1/comm" 2>/dev/null)
    printf '%s' "${name%-bin}"
}

scan() {
    start=$(now_ns)
    threads_a=$(decoder_threads ta)
    video_a=$(video_engines va)
    sleep "$SAMPLE_SECONDS"
    middle=$(now_ns)
    threads_b=$(decoder_threads tb)
    video_b=$(video_engines vb)
    printf '%s\n' "e $((middle - start))" "$threads_a" "$threads_b" "$video_a" "$video_b" "$(nvidia_decoders)" | grep -v '^$' | summarise |
        while read -r kind pid codec pci load; do
            printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$kind" "$pid" "$(app_of "$pid")" "$codec" "$pci" "$load"
        done
}

case "${1:-}" in
    scan) scan ;;
    *)
        echo "usage: decode.sh scan" >&2
        exit 2
        ;;
esac
