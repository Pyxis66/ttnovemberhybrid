#!/bin/bash
wget $1 --no-check-certificate -O - | tar -C /home/pi -xz
distro=${2:-"generic"}
sudo cp -rf /home/pi/printer/distro/"$distro"/req/* /home/pi/printer/ 2>/dev/null
sudo cp -rn /home/pi/printer/distro/"$distro"/opt/* /home/pi/printer/ 2>/dev/null
