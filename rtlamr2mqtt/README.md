# rtlamr2mqtt Add-on

A hass.io add-on for a software defined radio tuned to listen for utility
meter RF transmissions and republish the data via MQTT.

## About

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

