#!/bin/bash
distro=${1:-"generic"}
echo -n "$distro">/home/pi/printer/build
sudo cp -rf /home/pi/printer/distro/"$distro"/req/* /home/pi/printer/
sudo cp -rn /home/pi/printer/distro/"$distro"/opt/* /home/pi/printer/
