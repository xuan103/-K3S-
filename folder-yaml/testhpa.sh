#!/bin/bash

trap 'kill $(jobs -p)' EXIT

while true; 
do
  curl '120.96.143.50:8080/cgi-bin/kungfu?test&a'> /dev/null 2>&1
done &
while true; do
  curl '120.96.143.50:8080/cgi-bin/kungfu?test&b'> /dev/null 2>&1
done &
while true; do
  sleep 2
  clear
  kubectl get hpa hpa-sp
  echo "關閉請按 ctrl-c"
done
