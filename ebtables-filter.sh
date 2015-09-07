#!/bin/sh

### USE IT ONLY ONCE!
### USE ebtables-save and ebtables-restore! (See LJ artile for details)

# Bridge interface to add rules for. Typically br0
IFACE=br0

# Networks to block: private addresses
# as defined in RFC 1918
BLK_ADDR="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"

# Private networks to NOT block
UNBLK_ADDR="192.168.2.0/24"

# First - adding exceptions
for addr in $UNBLK_ADDR; do
  ebtables -A OUTPUT -p IPv4 \
    --ip-destination $addr  -j ACCEPT
  ebtables -A FORWARD -i $IFACE -p IPv4 \
    --ip-destination $addr  -j ACCEPT
  ebtables -A OUTPUT -p IPv4 \
    --ip-source $addr -j ACCEPT
  ebtables -A FORWARD -i $IFACE -p IPv4 \
    --ip-source $addr -j ACCEPT
done

# Second - adding blocked networks
for addr in $BLK_ADDR; do
  # Log leaks
  ebtables -A OUTPUT  -p IPv4 \
    --ip-destination $addr --log-level info \
    --log-ip --log-prefix "EBTABLES-BLKO"
  ebtables -A FORWARD -i $IFACE -p IPv4 \
    --ip-destination $addr --log-level info \
    --log-ip --log-prefix "EBTABLES-BLKF"
  ebtables -A OUTPUT  -p IPv4 \
    --ip-source $addr --log-level info \
    --log-ip --log-prefix "EBTABLES-BLKO"
  ebtables -A FORWARD -i $IFACE -p IPv4 \
    --ip-source $addr  --log-level info  \
    --log-ip --log-prefix "EBTABLES-BLKF"

 # Drop leaks
 ebtables -A OUTPUT -p IPv4 \
   --ip-destination $addr  -j DROP
 ebtables -A FORWARD -i $IFACE -p IPv4 \
   --ip-destination $addr  -j DROP
 ebtables -A OUTPUT -p IPv4 \
   --ip-source $addr -j DROP
 ebtables -A FORWARD -i $IFACE -p IPv4 \
   --ip-source $addr -j DROP
done

