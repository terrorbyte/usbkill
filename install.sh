#!/bin/sh

CONFIG="/etc/usbkill/usbkill_config"
UDEV_RULE="/etc/udev/rules.d/10-usbkill.rules"
UDEV_TEMPLATE="/usr/share/usbkill/10-usbkill.rules"
LAUNCHD_RULE=""
LAUNCHD_TEMPLATE=""

if [ "$(id -u)" != "0" ]; then
  echo "Installer must be run as root" 1>&2
  exit 1
fi

mkdir -p $(dirname $CONFIG) $(dirname $UDEV_TEMPLATE)
cp usbkill_config $CONFIG
cp templates/10-usbkill.rules $UDEV_TEMPLATE
cp usbkill.sh /usr/bin/usbkill
cp templates/shutdown.sh /etc/usbkill/shutdown.sh
chmod o+x /usr/bin/usbkill
chmod u+x /etc/usbkill/shutdown.sh
./usbkill.sh -g $CONFIG
