#!/usr/bin/with-contenv bashio
export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"
LOG_DIR=/share/rtlamr2mqtt
LOG_PATH=$LOG_DIR/output.log
SSL_PATH=/ssl

if [ -d /usr/local/lib64 ]; then
  export LD_LIBRARY_PATH=/usr/local/lib64
fi

CONFIG_PATH=/data/options.json
MQTT_HOST="$(bashio::config 'mqtt_host')"
MQTT_PORT="$(bashio::config 'mqtt_port')"
MQTT_CACERT="$(bashio::config 'mqtt_cacert')"
MQTT_USER="$(bashio::config 'mqtt_user')"
MQTT_PASS="$(bashio::config 'mqtt_password')"
MSGTYPE="$(bashio::config 'msgType')"
DEVICE_IDS="$(bashio::config 'ids')"
SINGLE="$(bashio::config 'single')"
DURATION="$(bashio::config 'duration')"
INTERVAL="$(bashio::config 'interval')"
ENABLE_LOG="$(bashio::config 'log')"
LOG_FILE="$(bashio::config 'log_file')"

filter_arg=""
duration_arg=""
quiet_arg=""
cafile_arg=""

[ -n "$MQTT_CACERT" ] && cafile_arg="--cafile ${SSL_PATH}/${MQTT_CACERT}"
[ -n "$DEVICE_IDS" ] && filter_arg="-filterid=$DEVICE_IDS"
[ "$SINGLE" != true ] && SINGLE=false
[ -n "$DURATION" ] && [ "$DURATION" != "0" ] && duration_arg="-duration=${DURATION}s"
[ -z "$INTERVAL" ] && INTERVAL=60

if [ "$ENABLE_LOG" = true ]; then
  if [ "$LOG_FILE" = true ]; then
    mkdir -p $LOG_DIR
    exec >> $LOG_PATH
    exec 2>&1
  fi
else
  quiet_arg="--quiet"
  ENABLE_LOG=""
fi

# Start the listener and enter an endless loop
date
echo "Starting RTLAMR with parameters:"
echo "MQTT Host =" $MQTT_HOST
echo "MQTT Port =" $MQTT_PORT
echo "MQTT CA Cert =" $MQTT_CACERT
echo "MQTT User =" $MQTT_USER
echo "MQTT Password =" $MQTT_PASS
echo "Message Type =" $MSGTYPE
echo "Device IDs =" $DEVICE_IDS
echo "Single reading =" $SINGLE
echo "Duration =" $DURATION
echo "Interval =" $INTERVAL
echo "Enable Log =" $ENABLE_LOG
echo "Log to file =" $LOG_FILE

/usr/local/bin/rtl_tcp &>/dev/null &

# Disable exit on error for monitor loop
set +e

# Sleep to fill buffer a bit
sleep 15

LASTVAL="0"

# Do this loop, so will restart if buffer runs out
while true; do 

/go/bin/rtlamr -format json -msgtype="$MSGTYPE" $filter_arg $duration_arg -single="$SINGLE" | while read line

do
  VAL="$(echo $line | jq --raw-output '.Message.Consumption' | tr -s ' ' '_')" # replace ' ' with '_'
  DEVICEID="$(echo $line | jq --raw-output '.Message.ID' | tr -s ' ' '_')"
  MQTT_PATH="readings/$DEVICEID/meter_reading"

  [ -n "$ENABLE_LOG" ] && echo $line
  if [ "$VAL" != "$LASTVAL" ]; then
    echo $VAL | /usr/bin/mosquitto_pub $quiet_arg -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" $cafile_arg -i RTLAMR -r -l -t "$MQTT_PATH"
    LASTVAL=$VAL
  fi
done

sleep $INTERVAL

done
