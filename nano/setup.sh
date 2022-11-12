#!/bin/bash
function add_config(){
	echo
	echo
	echo
	if grep -q "$1" $2; then
		echo ''
	else
		echo "$1" >> $2
	fi
}
function display_msg(){
	echo
	echo
	echo
	echo "$1"
}

display_msg "Installing necessary libraries for Raspian Stretch and auto mounting USB"
sudo apt-get install usbmount libpng12-0

display_msg "Setting up logrotate"
sudo cp config/printer.rotate /etc/logrotate.d/printer
sudo cp /etc/cron.daily/logrotate /etc/cron.hourly/

display_msg "Setting up PWM driver"
sudo killall pigpiod
sudo cp /home/pi/printer/install/pigpiod /usr/local/bin/
sudo cp /home/pi/printer/install/*.so /usr/local/lib/

display_msg "Enabling SSH"
sudo touch /boot/ssh

if [ ! -f /boot/nanodlp-dhcp.txt ]; then
	display_msg "Preparing nanodlp-dhcp.txt file"
	sudo cp -rn /etc/dhcpcd.conf /boot/nanodlp-dhcp.txt
	sudo rm /etc/dhcpcd.conf
	sudo ln -s -f /boot/nanodlp-dhcp.txt /etc/dhcpcd.conf
fi

if [ ! -f /boot/nanodlp-wifi.txt ]; then
	display_msg "Preparing nanodlp-wifi.txt file"
	sudo cp -rn config/nanodlp-wifi.txt /boot/
	sudo rm /etc/wpa_supplicant/wpa_supplicant.conf
	sudo ln -s -f /boot/nanodlp-wifi.txt /etc/wpa_supplicant/wpa_supplicant.conf
fi

display_msg "To make your Raspberry Pi IP static use nanodlp-dhcp.txt file."
echo "To setup wifi network you can use NanoDLP itself but you can also use nanodlp-wifi.txt file."
echo "After installation completed, put your microSD card into your computer and edit text files."

display_msg "Updating distribution files, ignore possible errors"
distro=${1:-"generic"}
echo -n "$distro">/home/pi/printer/build
sudo cp -rf /home/pi/printer/distro/"$distro"/req/* /home/pi/printer/ 2>/dev/null
sudo cp -rn /home/pi/printer/distro/"$distro"/opt/* /home/pi/printer/ 2>/dev/null
sudo ldconfig

read -r -p "Do you want to optimize Raspberry Pi settings for nanoDLP automatically? [Y/n] " response
if [[ $response =~ ^(|[yY])$ ]]
then
	# Enable basic configs
	add_config 'disable_camera_led=1' '/boot/config.txt'
	add_config 'hdmi_pixel_encoding=2' '/boot/config.txt'
	add_config 'start_x=1' '/boot/config.txt'
	add_config 'gpu_mem=128' '/boot/config.txt'
fi

read -r -p "Do you see black border around display output? (disable overscan) [Y/n] " response
if [[ $response =~ ^(|[yY])$ ]]
then
	add_config 'disable_overscan= 1' '/boot/config.txt'
fi

read -r -p "Do you want to enable i2c to enable communication with LCD and other hardware with i2c connectivity? [Y/n] " response
if [[ $response =~ ^(|[yY])$ ]]
then
	# Enable I2C on Raspberry Pi
	add_config 'i2c-bcm2708' '/etc/modules'
	add_config 'i2c-dev' '/etc/modules'
	add_config 'dtparam=i2c1=on' '/boot/config.txt'
	add_config 'dtparam=i2c_arm=on' '/boot/config.txt'
	if [ -f /etc/modprobe.d/raspi-blacklist.conf ]; then
		sed -i 's/^blacklist spi-bcm2708/#blacklist spi-bcm2708/' /etc/modprobe.d/raspi-blacklist.conf
		sed -i 's/^blacklist i2c-bcm2708/#blacklist i2c-bcm2708/' /etc/modprobe.d/raspi-blacklist.conf
	else
		echo ''
	fi
fi

sudo cp config/nanodlp.service /etc/systemd/system/
sudo systemctl enable nanodlp

display_msg "You can access your RPi through your favorite browser by IP address below"
hostname -I

read -r -p "Do you want to update raspberry firmware? (It required for new Raspbian) [Y/n] " response
	if [[ $response =~ ^(|[yY])$ ]]
then
	sudo rpi-update
fi

read -r -p "To expand file system, enable SSH server and camera module you need to use raspi-config. Do you want to use it now? [Y/n] " response
if [[ $response =~ ^(|[yY])$ ]]
then
	sudo raspi-config
fi

display_msg "Restarting your Raspberry Pi"
sudo reboot
