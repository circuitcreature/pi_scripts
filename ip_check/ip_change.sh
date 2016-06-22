#!/bin/bash
ip_runner(){
if [ ! -v ${mem_ip} ]; then
	cache="/home/pi/boot_scripts/ips.cache"
	touch $cache
	. $cache
	mem_ip=${old_ip}
	mem_public_ip=${old_public}
	export mem_ip
	export mem_public_ip
fi

let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
let secs=$((${upSeconds}%60))
let mins=$((${upSeconds}/60%60))
let hours=$((${upSeconds}/3600%24))
let days=$((${upSeconds}/86400))
UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`

from=raspberrypi
to=yourmail@gmail.com

TIMEOUT=0
while [ -z $(/sbin/ip route | awk '/default/ { print $3 }') ]
do
  if [ $TIMEOUT -gt 45 ]
  then
	echo `date`"-> ERROR, no IP found after 90 seconds." >> $DIR"cetra_script_debug"
	exit 0
  fi
  TIMEOUT=$((TIMEOUT+1))
  sleep 2s
done

#@PI how would you get to 8.8.8.8
PI=`/sbin/ip route get 8.8.8.8 | awk 'NR==1 {print $3,$NF;}'`
IFS=' ' read -a IPS <<< "$PI"
public=`wget -q -O - http://icanhazip.com/ | tail`
send_email=false

if [ -z ${old_ip} ]; then
	send_email=true
	echo 1
else
	 if [ "$old_ip" != "${IPS[1]}" ]; then
	 	send_email=true
		echo 2
	fi
fi
if [ -z ${old_public} ]; then
	send_email=true
	echo 3
else
	 if [ "$old_public" != "$public" ]; then
	 	send_email=true
		echo 4
	fi
fi

if ! $send_email ; then
	exit 1
fi

>${cache}
printf 'old_ip=%s\nold_public=%s\n' ${IPS[1]} ${public} >> ${cache}

function err_exit { echo -e 1>&2; exit 1; }
function mail {
echo "ehlo $(hostname -f)"
echo "MAIL FROM: <$from>"
echo "RCPT TO: <$to>"
echo "DATA"
echo "From: <$from>"
echo "To: <$to>"
echo "Subject: Ip change ${IPS[1]}, ${public}"
echo "Uptime: "${UPTIME}
echo "Public IP: ${public}"
echo "MAC `cat /sys/class/net/eth0/address`"
echo "IP: ${IPS[1]}"
echo "Gateway: ${IPS[0]}"
echo "."
echo "quit"
}
mail | nc localhost 25 || err_exit
exit 1
}
ip_runner &
