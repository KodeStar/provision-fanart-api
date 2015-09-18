#!/bin/bash          
MASTER=NO
for i in "$@"
do
case $i in
    -a=*|--apikey=*)
    APIKEY="${i#*=}"
    shift # past argument=value
    ;;
    -m|--master)
    MASTER=YES
    shift # past argument with no value
    ;;
    -h|--help)
    echo "./provision-fanart-api"
    echo "  -a | --apikey # Mandatory"
    echo "  -i | --ip # Optional - required if you want to set a failover ip for the docker insrtead on the hosts external ip"
    echo "  -s | --serverip # Optional / Mandatory if --ip is set, hosts external ip"
    echo "  -g | --gateway # Optional / Mandatory if --ip is set, gateway to use - on ovh this is the main ip with the last octet as 254 on online.net last octet should be 1"
    exit
    ;;
    *)
            # unknown option
    ;;
esac
done

echo "Provisioning the fanart.tv API"    
echo "APIKEY  = ${APIKEY}"

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
fi

