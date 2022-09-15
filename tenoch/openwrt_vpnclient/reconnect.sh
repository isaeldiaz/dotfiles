#!/bin/sh
n=10
while sleep 50; do
t=$(ping -c $n 8.8.8.8 | grep -o -E '[0-9]+ packets r' | grep -o -E '[0-9]+')
if [ "$t" -eq 0 ]; then
/etc/init.d/openvpn restart
fi
done
