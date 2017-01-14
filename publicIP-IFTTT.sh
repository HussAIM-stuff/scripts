#!/usr/bin/env bash

#STATIC_VARIABLES

#filename, file storing old publicIP
filename=oldPublicIP #REPLACE name of file to store old Ips

#server VPN
server="78.136.126.227" #REPLACE server name if needed

#remitent of the webRequest, to know of whom is the public ip
remitent='rpi' #REPLACE with remitent, if you are using more than one device in same sheet

#IFTTT secret key
secret_key="b3wtM_LanB0sOIjVy_vMki" #REPLACE with your key

#END_STATIC_VARIABLES

# Check internet connection checking if google DNS is listening
nc -z 8.8.8.8 53 >/dev/null 2>&1 ;
if ! [ $? -eq 0 ]
then
  echo "Error: check your internet connection"
  exit 1
fi

#get publicIP and store it in $pubip, and exit  after if $pubip is empty, (curl -s option means silent)
pubip=`curl -s http://ipecho.net/plain`
[ -z $pubip ] &&  echo "Error: could not retreive public IP" && exit 1
echo "publicIP: $pubip";

# exit if public IP is the same as our VPN server
# means we are already connected to our VPN and $pubip is not our real IP
[ "$server" == "$pubip" ] && echo "public ip is the same as server: $pubip" && exit 1

# if $filename exist, save the ip in $oldip
[ -f $filename ] && oldip=$(< $filename)  

# exit if the ip in $filename is the same as the public IP
# means our ip didn't change since last time
[ ! -z $oldip ] && [ "$oldip" == "$pubip" ] && echo "publicIP is equal to $filename: $pubip" && exit 1
# last 2 steps could be done in 1 step: [ -f $filename ] && [ "$(< $filename)" == "$pubip" ] && exit 1

# Send to IFTTT, in my case I used an event that adds the data in a new row on google sheets
value1=$remitent
value2=$pubip
json="{\"value1\":\"${value1}\",\"value2\":\"${value2}\"}"
curl -X POST -H "Content-Type: application/json" -d "${json}" https://maker.ifttt.com/trigger/publicIP/with/key/${secret_key}  

#after sending the ip, store it in $filename
echo $pubip > $filename
echo
