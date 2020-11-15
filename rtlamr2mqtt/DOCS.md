# rtlamr2mqtt Add-on

Utilities often use "smart meters" to optimize their residential meter reading
infrastructure. Smart meters transmit consumption information in the various
ISM bands allowing utilities to simply send readers driving through
neighborhoods to collect commodity consumption information. One protocol in
particular: Encoder Receiver Transmitter by Itron is fairly straight forward to
decode and operates in the 900MHz ISM band, well within the tunable range of
inexpensive rtl-sdr dongles.

This add-on includes a software defined radio receiver for these messages. We
make use of an inexpensive rtl-sdr dongle to allow users to non-invasively
record and analyze the commodity consumption of their household.

## Installation

The installation of this add-on is straightforward assuming the repository has
been installed:

1. Search for the “rtlamr2mqtt” add-on in the Supervisor add-on store
   and install it.
2. Install the "rtlamr2mqtt" add-on.
3. Start the "rtlamr2mqtt" add-on
4. Check the logs of the "rtlamr2mqtt" add-on to see if everything went well.

After ~30 seconds you should see messages appear in the add-on log and MQTT bus.

## Customization

If customizations to the RTLAMR monitor script are needed, copy monitor.sh to
`/config/rtlamr2mqtt` (i.e. `.../config/rtlamr2mqtt/monitor.sh`)
This allows you to edit the start script if you need to make any changes.

If this is using too much CPU, configure the duration setting with the number of
seconds of a single rtlamr run. You can also increase the cycle interval to
however many seconds you want to wait until scanning again. For example, 60s of
processing, then 5 mintutes (300s) of sleeping.

## MQTT Data

Data to the MQTT server is in the format: `readings/$DEVICEID/meter_reading`

## Configuration

**Note**: _Remember to restart the add-on when the configuration is changed._

Example add-on configuration:

```yaml
mqtt_host: "hassio.local"
mqtt_user: "myuser"
mqtt_password: "mypass"
msgType: "scm"
ids: "1234,1235"
duration: 0
interval: 60
log: false
log_file: false
```

**Note**: _This is just an example, don't copy and past it! Create your own!_

### Option: `mqtt_host`

Hostname of MQTT server.

### Option: `mqtt_user`

MQTT username, if needed.

### Option: `mqtt_password`

MQTT password, if needed.

### Option: `msgType`

The AMR message type to scan for. See the [RTLAMR Documentation](https://github.com/bemasher/rtlamr#message-types)
for details.

### Option: `ids`

Comma separated list of meter ID numbers to record. An empty string will
record all meters detected.

### Option: `duration`

Number of seconds to run single rtlamr scan. Set to 0 for continuous.

### Option: `interval`

Number of seconds to pause between rtlamr scans.

### Option: `log`

Set to `true` to enable logging of rtlamr output.

### Option: `log_file`

If `log` is true, setting `log_file` to true will redirect log output to
`/share/rtlamr2mqtt/output.log`

## Hardware

This has been tested and used with the following hardware (you can get it on Amazon)

- NooElec NESDR Nano 2+ Tiny Black RTL-SDR USB
- RTL-SDR Blog R820T2 RTL2832U 1PPM TCXO SMA Software Defined Radio

## Troubleshooting

If you see this error:

> Kernel driver is active, or device is claimed by second instance of librtlsdr.
> In the first case, please either detach or blacklist the kernel module
> (dvb_usb_rtl28xxu), or enable automatic detaching at compile time.

Then run the following command on the host

```bash
sudo rmmod dvb_usb_rtl28xxu rtl2832
```

