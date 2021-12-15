#!/bin/bash

echo "#Architecture : $(uname -a)"
echo "#CPU Physical : $(cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)"
echo "#vCPU : $(nproc)"
echo "#Memory Usage : $(free --mega | grep Mem | awk '{printf "%d/%dMB (%d%%)", $3, $2, $3/$2*100}')"
echo "#Disk Usage : $(df | tail -n+2 | awk '{tot+=$2} {cur+=$3} END {printf "%.1f/%.1fGB (%.1f%%)", cur/1000000, tot/1000000, cur/tot*100}')"
echo "#CPU Load : $(vmstat | tail -n+3 | awk '{idle+=$15} END {printf "%d%", 100-idle}')"
echo "#Last boot : $(who -b | awk '{printf "%s %s", $3, $4}')"
echo "#LVM Use : $(if [ $(lsblk | grep "lvm" | wc -l) -gt "0" ]
then echo "yes"
else echo "no" 
fi)"
echo "#TCP Connections :$(ss -s | grep estab | awk '{print $4}' | tr -d ',\n' && echo ' ESTABLISHED')"
echo "#User Log : $(who | awk '{print $1}' | sort | uniq | wc -l)"
echo "#Network : $(ip a | grep 'ether\|global' | awk '{print $2}' | sed 's/\/.*//' | tr '\n' ' ' | awk '{printf "IP %s (%s)", $2, $1}')"
echo "#Sudo : $(cat /var/log/sudo/sudo.log | grep -c "COMMAND" | tr -d '\n' && echo " cmd")"
