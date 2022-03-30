#!/bin/bash

# colors

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'


# Title Splash

echo -e "${ORANGE}IVRE${NOCOLOR}"
echo " (\.   \      ,/) _                  _  "
echo "  \(   |\     )/ (_)______ _ _ __ __| | "
echo "  //\  | \   /\  | |_  / _| | '__/ _  | "
echo " (/ /\_#oo#_/\ \)| |/ / (_| | | | (_| | "
echo "  \/\  ####  /\/ |_/___\__|_|_|  \__,_| "
echo -e "${ORANGE}By BitBurner${NOCOLOR}"

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
	ask="$(zenity --height=100 --width=300 --entry --text "Enter a Region code \
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

# Set a source scan name. This is for orginization like the category.
scansource="$(zenity --height=100 --width=300 --entry --text "Choose a Scan Source Name With No-Spaces!")"

# Prompts user to set a scan limit. More to scan means more time it takes
setlimit="$(zenity --height=100 --width=300 --entry --text "Set a Scan Limit. Exaple: 1-1000")"

# Prompts user to set number of NMAP instances that will run at once.
setprocesses="$(zenity --height=100 --width=300 --entry --text "Set number of instances 1-10")"

# Ask user to do scan or not
zenity --height=100 --width=300 --question --text "Do the scan?"

if [[ $? = 0 ]];

then
	echo -e "⏳ ${GREEN}Scan Started as $USER ${NOCOLOR}" &&
	ivre runscans $scan $ask --limit $setlimit --output=XMLFork --processes $setprocesses &&
	echo -e "⏳ ${GREEN}Import Started as $USER ${NOCOLOR}" &&
	ivre scan2db -c ${cat} -s ${scansource} -r scans/${cat}/up/*;
	echo -e "⌛ ${GREEN}Creating View from imported scans as $USER ${ORANGE}Be patient, this may take a while...${NOCOLOC}" &&
	sudo ivre db2view nmap &&
	echo -e "🛠 ${RED}Removing Scans after import. ${ORANGE}Almost done...${NOCOLOR}" &&
	sudo rm -rf scans/* &&
	echo -e "❗${GREEN}Imported Scans Deleted${NOCOLOR}"
else
echo "Bye"
exit

fi
                                                         
echo -e "${GREEN}"                                                         
echo " (\.   \      ,/)"
echo "  \(   |\     )/ "
echo "  //\  | \   /\  "
echo " (/ /\_#oo#_/\ \)"
echo "  \/\_ #### _/\/____   "                  
echo "    / \  | | | |  _ \  ___  _ __   ___  "
echo "   / _ \ | | | | | | |/ _ \| '_ \ / _ \ "
echo "  / ___ \| | | | |_| | (_) | | | |  __/ "
echo " /_/   \_\_|_| |____/ \___/|_| |_|\___| "
echo -e "${NOCOLOR}"                                      


# start ivre httpd server with newly added conent
echo -e "🖥 ⚡ ${GREEN}starting http server ${NOCOLOR}"
sudo ivre httpd --bind-address 0.0.0.0

exit
