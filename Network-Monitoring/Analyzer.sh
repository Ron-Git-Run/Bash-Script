#!/bin/bash

# Specify the directory to search and later write CSV file to
pcap_search="/project/netlogs/capLogs"

#Specify the directory to search
csv_search="/project/netlogs/refinedLogs"

#A function that searches for ports http, https and ssh
function writeFun() {
	local csv_file=$1

	#Define Sort Arrays
	funStuff=(80 443 22)

	awk -F',' -v values="${funStuff[*]}" '
  BEGIN {
    # Split the values into an array
    split(values, array, " ")
  }
  {
    # Check if the third column value is in the array
    for (i in array) {
      if ($5 == array[i] || $7 == array[i]) {
        print
        break
      }
    }
  }
' "$csv_file"
}

#searches for ports Open VPN, remote desktop protocol
#and Session Initiation Protocol (SIP)
function writeCritical() {
	local csv_file=$1

	#Define Mission Critical Array
	missionCritical=(1189 3389 5060)

awk -F',' -v values="${missionCritical[*]}" '
  BEGIN {
    # Split the values into an array
    split(values, array, " ")
  }
  {
    # Check if the third column value is in the array
    for (i in array) {
      if ($5 == array[i] || $7 == array[i]) {
        print
        break
      }
    }
  }
' "$csv_file"
}

#finds the third most recent file created
function secondLatest() {
	local directory=$1

	#Find the 3rd Last Written to File
	second_recent_file=$(ls -lt "$directory" | awk 'NR==3 {print $9}')
	echo $second_recent_file
}


function returnLatest() {
# Use find to list all files in the directory and its subdirectories
# Sort the files by modification time in descending order
# Print the first file (which is the latest modified file)
	local search_dir=$1
	latest_file=$(find $search_dir -type f -exec ls -lt --time=atime {} + | head -n 1 | awk '{print $NF}')
	echo $latest_file
}

#Define lastest PCAP Capture
latest_pcap=$(secondLatest $pcap_search)

#Refine Lastest PCAP Name
refName=$pcap_search"/"$latest_pcap

#Define necessary time logging for file differentiation
timelog=$(date +%H:%M_%F)

#Define name of CSV write-out file
csvWrtOut="/project/netlogs/refinedLogs/refined_$timelog".csv

#Parse out desired information from logged PCAP file
tshark -r $refName -T fields -e frame.time -e _ws.col.Protocol -e ip.src -e tcp.srcport -e ip.dst -e tcp.dstport -E header=y -E separator=, -E occurrence=f > $csvWrtOut

#Define lastest CSV File
latest_csv=$(returnLatest $csv_search)
#Appending the the functions writeFun and writeCritical to their
#respective directories into monitor.log file
writeCritical $latest_csv >> /project/netlogs/refinedLogs/missionCritical/monitor.log
writeFun $latest_csv >> /project/netlogs/refinedLogs/funStuff/monitor.log
