# Linux System Health Monitoring Tool Using Bash

## Project overview
A small menu-driven Bash application for Kali Linux that displays basic system health and configuration information. It demonstrates Linux Essentials topics such as shell scripting, commands, process monitoring, networking, service management, pipes, redirection, and text processing.

## Features
1. System information (hostname, OS, kernel, uptime, current user)
2. CPU and RAM usage
3. Root filesystem disk usage
4. IP addresses and default route
5. SSH and Apache service status
6. Top 10 processes by CPU usage
7. Generate a timestamped text report

Reports are saved in `~/linux_health_reports/`.

## Requirements
- Kali Linux or another Linux distribution
- Bash
- Common utilities: `awk`, `df`, `ip`, `ps`, `systemctl`
- `sleep` and `head`

Most features run as a regular user. Service status may depend on systemd and the service being installed.

## Run
Open a terminal in the project folder:

```bash
chmod +x linux_health_monitor.sh
./linux_health_monitor.sh
```

## Demonstration plan
1. Start the script and show its menu.
2. Choose System Information.
3. Show CPU and RAM usage.
4. Show disk and network details.
5. Check SSH/Apache service statuses.
6. Generate a report and open it:
   ```bash
   ls -l ~/linux_health_reports
   cat ~/linux_health_reports/health_report_*.txt
   ```
7. Exit the application.

## Concepts used
- Bash variables, functions, `case`, `while`, `read`
- `hostname`, `uname`, `uptime`, `whoami`
- `/proc/stat` and `/proc/meminfo`
- `awk`, `df`, `ip`, `ps`, `head`
- `systemctl is-active`
- Output redirection (`>`) and pipes (`|`)

## Limitations
- CPU usage is sampled over one second and is an approximate snapshot.
- Service checks only look for `ssh` and `apache2`.
- Root filesystem disk usage is used for the summary; the full report lists all mounted filesystems.
- It is a local monitoring tool, not a remote monitoring or alerting platform.

## Suggested project defense questions
**What is Bash?** A command interpreter and scripting language used to automate tasks in Linux.

**Why use a script?** It combines repeated checks into one menu-driven tool and report.

**What does `df` show?** Filesystem disk space usage.

**What does `systemctl is-active` check?** Whether a systemd service is active.

**What is `/proc`?** A virtual filesystem exposing kernel and process information.

**What does a pipe (`|`) do?** Sends the output of one command as input to another command.

**What does redirection (`>`) do?** Writes command output to a file, replacing its contents.

**Does this tool need root?** Most checks do not. Some service/system information can vary based on permissions and system configuration.
