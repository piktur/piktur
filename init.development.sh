#!/bin/bash

# Ensure relevant ports are free
# 3000, 3001, 3002, 3003, 2368
# $PIKTUR_ADMIN_PORT \
# $PIKTUR_API_PORT \
# $PIKTUR_BLOG_PORT \
# $PIKTUR_CLIENT_PORT \
# $PIKTUR_CLIENT_WEBPACK_DEV_PORT

free_occupied_ports () {
  local pids=`lsof -i4TCP:$1,$2,$3,$4,$5 -sTCP:LISTEN -t`

  # And kill PID(s) and wait for exit status
  if [ -n "$pids" ]
  then
    for pid in $pids; do
      kill -9 "$pid"
      while ps "$pid"; do sleep 0.1; done
    done
  fi
}

free_occupied_ports 3000 3001 3002 3003 2368 # 6379

exit