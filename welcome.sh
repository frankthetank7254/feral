#!/bin/bash
echo -e "\033[33m""Welcome $(whoami)""\e[0m"
screen -ls
echo -e "\033[33m""You have used $(du -s --si ~/ | awk '{print $1;}')""\e[0m"
echo -e "\033[33m""Your shared hard drive is $(df  -h $(df -h ~/ | grep dev | awk '{print $1}') | grep dev | awk '{print $5;}') full""\e[0m"
