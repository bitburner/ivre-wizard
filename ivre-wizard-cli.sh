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

while true; do
read -p "Start Wireguard? y/n " yn
case $yn in
	[Yy]*) sudo wg-quick up wg0; break;;
	[Nn]*) break;;
	*) echo "Please answer yes or no.";;

	esac
done

# ask to clear database and start with empty database or add to existing data

while true; do
read -p "Clear the database of previous scan data or add scan to existing data? Add or Clear: " cleardb

case $cleardb in

	[Addadd]*) break;;
	[Clearclear]*) sudo ivre scancli --init && ivre view --init; break;;
	*) echo "Please answer Add or Clear only."

	esac
done


# ask what scan type to do. Need to add some types and debug region and file.
echo ""
PS3="
Choose a scan type "

tasks=("Routable" "AS-Number" "Country" "Network" "File" "Quit")

select fav in "${tasks[@]}"; do
	case $fav in

		"Routable")
			scan="--routable"
			break
			;;
			
		"AS-Number")
		
			scan="--asnum"
			read -p "Enter an AS Number. Example: AS1234: " ask
			break
			;;
			
		"Country")
			scan="--region"
			ead -p "Enter a Region code. Example: RU: " ask
			break
			;;
			
		"Network")
			scan="--network"
			read -p "Enter a Network. Example: 192.168.1.0/24: " ask
			break
			;;
		
		"File")
			sscan="--file"
			read -p "Enter full path to file: " ask 
			break
			;;
		
		"Quit")
			echo "Goodbye"
			exit
			;;
		*)
			printf '\e[31m%s\e[0m' "invalid selection: $REPLY";;
	esac 
done

# Set a dynamic category name for each scan to help organize and find scans
read -p "Choose a Category Name With No-Spaces: " category

# Set a source scan name. This is for orginization like the category.
read -p "Choose a Scan Source Name With No-Spaces: " scansource 

# Prompts user to set a scan limit. More to scan means more time it takes
read -p "Set a Scan Limit. Example 1000: " setlimit 

# Prompts user to set number of NMAP instances that will run at once.
read -p "Set number of instances. Example 10: " setprocesses 

# Ask user to do scan or not

while true; do
read -p "Do the scan? y/n: " yn
case $yn in
	[Yy]*) echo -e "⏳ ${GREEN}Scan Started as $USER ${NOCOLOR}" &&
	ivre runscans ${scan} ${ask} --limit $setlimit --output=XMLFork --processes $setprocesses &&
	echo -e "⏳ ${GREEN}Import Started as $USER ${NOCOLOR}" &&
	ivre scan2db -c ${category//[[:blank;]]/} -s ${scansource//[[:blank;]]/} -r scans/${scansource//[[:blank;]]/}/up/*;
	echo -e "⌛ ${GREEN}Creating View from imported scans as $USER ${ORANGE}Be patient, this may take a while...${NOCOLOC}" &&
	ivre db2view nmap &&
	echo -e "🛠 ${RED}Removing Scans after import. ${ORANGE}Almost done...${NOCOLOR}" &&
	sudo rm -rf scans/* &&
	echo -e "❗${GREEN}Imported Scans Deleted${NOCOLOR}"; break;;
	[Nn]*) echo "Bye"; exit;;
	*) echo "Please answer yes or no.";;

	esac
done
                                                        
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
