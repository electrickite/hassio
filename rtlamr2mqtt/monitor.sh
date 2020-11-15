#!/bin/sh
export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

if [ -d /usr/local/lib64 ]; then
  export LD_LIBRARY_PATH=/usr/local/lib64
fi

CONFIG_PATH=/data/options.json
MQTT_HOST="$(jq --raw-output '.mqtt_host' $CONFIG_PATH)"
MQTT_USER="$(jq --raw-output '.mqtt_user' $CONFIG_PATH)"
MQTT_PASS="$(jq --raw-output '.mqtt_password' $CONFIG_PATH)"
MSGTYPE="$(jq --raw-output '.msgType' $CONFIG_PATH)"
DEVICE_IDS="$(jq --raw-output '.ids' $CONFIG_PATH)"
DURATION="$(jq --raw-output '.duration' $CONFIG_PATH)"
INTERVAL="$(jq --raw-output '.interval' $CONFIG_PATH)"
ENABLE_LOG="$(jq --raw-output '.log' $CONFIG_PATH)"

# Start the listener and enter an endless loop
echo "Starting RTLAMR with parameters:"
echo "MQTT Host =" $MQTT_HOST
echo "MQTT User =" $MQTT_USER
echo "MQTT Password =" $MQTT_PASS
echo "Message Type =" $MQTT_MSGTYPE
echo "Device IDs =" $DEVICE_IDS
echo "Duration =" $DURATION
echo "Interval =" $INTERVAL
echo "Enable Log =" $ENABLE_LOG

if [ "$ENABLE_LOG" != true ]; then
  quiet_arg="--quiet"
  ENABLE_LOG=""
fi

[ -n "$DEVICE_IDS" ] && filter_arg="-filterid=$DEVICE_IDS"
[ -n "$DURATION" ] && [ $DURATION != "0" ] && duration_arg="-duration=$DURATIONs"
[ -z "$INTERVAL" ] && INTERVAL=60

/usr/local/bin/rtl_tcp &>/dev/null &

# Sleep to fill buffer a bit
sleep 15

LASTVAL="0"

# Do this loop, so will restart if buffer runs out
while true; do 

/go/bin/rtlamr -format json -msgtype="$MSGTYPE" $filter_arg $duration_arg | while read line

do
  VAL="$(echo $line | jq --raw-output '.Message.Consumption' | tr -s ' ' '_')" # replace ' ' with '_'
  DEVICEID="$(echo $line | jq --raw-output '.Message.ID' | tr -s ' ' '_')"
  MQTT_PATH="readings/$DEVICEID/meter_reading"

  [ -n "$ENABLE_LOG" ] && echo $line
  if [ "$VAL" != "$LASTVAL" ]; then
    echo $VAL | /usr/bin/mosquitto_pub $quiet_arg -h "$MQTT_HOST" -u "$MQTT_USER" -P "$MQTT_PASS" -i RTLAMR -r -l -t "$MQTT_PATH"
    LASTVAL=$VAL
  fi
done

sleep $INTERVAL

done
