#!/bin/bash
# Auto-reroute
scriptversion="1.0.0"
scriptname="auto-reroute"
# Author adamaze
#
# wget -O ~/auto-reroute.sh http://git.io/hsFb && bash ~/auto-reroute.sh
#
############################
#### Script Notes Start ####
############################
#
# This script is meant to be run on a linux machine at your home.
# It will download test files using each of Feral's available routes, determine the fastest one, and then set that route for you.
# You need wget and curl for this to work
#
############################
##### Script Notes End #####
############################
# I didn't know where to put this as i didnt want to put it with the bulk of the script, and i wanted it checked early
if [ "$(hostname -f | awk -F. '{print $2;}')" == "feralhosting" ]; then
	echo -e "\033[31m""it looks like you are trying to run this from a Feral slot, it is meant to be run from your home network""\e[0m"
	exit
fi
#
############################
## Version History Starts ##
############################
#
# v1.0.0 - First version with official test downloads.
#
############################
### Version History Ends ###
############################
#
############################
###### Variable Start ######
############################
#
#
routes=(0.0.0.0 77.67.64.81 78.152.33.250 78.152.57.84 81.20.64.101 81.20.69.197 87.255.32.229 87.255.32.249)
route_names=(Default GTT Atrato#1 Atrato#2 NTT#1 NTT#2 Fiber-Ring/Leaseweb#2 Fiber-Ring/Leaseweb#1)
#
test_files=(https://feral.io/test.bin https://gtt-1.feral.io/test.bin https://atrato-1.feral.io/test.bin https://atrato-2.feral.io/test.bin https://ntt-1.feral.io/test.bin https://ntt-2.feral.io/test.bin https://fr-1.feral.io/test.bin https://fr-2.feral.io/test.bin)
count=-1
reroute_log=/tmp/$(openssl rand -hex 10)
############################
####### Variable End #######
############################
#
############################
#### User Script Starts ####
############################
#
# Prerequisite check
command -v curl >/dev/null 2>&1 || { echo >&2 "This script requires curl but it's not installed.  Aborting."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "This script requires wget but it's not installed.  Aborting."; exit 1; }
#
#
	for i in "${routes[@]}"
	do
		((count++))
		echo "Testing single segment download speed from ${route_names[$count]}..."
		speed=$(wget -O  /dev/null ${test_files[$count]} 2>&1 | tail -n 2 | head -n 1 | awk '{print $3 $4}' | sed 's/(//' | sed 's/ //' | sed 's/)//')
		if [ $speed = "ERROR404:" ]; then
			echo -e "\033[31m""\nThe test file cannot be found at ${test_files[$count]} \n""\e[0m"
			exit
		fi
	                echo -e "\033[32m""routing through ${route_names[$count]} results in $speed""\e[0m"
	                echo 
	                echo "$speed ${routes[$count]} ${route_names[$count]}" >> $reroute_log
	done
	#
	fastestroute=$(sort -hr $reroute_log | head -n 1 | awk '{print $2}')
	fastestspeed=$(sort -hr $reroute_log | head -n 1 | awk '{print $1}')
	fastestroutename=$(sort -hr $reroute_log | head -n 1 | awk '{print $3}')
	#
	echo -e "Routing through $fastestroutename provided the highest speed of $fastestspeed"
	echo "Setting route to $fastestroutename / $fastestroute ..."
	curl 'https://network.feral.io/reroute' --data "nh=$fastestroute" >/dev/null 2>&1
	echo "Please wait two minutes for route change to take effect..."
	rm $reroute_log
	#
	echo 'All done!'
#
############################
##### User Script End  #####
############################
#
############################
##### Core Script Ends #####
############################
#
