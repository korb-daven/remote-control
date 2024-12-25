#!/bin/bash

IP=$(curl -s ifconfig.me)

#1.1 Install the needed applications. 
#1.2 If the applications are already installed, don’t install them again. 
function InstallApplications()
{
	applications=("curl" "ssh" "sshpass", "nmap", "whois", "geoip-bin")

	for app in "${applications[@]}"; do
		if command -v "$app" &> /dev/null; then
			echo "$app is already installed."
		else
			echo "$app is not installed. Installing now..."
			sudo apt install -y "$app"
		fi
	done
}

#1.3 Check if the network connection is anonymous; if not, alert the user and exit. 
#1.4 If the network connection is anonymous, display the spoofed country name. 
function CheckNetwork()
{
	Country=$(whois $IP | grep -i country)
	if [ "$Country" ]
	then 
		echo "You are not anonymous !"
	else 
		echo "You are anonymous - spoofed country: $(geoiplookup $IP | awk '{print $5}')"
	fi
}

function RemoteAccess()
{
	echo "::::Make Connection to SSH::::"
	read -p "=> Enter username: " USERNAME
	read -p "=> Enter remote IP: " REMOTEIP
	read -p "=> Enter password: " PASSWORD
	sshpass -p "$PASSWORD" ssh $USERNAME@$REMOTEIP
}

#1.5 Allow the user to specify the address to scan via remote server; save into a variable. 
#2.1 Display the details of the remote server (country, IP, and Uptime). 
#2.2 Get the remote server to check the Whois of the given address. 
#2.3 Get the remote server to scan for open ports on the given address. 
function Scan()
{
	echo "::::Start to Scan any Domain::::"
	read -p "[*] Enter a domain to scan : " DMN
	Log
	scan_ip=$(dig +short $DMN)
	country=$(geoiplookup $DMN | awk '{print $5}')
	whois $DMN >> nr.log
	nmap -F $DMN >> nr.log
}

#3.1 Save the Whois and Nmap data into files on the local computer. 
#3.2 Create a log and audit your data collecting. 
function Log()
{
	echo "$(date) - inspecting $DMN " > nr.log
}	

InstallApplications
CheckNetwork
RemoteAccess
Scan
