#!/bin/bash
#
#
# wget -qO ~/community-troubleshooter http://git.io/vewgm && bash ~/community-troubleshooter
#
# Todo:
# check to see if normal folders are there, (rtorrent, rutorrent, deluge, transmission, mysql)
# 	maybe get a list of ALL default files/folders on a feral slot, and check for existance
#
#
mkdir -p ~/www/$(whoami).$(hostname -f)/public_html/tmp
log=$(openssl rand -hex 10).txt
logpath=~/www/$(whoami).$(hostname -f)/public_html/tmp/$log
if [ "$1" = "-c" ];then
        rm ~/www/$(whoami).$(hostname -f)/public_html/tmp/*.txt
	echo Old logs have been removed
	exit
fi
if [ -a ~/www/$(whoami).$(hostname -f)/public_html/tmp/index.html ];then
	:
else
	touch ~/www/$(whoami).$(hostname -f)/public_html/tmp/index.html
fi
#
echo -e "\033[33m""This script will run a series of tests on your slot, and then give you a URL at the end to paste into IRC...""\e[0m"
sleep 3
echo "$(whoami)" on "$(hostname -f) on "$(date) > $logpath
echo | tee -a $logpath
echo "#####################################################" | tee -a $logpath
echo "#                     CPU Info                      #" | tee -a $logpath
echo "#####################################################" | tee -a $logpath
echo | tee -a $logpath
echo "Server has been up for $(uptime | awk '{print $3}') days." | tee -a $logpath
echo "For the past minute, the average CPU utilization has been $(uptime | awk '{print $10}')" | tee -a $logpath
echo "For the past 5 minutes, the average CPU utilization has been $(uptime | awk '{print $11}')" | tee -a $logpath
echo "For the past 15 minutes, the average CPU utilization has been $(uptime | awk '{print $12}')" | tee -a $logpath
echo "As long as these numbers are below $(nproc), CPU usage is fine." | tee -a $logpath
echo | tee -a $logpath
echo "#####################################################" | tee -a $logpath
echo "#                  Hard Drive Info                  #" | tee -a $logpath
echo "#####################################################" | tee -a $logpath
echo | tee -a $logpath
echo "You are using $(du -sB GB ~/| awk '{print $1}') of space on your slot." | tee -a $logpath
echo "Your disk is $(df -h $(df -h ~/ | grep dev | awk '{print $1}') | grep dev | awk '{print $5}') used. (not your quota, unless on Radon)" | tee -a $logpath
echo "The OS disk is $(df -h / | grep dev | awk '{print $5}') used. (there is an issue if it is %100)" | tee -a $logpath
echo >> $logpath
echo -e "\033[33m""For the next 30 seconds, your disk will be monitored to see how busy it is.""\e[0m"
echo "Disk utilization over 30 seconds" >> $logpath
iostat -x 5 7 -d $(df -h ~ | grep dev | awk '{print $1}') | sed '/^$/d'| grep -v util | awk '{print $14}' | tail -n+3 | sed 's/^/%/' | tee -a $logpath
echo | tee -a $logpath
echo "#####################################################" | tee -a $logpath
echo "#                   Process Info                    #" | tee -a $logpath
echo "#####################################################" | tee -a $logpath
echo | tee -a $logpath
echo "Running proccesses:" | tee -a $logpath
ps x --sort=command | tee -a $logpath
if [ -a ~/.private/rtorrent/.prevent-restart ];then
	echo "rtorrent automatic restart is being prevented" | tee -a $logpath
fi
if [ -a ~/private/transmission/.prevent-restart ];then
	echo "rtorrent automatic restart is being prevented" | tee -a $logpath
fi
if [ -a ~/private/deluge/.prevent-restart ];then
	echo "deluge automatic restart is being prevented" | tee -a $logpath
fi
if [ -a ~/private/mysql/.prevent-restart ];then
	echo "mysql automatic restart is being prevented" | tee -a $logpath
fi
echo | tee -a $logpath
echo "#####################################################" | tee -a $logpath
echo "#                    Other Info                     #" | tee -a $logpath
echo "#####################################################" | tee -a $logpath
echo | tee -a $logpath
echo "Crontab entries:" | tee -a $logpath
crontab -l | grep -v "^#" | tee -a $logpath
echo | tee -a $logpath
echo -e "\033[33m""Testing latency to home router...""\e[0m"
if [ $(ping -c 1 $(echo $SSH_CLIENT | awk '{print $1}') | grep transmitted | awk '{print $4}') = 1 ];then
	echo "Latency to home network:" | tee -a $logpath
	ping -c 5 $(echo $SSH_CLIENT | awk '{print $1}') | grep ttl | awk '{print $7 $8}' | sed 's/time=//' | tee -a $logpath
else
	echo "Home network not responding to pings for latency test" | tee -a $logpath
fi
echo | tee -a $logpath
if [ $(ps aux | grep -v grep | grep -c plex) > 0 ];then
	echo "Plex is already running on this server" | tee -a $logpath
fi

echo
echo "Paste the following URL in chat, and someone may be able to help troubleshoot."
echo -e "\033[34m""https://$(hostname -f)/$(whoami)/tmp/$log""\e[0m"
echo to delete this file, run the following:
echo bash "~/community.troubleshooter -c"
