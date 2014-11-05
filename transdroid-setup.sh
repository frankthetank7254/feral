#!/bin/bash

tmpdir=tmp$(shuf -i 10000-90000 -n 1)
mkdir $tmpdir
wget -qO ~/$tmpdir/td-settings.json http://adamaze.perses.feralhosting.com/settings.json

echo  "Please enter the ruTorrent password from your Account overview page:"
read rtpass

sed "s/USERNAME-CHANGEME/$(whoami)/" ~/$tmpdir/td-settings.json | sed "s/HOSTNAME-CHANGEME/$(hostname -f)/" | sed "s/RTORRENTPASSWORD-CHANGEME/$rtpass/" | sed "s/SERVERNAME-CHANGEME/$(hostname)-rutorrent/" > ~/$tmpdir/settings.json
cp -r ~/$tmpdir ~/www/$(whoami).$(hostname)/public_html/

URL="http://$(whoami).$(hostname -f)/$tmpdir/settings.json"
echo Download the generated config file to your phone using the following link, then, in Transdroid, go to Settings>>System>>Import Settings, and select the downloaded file.
echo Use your phone to navigate here: $URL
echo or use the qrcode below:
echo
#qrencode -t ASCII -o ~/$tmpdir/ascii-code.txt $URL
#sed 's/ /M/g' ~/$tmpdir/ascii-code.txt > ~/$tmpdir/ascii-code2.txt
#sed 's/#/ /g' ~/$tmpdir/ascii-code2.txt

echo After you have downloaded the config file, press ENTER to clean up.
read useless
rm -r ~/$tmpdir ~/www/$(whoami).$(hostname)/public_html/$tmpdir/