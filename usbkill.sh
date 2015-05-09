#!/bin/sh

CONFIG="/etc/usbkill/usbkill_config"
UDEV_RULE="/etc/udev/rules.d/10-usbkill.rules"
UDEV_TEMPLATE="/usr/share/usbkill/10-usbkill.rules"
LAUNCHD_RULE=""
LAUNCHD_TEMPLATE=""

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

usage() {
  cat << EOF
Usage: ${0##*/} [-g [CONFIG]]
EOF
}

while :; do
  case $1 in
    -h|-\?|--help)
      usage
      exit 1
      ;;
    -g)
      if [ -n "$2" ]; then
        echo "Generating from $2"
        GENERATE=$2
        shift 2
        continue
      else
        if [ -f "$CONFIG" ]; then
          echo "Generating from $CONFIG"
          GENERATE="$CONFIG"
        else
          echo "-g option requires a config file to generate from or the \
$CONFIG to exist" 1>&2
          exit 2
        fi
      fi
      ;;
    --)
      shift
      break
      ;;
    -?)
      echo "Unknown option:" 1>&2
      usage
      exit 4
      ;;
    *)
      break
  esac
  shift
done

udev_main(){
  if [ -f "$UDEV_RULE" ]; then
    rm $UDEV_RULE
  else
    GENERATE="$CONFIG"
    udev_generate
  fi
}

udev_generate(){
  source "$GENERATE"
  if [ $? -ne 0 ]; then
    echo "$GENERATE not in correct format" 1>&2
    exit 5
  fi
  if [ "$WHITELIST_SERIAL" != "" ]; then
    WHITELIST_ENABLED=""
  else
    WHITELIST_ENABLED="#"
  fi
  #Use alternative delimeters so as not to mess with / in path
  sed -e "s/\${WHITELIST_SERIAL}/$WHITELIST_SERIAL/" \
    -e "s/\${WHITELIST_ENABLED}/$WHITELIST_ENABLED/" \
    -e "s/\${ACTION}/$ACTION/" \
    -e "s/\${SUBSYSTEMS}/$SUBSYSTEMS/" \
    -e "s/\${DEVTYPE}/$DEVTYPE/" \
    -e "s/\${MATCH_VAL}/$MATCH_VAL/" \
    -e "s/\${MATCH}/$MATCH/" \
    -e "s^\${COMMAND}^$COMMAND^" \
    -e "s^\${ADDITIONAL}^$ADDITIONAL^" \
     $UDEV_TEMPLATE > $UDEV_RULE
  if [ $? -ne 0 ]; then
    echo "Could not substitute properly in template" 1>&2
    exit 6
  fi
}

launchd_main(){
  echo "No support for OSX yet" 1>&2
  exit 2
}

launchd_generate(){
  echo "No support for OSX yet" 1>&2
  exit 2
}

if [ $# -gt 0 ]; then
  usage
  exit 2
fi

if command -v launchctl &> /dev/null; then
  if [ -n "$GENERATE" ]; then
    launchd_generate
  else
    launchd_main
  fi
elif command -v udevadm &> /dev/null; then
  if [ -n "$GENERATE" ]; then
    udev_generate
  else
    udev_main
  fi
  udevadm control --reload-rules
else
  echo "udev or launchctl not found" 1>&2
  exit 3
fi
