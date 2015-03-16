#!/bin/bash
#
# 
# Todo:
#       create script for later auto-run
#       put whole script in formal feral wrapper
#       change test.img filesize 
#       iostat on feral server
# 
# Longshot:
#       add a log 
# 
# 
# Defining routes
routes='0.0.0.0 77.67.64.81 78.152.33.250 78.152.57.84 81.20.64.101 81.20.69.197 87.255.32.229 87.255.32.249 149.6.36.66'
#
###########################
# checking prerequisites 
###########################
if [ -f /usr/bin/curl ]; then
        sleep .1
else
        echo "You need to install curl for this script to work"
        exit
fi

ipv6=$(curl --silent https://network.feral.io/reroute | grep -o addresses )
if [ -z $ipv6 ]; then
        sleep .1
else
        echo "This tool only works with IPv4 addresses."
        exit
fi
###########################

# Cleanup in case script didnt finish last time it was run
rm -f /tmp/auto-reroute.log


read -ep "Please enter the hostname of your slot. (without 'feralhosting.com') : " host
read -ep "Please enter your username: " username
echo -e "Now using SSH to create the test download file on your slot\n"
ssh $username@$host.feralhosting.com 'fallocate -l 10M ~/www/$(whoami).$(hostname)/public_html/auto-reroute-test.img'

# here is the meat and potatoes
for route in $routes
do
        echo "Setting route to $route ..."
        curl 'https://network.feral.io/reroute' --data "nh=$route" 2>/dev/null > /dev/null
        echo "Waiting 2 minutes for route change to take effect..."
        secs=$((2 * 60))
        while [ $secs -gt 0 ]; do
                echo -ne "$secs\033[0K\r"
                sleep 1
                : $((secs--))
        done
        echo "Testing single segment download speed from $1 ..."
        speed=$(wget -O  /dev/null --report-speed=bits http://$host.feralhosting.com/$username/auto-reroute-test.img 2>&1 | tail -n 2 | head -n 1 | awk '{print $3 $4}' | sed 's/(//' | sed 's/ //' | sed 's/)//')
        if [ $speed = "ERROR404:" ]; then
                echo -e "\033[31m""\nThe test file 'auto-reroute-test.img' cannot be found at http://$host.feralhosting.com/$username/auto-reroute-test.img \n""\e[0m"
                exit
        fi
        echo "routing through $route gets $speed"
        echo 
        echo "$speed $route" >> /tmp/auto-reroute.log
done

# This determines the fastest route of the routes tested, and what that speed was
fastestroute=$(sort -hr /tmp/auto-reroute.log | head -n 1 | awk '{print $2}')
fastestspeed=$(sort -hr /tmp/auto-reroute.log | head -n 1 | awk '{print $1}')

rm -f /tmp/auto-reroute.log
echo -e "Routing through $fastestroute provided the highest speed of $fastestspeed"
echo "Setting route to $fastestroute ..."
curl 'https://network.feral.io/reroute' --data "nh=$fastestroute" 2>/dev/null > /dev/null
echo "Please wait two minutes for route change to take effect..."
echo "Now using SSH to remove the test download file"
ssh $username@$host.feralhosting.com rm '~/www/$(whoami).$(hostname)/public_html/auto-reroute-test.img'

echo 'All done!'
exit
