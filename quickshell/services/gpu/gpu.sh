#!/bin/sh
set -u

SYS="${QS_GPU_SYSFS:-/sys}"
PROC="${QS_GPU_PROCFS:-/proc}"
HWINFO="${QS_GPU_HWINFO:-/run/qs-hw}"
PCI_IDS=/usr/share/hwdata/pci.ids
MIB=1048576
MICRO=1000000
MILLI=1000
NVIDIA_QUERY=utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw,power.limit,fan.speed,clocks.gr

value() {
    cat "$1" 2>/dev/null || echo -
}

first_value() {
    dir=$1
    shift
    [ -n "$dir" ] || { echo -; return; }
    for file; do
        [ -r "$dir/$file" ] && { cat "$dir/$file"; return; }
    done
    echo -
}

intel_integrated() {
    case "$1" in *:00:02.0) return 0 ;; esac
    return 1
}

discrete_of() {
    case "$1" in
        nvidia | nouveau | "") echo 1 ;;
        i915 | xe) if intel_integrated "$2"; then echo 0; else echo 1; fi ;;
    esac
}

state_of() {
    cat "$1/power/runtime_status" 2>/dev/null
}

has_smi() {
    command -v nvidia-smi >/dev/null 2>&1
}

pci_name() {
    vendor=$(cut -c3- "$1/vendor" 2>/dev/null)
    device=$(cut -c3- "$1/device" 2>/dev/null)
    sed -n "/^$vendor  /,/^[0-9a-f]/s/^\t$device  //p" "$PCI_IDS" 2>/dev/null | head -n 1
}

missing_for() {
    case "$1" in
        nvidia) has_smi || echo nvidia-utils ;;
        nouveau | "") echo nvidia-driver ;;
    esac
}

probe() {
    for dev in "$SYS"/bus/pci/devices/*; do
        class=$(cat "$dev/class" 2>/dev/null) || continue
        case "$class" in 0x03*) ;; *) continue ;; esac
        driver=$(basename "$(readlink "$dev/driver" 2>/dev/null)" 2>/dev/null)
        vendor=$(cat "$dev/vendor" 2>/dev/null)
        state=$(state_of "$dev")
        vram=""
        name=""
        case "$driver" in
            amdgpu)
                vram=$(cat "$dev/mem_info_vram_total" 2>/dev/null)
                ;;
            nvidia)
                if [ "$state" != suspended ] && has_smi; then
                    info=$(nvidia-smi -i "${dev##*/}" --query-gpu=memory.total,name --format=csv,noheader,nounits 2>/dev/null | head -n 1)
                    mib=$(printf '%s' "${info%%,*}" | tr -d ' ')
                    case "$mib" in *[!0-9]* | "") ;; *) vram=$((mib * MIB)) ;; esac
                    case "$info" in *,*) name=$(printf '%s' "${info#*,}" | sed 's/^ *//; s/^NVIDIA //') ;; esac
                fi
                ;;
            i915 | xe | nouveau | radeon) ;;
            "") [ "$vendor" = 0x10de ] || continue ;;
            *) continue ;;
        esac
        hwmon=$(ls -d "$dev"/hwmon/hwmon* 2>/dev/null | head -n 1)
        [ -n "$name" ] || name=$(cat "$dev/product_name" 2>/dev/null)
        [ -n "$name" ] || name=$(pci_name "$dev")
        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$dev" "$hwmon" "${dev##*/}" "$vram" "$state" "$name" "${driver:-none}" "$(missing_for "$driver")" "$(discrete_of "$driver" "${dev##*/}")"
    done
}

fdinfo_scan() {
    find "$PROC"/[0-9]*/fd -lname '/dev/dri/*' 2>/dev/null | sed 's|/fd/|/fdinfo/|' | xargs -r awk -v want="$1" -v proc="$PROC" '
        function kib(amount, unit) {
            if (unit == "MiB") return amount * 1024
            if (unit == "GiB") return amount * 1048576
            if (unit == "B" || unit == "") return amount / 1024
            return amount
        }
        function flush() {
            if (client != "" && (want == "" || pdev == "" || pdev == want) && !seen[pid SUBSEP pdev SUBSEP client]++) {
                busy[pid] += work
                span[pid] += total
                mem[pid] += memory > 0 ? memory : shared
                local[pid] += memory
                if (kind != "") kinds[pid] = kind
            }
            client = ""
        }
        FNR == 1 { flush(); n = split(FILENAME, part, "/"); pid = part[n - 2]; client = pdev = kind = ""; work = total = memory = shared = 0 }
        /^drm-client-id:/ { client = $2 }
        /^drm-pdev:/ { pdev = $2 }
        /^drm-engine-(gfx|render):/ { work = $2; kind = "ns" }
        /^drm-cycles-rcs:/ { work = $2; kind = "cycles" }
        /^drm-total-cycles-rcs:/ { total = $2 }
        /^drm-(memory|resident)-(vram|local0)/ { memory = kib($2, $3) }
        /^drm-resident-system0?:/ { shared = kib($2, $3) }
        END {
            flush()
            for (id in busy) {
                path = proc "/" id "/comm"
                name = ""
                getline name < path
                close(path)
                printf "%s\t%s\t%d\t%d\t%d\t%d\t%s\n", id, (id in kinds ? kinds[id] : "ns"), busy[id], span[id], mem[id], local[id], name
            }
        }' 2>/dev/null
}

local_vram() {
    awk -F'\t' '{ kib += $6 } END { printf "%d\n", kib * 1024 }'
}

counters() {
    awk -F'\t' '
        { kind = $2; work += $3; total += $4 }
        END { if (kind == "") print "-"; else printf "%s\t%d\t%d\n", kind, work, total }'
}

nvidia_readings() {
    if ! has_smi; then
        printf -- '-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n'
        return
    fi
    nvidia-smi -i "$1" --query-gpu="$NVIDIA_QUERY" --format=csv,noheader,nounits 2>/dev/null | head -n 1 | awk -F', *' -v mib="$MIB" -v micro="$MICRO" -v milli="$MILLI" '
        function num(text) { return text ~ /^[0-9.]+$/ }
        function out(text, scale) { if (num(text)) printf "%.0f\n", text * scale; else print "-" }
        {
            out($1, 1); out($2, mib); out($3, mib); out($4, milli)
            out($5, micro); print "-"; out($6, micro)
            out($7, 1); print (num($7) ? 100 : "-"); print "-"
            out($8, micro)
        }
        END { if (NR == 0) for (i = 0; i < 11; i++) print "-" }'
}

intel_clock() {
    for file in "$1"/drm/card*/gt_act_freq_mhz "$1"/tile0/gt0/freq0/act_freq; do
        [ -r "$file" ] || continue
        echo $(($(cat "$file") * MICRO))
        return
    done
    echo -
}

hwmon_readings() {
    first_value "$1" temp1_input temp2_input
    if [ -n "${2:-}" ]; then first_value "$HWINFO" "$2"; else first_value "$1" power1_input; fi
    first_value "$1" power1_average
    first_value "$1" power1_cap power1_max
    first_value "$1" pwm1
    first_value "$1" pwm1_max
    first_value "$1" fan1_input
}

read_card() {
    driver=$1 dev=$2 hwmon=$3 pci=$4
    if [ "$(state_of "$dev")" = suspended ]; then
        echo suspended
        return
    fi
    echo active
    case "$driver" in
        amdgpu)
            for file in gpu_busy_percent mem_info_vram_used mem_info_vram_total; do value "$dev/$file"; done
            hwmon_readings "$hwmon"
            first_value "$hwmon" freq1_input
            echo -
            ;;
        radeon)
            printf -- '-\n-\n-\n'
            hwmon_readings "$hwmon"
            first_value "$hwmon" freq1_input
            echo -
            ;;
        nvidia)
            nvidia_readings "$pci"
            echo -
            ;;
        i915 | xe)
            scan=$(fdinfo_scan "$pci")
            echo -
            if intel_integrated "$pci"; then
                echo -
                echo -
                hwmon_readings "$hwmon" gpu_power
            else
                printf '%s' "$scan" | local_vram
                echo -
                hwmon_readings "$hwmon"
            fi
            intel_clock "$dev"
            printf '%s' "$scan" | counters
            first_value "$hwmon" energy1_input
            ;;
    esac
}

nvidia_processes() {
    has_smi || return 0
    nvidia-smi pmon -i "$1" -c 1 -s um 2>/dev/null | awk '
        /^# *gpu/ { for (i = 2; i <= NF; i++) column[$i] = i - 1; next }
        /^#/ || !("pid" in column) { next }
        $column["pid"] ~ /^[0-9]+$/ {
            sm = $column["sm"]; fb = $column["fb"]
            name = $column["command"]
            for (i = column["command"] + 1; i <= NF; i++) name = name " " $i
            kib = fb ~ /^[0-9]+$/ ? fb * 1024 : 0
            printf "%s\tpct\t%d\t0\t%d\t%d\t%s\n", $column["pid"], (sm ~ /^[0-9]+$/ ? sm : 0), kib, kib, name
        }'
}

processes() {
    driver=$1 dev=$2 pci=$3
    [ "$(state_of "$dev")" = suspended ] && return 0
    case "$driver" in
        nvidia) nvidia_processes "$pci" ;;
        amdgpu | i915 | xe) fdinfo_scan "$pci" ;;
    esac
}

command=${1:-}
[ $# -gt 0 ] && shift
case "$command" in
    probe) probe ;;
    read) read_card "$@" ;;
    procs) processes "$@" ;;
    *)
        echo "usage: gpu.sh probe | read DRIVER DEVICE HWMON PCI | procs DRIVER DEVICE PCI" >&2
        exit 2
        ;;
esac
