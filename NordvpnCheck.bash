#!/bin/bash
#settings() {
#	timeout 5s nordvpn s technology openvpn
#	timeout 5s nordvpn s protocol udp
#	timeout 5s nordvpn s killswitch on
#	timeout 5s nordvpn s cybersec on
#	timeout 5s nordvpn s obfuscate off
#	timeout 5s nordvpn s notify on
#	timeout 5s nordvpn s autoconnect on
#	timeout 5s nordvpn s dns off
#}

#set your static ip & service
ips = xx.xx.xx.xxx
servicename = some.service

reconnect() {
	timeout 5s nordvpn d	
	timeout 10s nordvpn c us
}

restartvpnservices() {
	systemctl restart nordvpn.service | systemctl restart nordvpnd.service
}

check() {
	timeout 20s bash -c 'nordvpn status | grep -q "Status: Connected"'
}


checkip1(){
	timeout 10s bash -c 'curl ifconfig.me | grep -q $ips'
}
checkip2(){
	timeout 10s bash -c 'curl ipinfo.io/ip | grep -q $ips'
}

# Connection check.
echo "$(date) [Checking VPN connectivity]"
if ! check; then
	systemctl stop $servicename
	echo "Stoped " $servicename
	echo "$(date) [Check failed, trying again in 3s]"
	sleep 10	
	reconnect
	if ! check; then
		echo "$(date) [Reconnect failed, trying again in 3s]"
		sleep 10
		reconnect
		if ! check; then
			echo "$(date) [Second reconnect failed, restarting NordVPN (30s)"
			restartvpnservices
			sleep 30
			#settings
			reconnect
			echo "$(date) [Checking VPN connectivity]"
			if ! check; then
				echo "$(date) [Check failed, trying again in 3s]"
				sleep 10
				reconnect
				if ! check; then
					echo "$(date) [Check failed again, starting VPN]"
					reconnect
					if ! check; then
						echo "$(date) [Reconnect failed, trying again in 3s]"
						sleep 10
						restartvpnservices
						sleep 20
						reconnect
						if ! check; then
							echo "$(date) [Second reconnect failed, restart the system to regain connection with the VPN service]"
							sleep 99999999999999999999999999999999
						fi
					fi
				fi
			fi
		fi
	fi
fi

# Check if Ip if public
if  checkip1; then
	echo "$(date) [Ip check failed, restarting NordVPN (30s)]"
	systemctl stop $servicename
	echo "Stoped " $servicename
	reconnect
	sleep 30
	settings
	if  checkip2; then
		systemctl stop $servicename
		echo "Stoped " $servicename
		echo "$(date) [Ip2 check failed, restart the system to regain connection with the VPN service]"
		sleep 99999999999999999999999999999999
	fi
fi

#Chechk if some service is running
if  ! systemctl is-active $servicename;then
	echo $servicename " innactive"
	systemctl start $servicename
	echo "Started " $servicename
fi
	
sleep 5