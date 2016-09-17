#!/bin/bash

deviceid=$((RANDOM%10000))
val=0
while true
do 
	val=$((val+$RANDOM%11-5)) 
	mosquitto_pub -h localhost -p 11883 -t "test/genmqttinput-$deviceid/DHT22/temperature" -m "$val"
	sleep 1
done
