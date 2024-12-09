#!/bin/bash

ARCH=$(uname -a)
PHYSICAL_CPU=$(cat /proc/cpuinfo | grep "physical id" | uniq | awk '{print $4 + 1}')
if [ $(echo "$PHYSICAL_CPU" | wc -l) -gt 1 ]; then
  PHYSICAL_CPU=$(cat /proc/cpuinfo | grep "physical id" | uniq | sort -r | head -n 1 | awk '{print $4 + 1}');
fi
VIRTUAL_CPU=$(cat /proc/cpuinfo | grep "processor" | uniq | awk '{print $3 + 1}')
if [ $(echo "$VIRTUAL_CPU" | wc -l) -gt 1 ]; then
  VIRTUAL_CPU=$(cat /proc/cpuinfo | grep "processor" | uniq | sort -r | head -n 1 | awk '{print $3 + 1}');
fi

RAM_TOTAL=$(free --mega | grep "Mem" | awk '{print $2}')
RAM_USED=$(free --mega | grep "Mem" | awk '{print $3}')
RAM_PERCENT=$(echo $RAM_USED $RAM_TOTAL | awk '{printf("%.2f"), $1/$2 * 100}')

DISK_UTILS=$(df -B 1000000 --total | grep "total" | awk '{printf("%s %s"), $2, $3}')
DISK_USED=$(echo $DISK_UTILS | awk '{print $2}')
DISK_TOTAL=$(echo $DISK_UTILS | awk '{printf("%d"), $1 / 1000}')
DISK_PERCENT=$(echo $DISK_USED $DISK_TOTAL | awk '{printf("%.2f"), $1 / 1000 * 100 / $2}')

export LANG=C
CONTENT=$(cat /proc/stat)
CPU_LOAD_TOTAL=$(echo $CONTENT | awk '/cpu / {printf("%.2f"), $2 + $3 + $4 + $5 + $6 + $7 + $8}')
CPU_LOAD_IDLE=$(echo $CONTENT | awk '/cpu / {printf("%.2f"), $5 + $6}')
CPU_LOAD=$(echo $CPU_LOAD_IDLE $CPU_LOAD_TOTAL| awk '{printf("%.2f%%"), 100 - ($1 * 100 / $2)}')
# CPU_LOAD=$(top -bn1 | grep '%Cpu' | sed 's/,/ /g' | awk '{print 100 - $8}')
# CPU_LOAD=$(top -bn1 | grep '^%Cpu' | cut -c 36-40 | awk '{printf("%.1f%%"), 100 - $1}')

LAST_BOOT=$(who -b | awk '{print($3 " " $4)}')

LVM_NBR=$(lsblk | grep lvm | wc -l)
LVM_USE=$(if [ $(echo "$LVM_NBR") -gt 0 ]; then echo yes; else echo no; fi)

CONN_TCP=$(cat /proc/net/sockstat | grep TCP | awk '{print $3}')

USER_LOG=$(who | wc -l)

IP=$(hostname -I | awk '{print $1}')
MAC=$(ip link show | grep "link/ether" | awk '{print $2}')
if [ $(echo "$MAC" | wc -l) -gt 1 ]
then
  MAC=$(echo "$MAC" | sed ':a;N;$!ba;s/\n/ et /g')
fi

# Count Nbr of Sudos from the start 
# Second counts from the log file creation and setup
# SUDO_CMDS=$(journalctl -q "_COMM=sudo" | grep COMMAND | wc -l)
SUDO_CMDS=$(cat /var/log/sudo/sudo.log | grep "COMMAND" | wc -l)

# should replace 'wall' by 'echo' for tests
wall "  #Architecture: $ARCH
        #CPU physical: $PHYSICAL_CPU
        #vCPU: $VIRTUAL_CPU
        #Memory Usage: $RAM_USED/${RAM_TOTAL}MB ($RAM_PERCENT%)
        #Disk Usage: $DISK_USED/${DISK_TOTAL}GB ($DISK_PERCENT%)
        #CPU load: $CPU_LOAD
        #Last boot: $LAST_BOOT
        #LVM use: $LVM_USE ($LVM_NBR)
        #Connections TCP: $CONN_TCP ESTABLISHED
        #User log: $USER_LOG
        #Network: IP $IP ($MAC)
        #Sudo: $SUDO_CMDS cmd"
