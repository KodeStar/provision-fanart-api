#!/bin/bash          
MASTER=NO
HTTPPORT=80
HTTPSPORT=443
NAME=""
IFACE="eth0"
for i in "$@"
do
case $i in
    -a=*|--apikey=*)
    APIKEY="${i#*=}"
    shift # past argument=value
    ;;
    -c=*|--config=*)
    CONFIG="${i#*=}"
    shift # past argument=value
    ;;
    -p=*|--http-port=*)
    HTTPPORT="${i#*=}"
    shift # past argument=value
    ;;
    -t=*|--https-port=*)
    HTTPSPORT="${i#*=}"
    shift # past argument=value
    ;;
    -i=*|--ip=*)
    IP="${i#*=}"
    shift # past argument=value
    ;;
    -f=*|--interface=*)
    IFACE="${i#*=}"
    shift # past argument=value
    ;;
    -n=*|--name=*)
    NAME="${i#*=}"
    CREATENAME="--name=$NAME"
    shift # past argument=value
    ;;
    -s=*|--serverip=*)
    SERVERIP="${i#*=}"
    shift # past argument=value
    ;;
    -m|--master)
    MASTER=YES
    shift # past argument with no value
    ;;
    -h|--help)
    echo "./provision-fanart-api"
    echo "  -a | --apikey # Mandatory"
    echo "  -c | --config # Mandatory config directory location"
    echo "  -p | --http-port # Optional - If you aren't using a failover IP you probably need to use a different port from 80"
    echo "  -t | --https-port # Optional - If you aren't using a failover IP you probably need to use a different port from 443"
    echo "  -i | --ip # Optional - required if you want to set a failover ip for the docker insrtead on the hosts external ip"
    echo "  -s | --serverip # Optional / Mandatory if --ip is set, hosts external ip"
    echo "  -g | --gateway # Optional / Mandatory if --ip is set, gateway to use - on ovh this is the main ip with the last octet as 254 on online.net last octet should be 1"
    echo "  -m | --master # Optional - no value"
    echo "  -n | --name # Optional - Docker container name, if not set a random name will be used"
    echo "  -f | --interface # Optional - interface to use, if not selected eth0 is used"
    echo "  -h | --help # this help page"
    exit
    ;;
    *)
            # unknown option
    ;;
esac
done

if [[ -z ${APIKEY} ]]; then
	echo "API Key required. Aborting"
	exit 1
fi

echo "Provisioning the fanart.tv API"    
echo "APIKEY  = ${APIKEY}"

# Check if curl is installed
command -v curl >/dev/null 2>&1 || { echo >&2 "curl is a requirement, please install before running this script"; exit 1; }

# Check if Docker is installed
command -v docker >/dev/null 2>&1 || {
	echo "Docker not installed, installing now:"
    curl -sSL https://get.docker.com/ | sh
}

if [ ${MASTER} = "YES" ]; then
    echo "Installing Master API"
    # Do stuff
else
     echo "Installing Client API"
     # Do stuff
     docker create $CREATENAME -v $CONFIG:/config -v /etc/localtime:/etc/localtime:ro -p $HTTPPORT:80 -p $HTTPSPORT:443 -e "APIKEY=$APIKEY" linuxserver/fanart.api
     CID=$(docker start $NAME)
fi

if [[ -z $IP ]]; then
	echo "Finished installing"
else
	# This bit doesn't work because I don't know how to do it
	# I need to find what virtual interfaces are available and increment
	# it, but for now I will just hard code it
	VIFACE="virtual0"
	# Update that when I know how to do it

	ip link add $VIFACE link $IFACE type macvlan mode bridge
	ip address add $IP/24 broadcast $GATEWAY dev $VIFACE
	INTIP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' $CID) # Store as $INTIP
	iptables -t nat -A PREROUTING -p all -d $IP -j BRIDGE-$VIFACE
	iptables -t nat -A OUTPUT -p all -d $IP -j BRIDGE-$VIFACE
	iptables -t nat -A BRIDGE-$VIFACE -p all -j DNAT --to-destination $INTIP
	iptables -t nat -I POSTROUTING -p all -s -j SNAT --to-source $IP
	echo 2 > /proc/sys/net/ipv4/conf/$IFACE/rp_filter
	echo 2 > /proc/sys/net/ipv4/conf/$VIFACE/rp_filter	
fi