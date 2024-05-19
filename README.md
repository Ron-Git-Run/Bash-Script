# Network-Monitoring

Catcher.SH

#!/bin/bash

#Directory for stored logs

dir="/project/netlogs/capLogs/"

#Create time log for file

timelog=$(date +%H:%M_%F)

#Create Write-Out file name

filename=$dir"netlog"$timelog.pcap

#Write out a PCAP file that contains traffic for 60 secs

sudo tcpdump -i enp3s0 -w $filename -s 0 -n -A -W1 -G60 
