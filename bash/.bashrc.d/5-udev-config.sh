#!/bin/bash

# if udev is not present on the system, skip this
if [ ! "$(command -v udevadm)" ]; then
  return
fi

# a helper to easily configure udev rules
function udev-config() {
  # 1. Choose Subsystem
  SUBSYSTEM=$(whiptail --title "Subsystem Selection" --menu "Choose the subsystem for the device:" 15 60 4 \
    "tty" "Serial/COM (Arduino/Serial)" \
    "hidraw" "HID Raw (Input devices/Custom HID)" \
    "usb" "USB Device (Generic USB)" 3>&1 1>&2 2>&3)

  if [ -z "$SUBSYSTEM" ]; then return 1; fi

  # 2. Select Device
  # We generate a list where the ID is clearly separated at the start of the line
  # Format: [ID] [Description]
  DEVICE_LIST=$(lsusb | awk '{print $2$4, $6, $7, $8, $9, $10, $11}' | sed 's/://g' | sed 's/ / /g')

  # To get the data properly, we'll use a temporary array to map choices
  mapfile -t devices < <(lsusb)

  # Create an array for whiptail
  menu_options=()
  for i in "${!devices[@]}"; do
    # Extract IDs: lsusb output is like "Bus 001 Device 005: ID 2341:0043"
    # We grab the part after "ID "
    id_pair=$(echo "${devices[$i]}" | grep -oP 'ID \K[0-9a-fA-F]{4}:[0-9a-fA-F]{4}')
    desc=$(echo "${devices[$i]}" | cut -d: -f3-)

    if [ ! -z "$id_pair" ]; then
      menu_options+=("$id_pair" "$desc")
    fi
  done

  CHOICE=$(whiptail --title "USB Device Selector" --menu "Select your device:" 25 100 15 "${menu_options[@]}" 3>&1 1>&2 2>&3)

  if [ -z "$CHOICE" ]; then return 1; fi

  # 3. Parse IDs
  VENDOR_ID=$(echo $CHOICE | cut -d: -f1)
  PRODUCT_ID=$(echo $CHOICE | cut -d: -f2)

  #RULE_FILE="/etc/udev/rules.d/99-custom-usb.rules"
  RULE='SUBSYSTEM=="'$SUBSYSTEM'", ATTRS{idVendor}=="'$VENDOR_ID'", ATTRS{idProduct}=="'$PRODUCT_ID'", MODE="0666"'

  # 4. Check for duplicates and write
  if grep -q "$VENDOR_ID.*$PRODUCT_ID" "$RULE_FILE" 2>/dev/null; then
    whiptail --msgbox "A rule for this device already exists in $RULE_FILE" 10 50
  else
    sudo bash -c "
      RULE_FILE='/etc/udev/rules.d/99-custom-usb.rules'
      echo '$RULE' >> \"\$RULE_FILE\"
      udevadm control --reload-rules
      udevadm trigger
      echo 'Rule added successfully. $RULE'
    "
  fi
}
