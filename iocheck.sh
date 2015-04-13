#! /bin/bash
########################
####Define Variables####
########################
mkdir ~/iocheck
log=~/iocheck/iocheck-$(date +%F.%H.%M.%S).log
current_mountpoint=$(echo $HOME | awk -F "/" '{print $3}')
current_disk=$(df | grep /$current_mountpoint | awk '{print $1}' |  awk -F "/" '{print $3}')
disk_users=$(ls ~/../ | grep -v $(whoami) | grep -v "lost+found")
number_of_disk_users=$(ls ~/../| grep -v lost+found | wc -w)
grep_me=$(echo $disk_users | sed 's/ /\|/g')
########################
#
echo -e "\033[33m""Hello $(whoami), Your slot is located on the following disk:""\e[0m"
echo "Hello $(whoami), Your slot is located on the following disk:" >> $log

df -h | grep -E "Filesystem|$(echo $current_disk)" | tee -a $log

echo | tee -a $log

echo -e "\033[33m""This disk is shared by the following $number_of_disk_users users""\e[0m"
echo "This disk is shared by the following $number_of_disk_users users" >> $log

echo $disk_users $(whoami) | tee -a $log

echo | tee -a $log

echo -e "\033[33m""You are running the following processes:""\e[0m"
echo "You are running the following processes:" >> $log

ps aux | grep $(whoami) | tee -a $log

echo | tee -a $log

echo -e "\033[33m""The other users on your disk are running the following processes:""\e[0m"
echo "The other users on your disk are running the following processes:" >> $log

ps afo user:16,%cpu,%mem,command > ~/tmp_ps_list | tee -a $log

grep -E --color=auto "$grep_me" ~/tmp_ps_list | tee -a $log

rm ~/tmp_ps_list | tee -a $log

echo | tee -a $log

echo | tee -a $log

echo -e "\033[33m""Current disk I/O (a reading every 2 seconds repeated 5 times)""\e[0m"
echo -e "\033[33m""the first reading is actually an average from boot until now, so it may be wildly different than the other readings""\e[0m"
echo "the first reading is actually an average from boot until now, so it may be wildly different than the other readings" >> $log
echo "Current disk I/O (a reading every 2 seconds repeated 5 times)" >> $log

iostat -x 2 5 -m -d /dev/$current_disk | tee -a $log

echo -e "\033[33m"$log"\e[0m" has been created for your records.
echo
showMenu ()
{
	echo Please choose 1 or 2 and press enter...
	echo "1) Show full log (press q to quit when done with log)"
	echo "2) Quit"
	echo
}
while [ 1 ]
do
	showMenu
	read -e CHOICE
	echo
	case "$CHOICE" in
		"1")
			less $log
			;;
		"2")
			exit
			;;
	esac
done
