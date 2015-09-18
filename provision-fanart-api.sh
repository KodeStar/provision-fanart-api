#!/bin/bash          
echo "Provisioning the fanart.tv API"    

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
    *)
            # unknown option
    ;;
esac
done
echo "APIKEY  = ${APIKEY}"
echo "MASTER  = ${MASTER}"
