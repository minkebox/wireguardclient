#! /bin/sh

# Check network exists
ifconfig wg0 || exit 1

# Check default route exists
[ "$(ip route show table 0 | grep 'default dev wg0')" = "" ] && exit 1

# Check DNS is up
nslookup localhost 127.0.0.1 || exit 1

exit 0
