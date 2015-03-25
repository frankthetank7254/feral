#!/bin/bash

routes=(0.0.0.0 77.67.64.81 78.152.33.250 78.152.57.84 81.20.64.101 81.20.69.197 87.255.32.229 87.255.32.249)
route_names=(Default GTT Atrato#1 Atrato#2 NTT#1 NTT#2 Fiber-Ring/Leaseweb#2 Fiber-Ring/Leaseweb#1)
#
test_files=(https://feral.io/test.bin https://gtt-1.feral.io/test.bin https://atrato-1.feral.io/test.bin https://atrato-2.feral.io/test.bin https://ntt-1.feral.io/test.bin https://ntt-2.feral.io/test.bin https://fr-1.feral.io/test.bin https://fr-2.feral.io/test.bin)
route_count=${#routes[@]}
count=-1
reroute_log=$(mktemp)

for i in "${routes[@]}"
do
	((count++))
	echo "Testing single segment download speed from ${route_names[$count]}..."
	speed=$(wget -O  /dev/null --report-speed=bits ${test_files[$count]} 2>&1 | tail -n 2 | head -n 1 | awk '{print $3 $4}' | sed 's/(//' | sed 's/ //' | sed 's/)//')
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
echo "Setting route to $fastestroute ..."
curl 'https://network.feral.io/reroute' --data "nh=$fastestroute" >/dev/null 2>&1
echo "Please wait two minutes for route change to take effect..."
#
echo 'All done!'
