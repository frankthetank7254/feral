#!/bin/bash
# Script name goes here
scriptversion="1.0.0"
scriptname="auto-reroute"
# Author adamaze
#
# XXX
#
############################
#### Script Notes Start ####
############################
#
# This updater deals with updating a single file, the "~/bin/somescript", by updating and switching to this script.
#
# How do I customise this updater?
#
# 3: Set the scripturl variable in the variable section to the RAW github URl of the script for updating.
# 4: Insert your script in the "User Script" labelled section - Indented by two tabs to be in line with the script.
# 5: Disable the updater - you can either set "updaterenabled" variable to 0 in the variable section or use the argument nu when calling the script, for example - "somescript nu"
# 6: quick load - use the argument qr when calling the script, for example - "somescript qr".
# 7: To pass your own variables to the script start from $3 onwards.
#
############################
##### Script Notes End #####
############################
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
# Disables the built in script updater permanently.
updaterenabled="0"
#
# This is the raw github url of the script to use with the built in updater.
scripturl="XXX"
#
routes=(0.0.0.0 77.67.64.81 78.152.33.250 78.152.57.84 81.20.64.101 81.20.69.197 87.255.32.229 87.255.32.249)
route_names=(Default GTT Atrato#1 Atrato#2 NTT#1 NTT#2 Fiber-Ring/Leaseweb#2 Fiber-Ring/Leaseweb#1)
#
test_files=(https://feral.io/test.bin https://gtt-1.feral.io/test.bin https://atrato-1.feral.io/test.bin https://atrato-2.feral.io/test.bin https://ntt-1.feral.io/test.bin https://ntt-2.feral.io/test.bin https://fr-1.feral.io/test.bin https://fr-2.feral.io/test.bin)
count=-1
reroute_log=$(mktemp)
############################
####### Variable End #######
############################
#
############################
#### Self Updater Start ####
############################
#
if [[ ! -z $1 && $1 == 'qr' ]] || [[ ! -z $2 && $2 == 'qr' ]];then echo -n '' > ~/.quickrun; fi
#
if [[ ! -z $1 && $1 == 'nu' ]] || [[ ! -z $2 && $2 == 'nu' ]]
then
    echo
    echo "The Updater has been temporarily disabled"
    echo
    scriptversion=""$scriptversion"-nu"
else
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
        echo
    else
        echo
        echo "The Updater has been disabled"
        echo
        scriptversion=""$scriptversion"-DEV"
    fi
fi
#
if [[ -f ~/.quickrun ]];then updatestatus="y"; rm -f ~/.quickrun; fi
#
############################
##### Self Updater End #####
############################
#
############################
#### Core Script Starts ####
############################
#
if [[ "$updatestatus" == "y" ]]
then
    :
else
    echo -e "Hello $(whoami), you have the latest version of the" "\033[36m""$scriptname""\e[0m" "script. This script version is:" "\033[31m""$scriptversion""\e[0m"
    echo
    read -ep "The script has been updated, enter [y] to continue or [q] to exit: " -i "y" updatestatus
    echo
fi
#
if [[ "$updatestatus" =~ ^[Yy]$ ]]
then
#
############################
#### User Script Starts ####
############################
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
	echo "Setting route to $fastestroute ..."
	curl 'https://network.feral.io/reroute' --data "nh=$fastestroute" >/dev/null 2>&1
	echo "Please wait two minutes for route change to take effect..."
	#
	echo 'All done!'
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
