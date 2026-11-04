#!/usr/bin/env bash
# Linux System Health Monitoring Tool
# Course project: Linux Essentials for Cyber Security

set -u

REPORT_DIR="$HOME/linux_health_reports"
mkdir -p "$REPORT_DIR"

line() { printf '%s\n' '========================================'; }

system_info() {
    line
    echo "SYSTEM INFORMATION"
    line
    printf "Hostname:       %s\n" "$(hostname 2>/dev/null || echo N/A)"
    printf "Kernel:         %s\n" "$(uname -r 2>/dev/null || echo N/A)"
    printf "Operating Sys:  %s\n" "$(. /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-Linux}" || echo Linux)"
    printf "Uptime:         %s\n" "$(uptime -p 2>/dev/null || uptime 2>/dev/null || echo N/A)"
    printf "Current User:   %s\n" "$(whoami 2>/dev/null || echo N/A)"
}

cpu_usage() {
    # Calculate CPU utilization from /proc/stat over a one-second interval.
    read -r _ user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1 _ < /proc/stat
    total1=$((user1 + nice1 + system1 + idle1 + iowait1 + irq1 + softirq1 + steal1))
    idle_total1=$((idle1 + iowait1))
    sleep 1
    read -r _ user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 _ < /proc/stat
    total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))
    idle_total2=$((idle2 + iowait2))
    total_delta=$((total2 - total1))
    idle_delta=$((idle_total2 - idle_total1))
    if (( total_delta > 0 )); then
        awk -v t="$total_delta" -v i="$idle_delta" 'BEGIN { printf "%.1f", (100*(t-i)/t) }'
    else
        echo "N/A"
    fi
}

memory_usage() {
    awk '
    /^MemTotal:/ { total=$2 }
    /^MemAvailable:/ { available=$2 }
    END {
        if (total > 0) {
            used=total-available
            printf "RAM Used: %.1f%% (%d MiB used of %d MiB total)\n", 100*used/total, used/1024, total/1024
        } else { print "RAM information unavailable" }
    }' /proc/meminfo
}

disk_usage() {
    df -hP / | awk 'NR==1 {print "Filesystem  Size  Used  Avail  Use%"} NR==2 {print $1, $2, $3, $4, $5}'
}

network_info() {
    line
    echo "NETWORK INFORMATION"
    line
    if command -v ip >/dev/null 2>&1; then
        echo "IP addresses:"
        ip -brief address show 2>/dev/null || ip address show
        echo
        echo "Default route:"
        ip route show default 2>/dev/null || echo "No default route found"
    else
        echo "The 'ip' command is not available."
    fi
}

service_status() {
    local service="$1"
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            printf "%-10s : ACTIVE\n" "$service"
        else
            printf "%-10s : INACTIVE or not installed\n" "$service"
        fi
    else
        printf "%-10s : systemctl not available\n" "$service"
    fi
}

services_check() {
    line
    echo "SERVICE STATUS"
    line
    service_status ssh
    service_status apache2
}

processes() {
    line
    echo "TOP 10 PROCESSES BY CPU"
    line
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu 2>/dev/null | head -n 11
}

health_summary() {
    local cpu ram disk status="NORMAL"
    cpu="$(cpu_usage)"
    ram="$(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {if(t>0) printf "%.1f",100*(t-a)/t; else print "0"}' /proc/meminfo)"
    disk="$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')"

    if awk -v x="$ram" 'BEGIN {exit !(x>=85)}' || [[ "${disk:-0}" =~ ^[0-9]+$ ]] && (( disk >= 85 )); then
        status="WARNING"
    fi
    if awk -v x="$cpu" 'BEGIN {exit !(x>=90)}'; then
        status="HIGH CPU"
    fi
    printf "CPU Usage:  %s%%\n" "$cpu"
    printf "RAM Usage:  %s%%\n" "$ram"
    printf "Root Disk:  %s%%\n" "${disk:-N/A}"
    printf "Status:     %s\n" "$status"
}

generate_report() {
    local report="$REPORT_DIR/health_report_$(date +%Y%m%d_%H%M%S).txt"
    {
        echo "LINUX SYSTEM HEALTH REPORT"
        echo "Generated: $(date)"
        echo
        system_info
        echo
        line
        echo "RESOURCE USAGE"
        line
        health_summary
        echo
        line
        echo "DISK SPACE"
        line
        df -hP
        echo
        network_info
        echo
        services_check
        echo
        processes
    } > "$report"
    echo
    echo "Report generated successfully:"
    echo "$report"
}

show_menu() {
    clear 2>/dev/null || true
    line
    echo "      LINUX SYSTEM HEALTH MONITOR"
    line
    echo "1. System Information"
    echo "2. CPU and RAM Usage"
    echo "3. Disk Space"
    echo "4. Network Information"
    echo "5. Check Services (SSH / Apache)"
    echo "6. Top Running Processes"
    echo "7. Generate System Report"
    echo "8. Exit"
    line
}

while true; do
    show_menu
    read -r -p "Enter your choice [1-8]: " choice
    case "$choice" in
        1) system_info ;;
        2)
            echo "CPU Usage: $(cpu_usage)%"
            memory_usage
            ;;
        3) disk_usage ;;
        4) network_info ;;
        5) services_check ;;
        6) processes ;;
        7) generate_report ;;
        8) echo "Thank you for using Linux System Health Monitor."; exit 0 ;;
        *) echo "Invalid choice. Please enter a number from 1 to 8." ;;
    esac
    echo
    read -r -p "Press Enter to return to the menu..." _
done
