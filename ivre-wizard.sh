#!/bin/bash

# colors



# Title Splash
echo "IVRE"
echo " (\.   \      ,/)"
echo "  \(   |\     )/"
echo "  //\  | \   /\\"
echo " (/ /\_#oo#_/\ \)"
echo "  \/\  ####  /\/"
toilet --metal -f standard Wizard
toilet -f term By BitBurner

# Ask to start Wireguard VPN tunnel
zenity --height=100 --width=300 --question --text "Start Wireguard?"

if [[ $? = 0 ]];

then
	sudo wg-quick up wg0
fi

# ask what scan type to do. Need to add some types and debug region and file.
scantype="$(zenity --height=300 --width=300 --list \
		--radiolist \
		--title="Choose a scan type" \
		--column="Choose" --column="Scan Type:" \
		FALSE "Routable" \
		FALSE "AS-Number" \
		FALSE "Country" \
		FALSE "Network" \
		FALSE "File")"

if [ $scantype = "Routable" ];

then
	scan="--routable"
fi

if [ $scantype = "AS-Number" ];

then
	scan="--asnum"
	ask="$(zenity --height=100 --width=300 --entry --text "Enter an AS Number \
	Example: AS1234")"
fi

if [ $scantype = "Country" ];

then
	scan="--region"
	ask="$(zenity --height=100 --width=300 --entry --text "Enter a Region code\
	Example: RU")"
fi

if [ $scantype = "Network" ];

then
	scan="--network"
	ask="$(zenity --height=100 --width=300 --entry --text "Enter a Network \
	Example: 192.168.1.0/24")"
fi

if [ $scantype = "File" ];

then
	scan="--file"
	ask="$(zenity ---height=100 --width=300 -entry --text "Enter full path to file...")"
fi

# Set a dynamic category name for each scan to help organize and find scans
cat="$(zenity --height=100 --width=300 --entry --text "Choose a Category Name With No-Spaces!")"


# Prompts user to set a scan limit. More to scan means more time it takes
setlimit="$(zenity --height=100 --width=300 --entry --text "Set a Scan Limit. Exaple: 1-1000")"

# Prompts user to set number of NMAP instances that will run at once.
setprocesses="$(zenity --height=100 --width=300 --entry --text "Set number of instances 1-10")"

# Ask user to do scan or not
zenity --height=100 --width=300 --question --text "Do the scan?"

if [[ $? = 0 ]];

then
	toilet -f term -F border Scan Started as $USER
	
	ivre runscans $scan $ask --categories ${cat} --limit $setlimit --output=XMLFork --processes $setprocesses && 
	toilet -f term -F border Import Started as $USER && 
	ivre scan2db -c ${cat} -s wise-eagle -r scans/${cat}/up/*; 
	toilet -f term -F border Import Finishing as $USER... && 
	sudo ivre db2view nmap && 
	toilet -f term -F border Removing Scans. Almost done... && 
	sudo rm -rf scans/* &&
	toilet -f term -F border Scans Deleted
else
echo "Bye"
exit

fi
figlet ALL DONE!

# start ivre httpd server with newly added conent
toilet -f term -F border starting http server
sudo ivre httpd --bind-address 0.0.0.0

exit
