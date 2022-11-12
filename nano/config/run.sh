#!/bin/bash
touch /var/log/printer.log
chmod 644 /var/log/printer.log
/usr/local/bin/pigpiod -s 10
sleep 5
clear
setterm -cursor off
(cd /home/pi/printer;./printer >> /var/log/printer.log 2>&1)
exit 0