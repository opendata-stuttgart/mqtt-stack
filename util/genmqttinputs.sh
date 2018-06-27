#!/bin/bash

val=0

deviceid=$((RANDOM%10000))
server=localhost
port=1883
topic="test/genmqttinput-$deviceid/intval"
usesensors="false"
mopts=""

usage(){
	echo "mopts=\"[mosquitto_sub-options]\" $0 [-h] [-v <verbose>] [-s server $server] [-p port $port] [[-d deviceid ] | [-t topic $topic]] [-l <publish local sensors values>]"
}


while getopts 'vhls:d:p:t:' OPTION ; do
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
		echo "host=$server"
                ;;
        p)
		port="$OPTARG"
		echo "port=$port"
                ;;
        t)
		topic="$OPTARG"
		echo "topic=$topic"
                ;;
	l)	if [ -n "$(which sensors)" ] ; then
			usesensors="true"
			echo "using sensors output"
		else
			echo "sensors not found, lm-sensors installed and usable?"
		fi
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

initretain="true"
if [ "$usesensors" == "true" ] ; then
	sensors -u -A| awk -v topicroot="$topic/$(hostname)/sensors" -F ':' '/^[^ ]/{if(NR-prevnr>1){stype=""};stype=stype"/"$0; gsub(" ","",stype);prevnr=NR}/^ /{print topicroot stype"/"gensub(" ","","g",$1) " " $2}'| while read topic val
        do
		# retain messages: -r
                mosquitto_pub $mopts -r -h "$server" -p "$port" -t "$topic" -m "$val"
        done
fi
while true
do 
	val=$((val+$RANDOM%11-5)) 
	if [ "$usesensors" == "true" ] ; then
		sensors -u -A| awk -v topicroot="$topic/$(hostname)/sensors" -F ':' '/^[^ ]/{if(NR-prevnr>1){stype=""};stype=stype"/"$0; gsub(" ","",stype);prevnr=NR}/input/{print topicroot stype"/"gensub(" ","","g",$1) " " $2}'| while read topic val
		do
			mosquitto_pub $mopts -h "$server" -p "$port" -t "$topic" -m "$val"
		done 
	fi		

	mosquitto_pub $mopts -h "$server" -p "$port" -t "$topic" -m "$val"
	sleep 1
done
