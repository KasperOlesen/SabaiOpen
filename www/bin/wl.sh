#!/bin/ash
# Sabai Technology - Apache v2 licence
# copyright 2014 Sabai Technology

#input parameters
action="$1"
device="$2"

# checking action
if [ "$action" = "save" ] || [ "$action" = "start" ] ; then
	config_file=sabai
else
	config_file=sabai-new
fi

# parsing common configs of devices
mode=$(uci get $config_file.$device.mode)
ssid=$(uci get $config_file.$device.ssid)
wpa_psk=$(uci get $config_file.$device.wpa_psk)
encryption=$(uci get $config_file.$device.encryption)
channel_freq=$(uci get $config_file.$device.channel_freq)

# parsing specific configs of main wl
if [ "$device" = "wlradio0" ]; then
	wpa_rekey=$(uci get $config_file.$device.wpa_rekey)
	auto=$(uci get $config_file.$device.auto)
	if [ "$auto" = "off" ]; then
		uci set wireless.radio0.channel="$channel_freq"
		uci commit wireless
	else
		uci set wireless.radio0.channel="auto"
	fi
fi

uci set wireless.radio0.country='US'




wifi down

if [ "$mode" = "off" ]; then
		uci set wireless.radio0.disabled=1
		uci delete wireless.@wifi-iface[0].mode
	else
		uci set wireless.radio0.disabled=0
		uci set wireless.@wifi-iface[0].mode="$(uci get $config_file.wlradio0.mode)";
	fi

uci set wireless.@wifi-iface[0].ssid="$(uci get $config_file.wlradio0.ssid)";
uci set wireless.@wifi-iface[0].encryption="$(uci get $config_file.wlradio0.encryption)";

_wep(){
	wepkeys="$(uci get $config_file.wlradio0.wepkeys)";
	uci set wireless.@wifi-iface[0].key1=$(echo $wepkeys |awk -F: '{print $0}' | awk '{print $1}')
	uci set wireless.@wifi-iface[0].key2=$(echo $wepkeys |awk -F: '{print $0}' | awk '{print $2}')
	uci set wireless.@wifi-iface[0].key3=$(echo $wepkeys |awk -F: '{print $0}' | awk '{print $3}')
	uci set wireless.@wifi-iface[0].key4=$(echo $wepkeys |awk -F: '{print $0}' | awk '{print $4}')
	uci set wireless.@wifi-iface[0].key=4
	uci commit wireless;
}

_psk(){
	wpa_encryption=$(uci get $config_file.wlradio0.wpa_encryption)
	full_encryption=$(echo "$encryption+$wpa_encryption") 
	uci set wireless.@wifi-iface[0].encryption=$full_encryption
	uci set wireless.@wifi-iface[0].key=$(uci get $config_file.wlradio0.wpa_psk)
	uci set wireless.@wifi-iface[0].key1=''
	uci set wireless.@wifi-iface[0].key2=''
	uci set wireless.@wifi-iface[0].key3=''
	uci set wireless.@wifi-iface[0].key4=''
	uci commit wireless
}

ls >/dev/null 2>/dev/null 

case $encryption in
	none)	break;	;;
	wep)	_wep	;;
	psk)	_psk	;;
	psk2)	_psk	;;
	mixed-psk)	_psk	;;
esac

if [ $action = "update" ]; then
	echo "network" >> /tmp/.restart_services
else
	wifi up
fi
logger "wireless script run and wifi restarted"
