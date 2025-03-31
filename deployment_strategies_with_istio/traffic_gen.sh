#! /bin/bash

set -e

GATEWAY_HOST=""
OPT_HEADER=""

while getopts ":g:h:" arg; do
  case $arg in
    g)
      GATEWAY_HOST=$OPTARG
      ;;
    h)
      OPT_HEADER=$OPTARG
      ;;
  esac
done

# Handle positional argument for header if provided without -h
if [ -z "$OPT_HEADER" ] && [ $# -gt 0 ]; then
  OPT_HEADER=$1
fi

if [ -z "$GATEWAY_HOST" ]; then
  echo "Using http://localhost:5000, header '$OPT_HEADER'"
  for i in $(seq 1 10000); do
    sleep 0.3;
    if [ -z "$OPT_HEADER" ]; then
      curl http://localhost:5000; echo ""
    else
      curl -H "$OPT_HEADER" http://localhost:5000; echo ""
    fi
  done
else
  echo "Using $GATEWAY_HOST, header '$OPT_HEADER'"
  for i in $(seq 1 10000); do
    sleep 0.3;
    if [ -z "$OPT_HEADER" ]; then
      curl $GATEWAY_HOST; echo ""
    else
      curl -H "$OPT_HEADER" $GATEWAY_HOST; echo ""
    fi
  done
fi