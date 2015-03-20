#!/bin/bash
#
mkdir -p ~/bin && bash
wget -qO ~/znc.tar.gz http://znc.in/releases/znc-latest.tar.gz
tar xf ~/znc.tar.gz && cd ~/znc-1.*
./configure --prefix=$HOME
make && make install
cd && rm -rf znc{-1.*,.tar.gz}
~/bin/znc --makeconf

# adding to cron
tmpnum=$(shuf -i 10001-20000 -n 1) 
if [ "$(crontab -l)" == "no crontab for $(whoami)" ]; then
        echo "crontab does not currently exist, so we are creating one"
        echo "@reboot ~/bin/znc" >> ~/crontab.$tmpnum.tmp
        crontab ~/crontab.$tmpnum.tmp
        rm ~/crontab.$tmpnum.tmp
else
        if [ $(crontab -l | grep -c znc) == "0" ]; then
                echo "crontab does exist, and znc is not in there, so we are appending it"
                crontab -l > ~/crontab.$tmpnum.tmp   
                echo "@reboot ~/bin/znc" >> ~/crontab.$tmpnum.tmp
                crontab ~/crontab.$tmpnum.tmp
                rm ~/crontab.$tmpnum.tmp
        else
                echo "znc is already in crontab"
        fi
fi

# give user the full URL
echo -e "\nhttps://$(hostname -f):$(grep Port ~/.znc/configs/znc.conf | awk '{print $3}')"


