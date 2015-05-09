#!/bin/sh
#Call usbkill to disable it at start. Should change this in whitelist mode
/usr/bin/usbkill
/usr/bin/shutdown 0
