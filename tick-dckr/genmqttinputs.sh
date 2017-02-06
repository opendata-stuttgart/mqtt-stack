#!/bin/bash

val=0

deviceid=$((RANDOM%10000))
server=localhost
port=1883
topic="test/genmqttinput-$deviceid/intval"
mopts=""

usage(){
	echo "mopts=\"[mosquitto_sub-options]\" $0 [-h] [-v verbose] [-s server $server] [-p port $port] [[-d deviceid ] | [-t topic $topic]]"
}

while getopts 'vhd:s:p:t:' OPTION ; do
        case $OPTION in
        v)      verbose="y"
		mopts="$mopts -d"
                ;;
        d)
		deviceid="$OPTARG"
		topic="test/genmqttinput-$deviceid/intval"
		echo "deviceid=$deviceid topic=$topic"
                ;;
        s)
		server="$OPTARG"
		echo "server=$server"
                ;;
        p)
		port="$OPTARG"
		echo "port=$port"
                ;;
        t)
		topic="$OPTARG"
		echo "topic=$topic"
                ;;
        h)        usage $EXIT_SUCCESS
                ;;
        \?)        echo "Unknown option \"-$OPTARG\"." >&2
                usage $EXIT_ERROR
                ;;
        :)        echo "Option \"-$OPTARG\" needs an argument!" >&2
                usage $EXIT_ERROR
                ;;
        *)        echo "Argument parsing failed (this is a bug)..."
>&2
                usage $EXIT_BUG
                ;;
        esac
done

usage

while true
do 
	val=$((val+$RANDOM%11-5)) 
	mosquitto_pub $mopts -h "$server" -p "$port" -t "$topic" -m "$val"
	sleep 1
done
