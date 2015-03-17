
#!/bin/bash
# Auto Reroute
scriptversion="0.5.0"
scriptname="auto.reroute"
# adamaze
#
# Bash Command XXX
#
############################
#### Script Notes Start ####
############################
#
# Todo:
#	fix automation
#	change test.img filesize 
# 	iostat on feral server
# 
# Longshot:
#	add a log 
# 
#
############################
##### Script Notes End #####
############################
#
############################
## Version History Starts ##
############################
#
# v0.5.0 - first virsion that included standard feral wrapper
#
#############################
### Version History Ends ###
############################
#
############################
###### Variable Start ######
############################
#
updaterenabled="0"
# Defining routes
routes='0.0.0.0 77.67.64.81 78.152.33.250 78.152.57.84 81.20.64.101 81.20.69.197 87.255.32.229 87.255.32.249 149.6.36.66'
#
scripturl="https://raw.githubusercontent.com/frankthetank7254/feral/master/auto-reroute.sh"
#
############################
####### Variable End #######
############################
#
############################
#### Self Updater Start ####
############################
#
if [[ "$updaterenabled" -eq 1 ]]
then
    [[ ! -d ~/bin ]] && mkdir -p ~/bin
    [[ ! -f ~/bin/"$scriptname" ]] && wget -qO ~/bin/"$scriptname" "$scripturl"
    #
    wget -qO ~/.000"$scriptname" "$scripturl"
    #
    if [[ $(sha256sum ~/.000"$scriptname" | awk '{print $1}') != $(sha256sum ~/bin/"$scriptname" | awk '{print $1}') ]]
    then
        echo -e "#!/bin/bash\nwget -qO ~/bin/$scriptname $scripturl\ncd && rm -f $scriptname{.sh,}\nbash ~/bin/$scriptname\nexit" > ~/.111"$scriptname"
        bash ~/.111"$scriptname"
        exit
    else
        if [[ -z $(ps x | fgrep "bash $HOME/bin/$scriptname" | grep -v grep | head -n 1 | awk '{print $1}') && $(ps x | fgrep "bash $HOME/bin/$scriptname" | grep -v grep | head -n 1 | awk '{print $1}') -ne "$$" ]]
        then
            echo -e "#!/bin/bash\ncd && rm -f $scriptname{.sh,}\nbash ~/bin/$scriptname\nexit" > ~/.222"$scriptname"
            bash ~/.222"$scriptname"
            exit
        fi
    fi
    cd && rm -f .{000,111,222}"$scriptname"
    chmod -f 700 ~/bin/"$scriptname"
else
    echo
    echo "The Updater has been disabled"
fi
#
############################
##### Self Updater End #####
############################
#
############################
#### Core Script Starts ####
############################
#
echo
echo -e "Hello $(whoami), you have the latest version of the" "\033[36m""$scriptname""\e[0m" "script. This script version is:" "\033[31m""$scriptversion""\e[0m"
echo
read -ep "The script has been updated, enter [y] to continue or [q] to exit: " -i "y" updatestatus
echo
if [[ "$updatestatus" =~ ^[Yy]$ ]]
then
#
############################
#### User Script Starts ####
############################
#
# checking prerequisites 
	if [ -f /usr/bin/curl ]; then
		:
	else
		echo "You need to install curl for this script to work"
		exit
	fi
	
	ipv6=$(curl --silent https://network.feral.io/reroute | grep -o addresses )
	if [ -z $ipv6 ]; then
		:
	else
		echo "This tool only works with IPv4 addresses."
		exit
	fi
###########################


# Cleanup in case script didnt finish last time it was run
	rm -f /tmp/auto-reroute.log

	#if [ -z $1 ]; then
		read -ep "Please enter the hostname of your slot. (without 'feralhosting.com') : " host
		#echo this script can also be called like this for automation:  $0 host username
	#fi
	#if [ -z $2 ]; then
		read -ep "Please enter your username: " username
		#echo this script can also be called like this for automation:  $0 host username
	#fi

	echo "You can also call this script the following way for automation: ./auto-reroute.sh host username"
	echo -e "Now using SSH to create the test download file on your slot\n"
	ssh $username@$host.feralhosting.com 'fallocate -l 10M ~/www/$(whoami).$(hostname)/public_html/auto-reroute-test.img'

# here is the meat and potatoes
	for route in $routes
	do
		echo "Setting route to $route ..."
		curl 'https://network.feral.io/reroute' --data "nh=$route" 2>/dev/null > /dev/null
		echo "Waiting 2 minutes for route change to take effect..."
# edit this next line to "2 * 60" when done testing
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

#
############################
#### User Script Starts ####
############################
#
	#
#
############################
##### User Script End  #####
############################
#
else
    echo -e "You chose to exit after updating the scripts."
    echo
    cd && bash
    exit 1
fi
#
############################
##### Core Script Ends #####
############################
#
