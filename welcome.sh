#!/bin/bash
echo -e "\033[33m""Welcome $(whoami)""\e[0m"
screen -ls
echo -e "\033[33m""You have $(du -s --si ~/ | awk '{print $1;}') of free space""\e[0m"
echo -e "\033[33m""The disk that you are on is $(df  -h $(df -h ~/ | grep dev | awk '{print $1}') | grep dev | awk '{print $5;}') full""\e[0m"
