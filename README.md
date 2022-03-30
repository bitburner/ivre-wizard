```
IVRE
 (\.   \      ,/) _                  _ 
  \(   |\     )/ (_)______ _ _ __ __| |
  //\  | \   /\  | |_  / _` | '__/ _` |
 (/ /\_#oo#_/\ \)| |/ / (_| | | | (_| |
  \/\  ####  /\/ |_/___\__,_|_|  \__,_|      
By BitBurner
```
# ivre-wizard
An interactive wizard front end for IVRE to make creating scans to the database easier.

# Why?
I created this script for doing scans with IVRE (https://ivre.rocks/) on Kali (https://www.kali.org/) where IVRE comes pre installed and configured. This makes scanning with IVRE more practical for non-production environments like for CTF and labs. I recommend setting up Wireguard on Linode or other cloud host and pipe all your scan traffic through there. 

# Requirements
- IVRE - Comes ready to go in Kali.
- zenity - Should be installed in Kali by default. If not apt install zentiy.

# Install and run

First update your IVRE IPdata (you should do this frequently (weekly) as it matches data like AS numbers etc to scanned hosts and populates the data with more meaning)

```
sudo ivre ipdata --download
```

Clone the repo

```
git clone https://github.com/bitburner/ivre-wizard.git
```

Make the scripts executable

```
sudo chmod +x ivre-wizard/ivre-wizard.sh && sudo chmod -x ivre-wizard/ivre-wizard-cli.sh
```

Run the script (the main script uses Zenity GUI elements to prompt the user with dialog boxes in your GUI. If you want a command line only version with no zentiy dialog boxes use ivre-wizard-cli.sh instead).

```
sudo ./ivre-wizard-wizard/ivre-wizard.sh
```
If you have trouble running in sudo try without but when it runs the httpd server at the end it will be with sudo which will cause it to look for the scans folder in the root users folder not the user who started the scan. Quit it and run it again by hand without sudo and see if you data appears. "ivre httpd --bind-address 0.0.0.0" This is one of the main reason I have the script tell you with what accounts it's doing certain processes so you know where things end up. I'll try to fix this eventually.

# Useage

This script builds a IVRE runscans command from user input

- Start Wireguard?
    - This assumes you're using a wireguard VPN and asks to make sure it started before doing a large internet scan.

- Scan Type
    - These are the different scan types "ivre runscans supports
        - Routable - entire reachable address space from your endpoint
        - AS-Number - AS Number. You can use https://bgp.he.net for reference
        - Country - Region code (*this needs some work still)
        - Network - General network scan example: 192.168.1.0/24
        - File - This is a path to a file of a list of IPs on single line

- Category Name
    - This is an arbitrary name for an organization name to filter your scans by later in the IVRE Web interface. This should not have spaces.

- Scan Source Name
    - This again is an arbitrary name you can set for organization and helps when scans are coming from multiple sources. Just remember no spaces.

- Scan Limit
    - Sets the limit of the amount of hosts it will scan within the given scan type. The more you scan the longer it takes. Start with small limits for testing.

- Number of instances
    - This is the number of instances of NMAP that do the actual scan. If you have 1000 hosts to scan and choose 10 instances, 10 NMAPS will scan 100 hosts each simultaneously. Be careful here as this is CPU intensive. Not RAM intensive at all so keep that in mind if making say a virtual machine to run this from.

- Do the scan
    - This runs the scan according to your inputs. When it finishes the scan it will use "ivre scan2db" and import the scan in the database. Then "ivre db2view nmap" will create a "view" according to your Category and other data from the NMAP scan. This can take as long as the scan sometimes if a lot of data was returned for hosts (Lots of open ports etc). Finally it will start the “ivre httpd” on “0.0.0.0” and you can access the webpage http://127.0.0.1/ and see the data that was just added. No data? Did you run the script as sudo? It needs to be in order to find its “scans” folder.

    @bitburner
