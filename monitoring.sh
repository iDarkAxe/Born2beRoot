#!/bin/bash

# • Le taux d’utilisation actuel de vos processeurs sous forme de pourcentage.
# • La date et l’heure du dernier redémarrage.
# • Si LVM est actif ou pas.
# • Le nombre de connexions actives.
# • Le nombre d’utilisateurs utilisant le serveur.
# • L’adresse IPv4 de votre serveur, ainsi que son adresse MAC (Media Access Control).
# • Le nombre de commande executées avec le programme sudo.

# Utiliser 'wall' pour ecrire le message sur tous les terminaux (Banniere facultative)
# Utiliser 'cron' pour rappeler ce script en permanence

# cat /etc/os-release

  GNU nano 7.2                          monitoring.sh                                   
#!/bin/bash

ARCH=$(uname -a)
PHYSICAL_CPU=$(cat /proc/cpuinfo | grep "physical id" | uniq | awk '{print $4 + 1}')
VIRTUAL_CPU=$(cat /proc/cpuinfo | grep "processor" | uniq | awk '{print $3 + 1}')

RAM_TOTAL=$(free --mega | grep "Mem" | awk '{print $2}')
RAM_USED=$(free --mega | grep "Mem" | awk '{print $3}')
# RAM_PERCENT=$(free --mega | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
RAM_PERCENT=$(echo $RAM_USED $RAM_TOTAL | awk '{printf("%.2f"), $1/$2 * 100}')

DISK_USED=$(df -B 1000000 --total | grep "total" | awk '{print $3}')
DISK_TOTAL=$(df -B 1000000000 --total | grep "total" | awk '{print $2}')
DISK_PERCENT=$(df -B 1 --total | grep "total" | awk '{printf("%.2f"), $3/$2*100}')

export LANG=C
# CPU_LOAD=$(top -bn1 | grep '%Cpu' | sed 's/,/ /g' | awk '{print 100 - $8}')
# CPU_LOAD=$(top -bn1 | grep '^%Cpu' | cut -c 36-40 | awk '{printf("%.1f%%"),  100 - $1}')
CPU_LOAD=$(awk '/cpu / {usage=($2+$4)*100/($2+$4+$5)} END {printf("%.2f%%"),   usage "%"}' /proc/stat)

LAST_BOOT=$(who -b | awk '{print($3 " " $4)}')

LVM_USE=$(if [ $(lsblk | grep lvm | wc -l) -eq 8 ]; then echo no; else echo yes; fi)

CONN_TCP=$(cat /proc/net/sockstat | grep TCP | awk '{print $3}')

USER_LOG=$(who | wc -l)

IP=(hostname | awk '{print $1}')
MAC=$(ip link show | grep "link/ether" | awk '{print $2}')

SUDO_CMDS=$(journalctl -q "_COMM=sudo" | grep COMMAND | wc -l)
# SUDO_CMDS2=$(cat /var/log/sudo/sudo.log | grep "COMMAND" | wc -l)


echo "  #Architecture: $ARCH
        #CPU physical: $PHYSICAL_CPU
        #vCPU: $VIRTUAL_CPU
        #Memory Usage: $RAM_USED/${RAM_TOTAL}MB ($RAM_PERCENT%)
        #Disk Usage: $DISK_USED/${DISK_TOTAL}GB ($DISK_PERCENT%)
        #CPU load: $CPU_LOAD
        #Last boot: $LAST_BOOT
        #LVM use: $LVM_USE
        #Connections TCP: $CONN_TCP ESTABLISHED
        #User log: $USER_LOG
        #Network: IP $IP ($MAC)
        #Sudo: $SUDO_CMDS cmd"




