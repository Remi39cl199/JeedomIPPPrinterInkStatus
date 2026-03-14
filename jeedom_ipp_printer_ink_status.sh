#!/bin/bash

TIMEOUT=5
IP="$1"
TESTFILE="/usr/share/cups/ipptool/get-printer-attributes.test"

if [ -z "$IP" ]; then
    echo '{"error":"missing_ip"}'
    exit 1
fi

if ! command -v ipptool >/dev/null 2>&1; then
    echo '{"error":"ipptool_not_installed"}'
    exit 1
fi

URL="ipp://$IP:631/ipp/print"

DATA=$(timeout $TIMEOUT ipptool -tv "$URL" "$TESTFILE" 2>/dev/null)

if [ -z "$DATA" ]; then
    echo '{"error":"printer_unreachable"}'
    exit 1
fi


MODEL=$(echo "$DATA" | awk -F'= ' '/printer-make-and-model/{gsub(/"/,"",$2);print $2;exit}')

STATE_NUM=$(echo "$DATA" | awk '/printer-state /{print $NF;exit}')

case "$STATE_NUM" in
3) STATE="idle" ;;
4) STATE="printing" ;;
5) STATE="stopped" ;;
*) STATE="unknown" ;;
esac


REASONS=$(echo "$DATA" | awk -F'= ' '/printer-state-reasons/{print $2;exit}')


NAMES=$(echo "$DATA" | awk -F'= ' '/marker-names/{print $2;exit}')
LEVELS=$(echo "$DATA" | awk -F'= ' '/marker-levels/{print $2;exit}')
HIGHS=$(echo "$DATA" | awk -F'= ' '/marker-high-levels/{print $2;exit}')
LOWS=$(echo "$DATA" | awk -F'= ' '/marker-low-levels/{print $2;exit}')

INK_JSON="{}"

if [ -n "$NAMES" ] && [ -n "$LEVELS" ]; then

IFS=',' read -ra NAME_ARRAY <<< "$NAMES"
IFS=',' read -ra LEVEL_ARRAY <<< "$LEVELS"
IFS=',' read -ra HIGH_ARRAY <<< "$HIGHS"
IFS=',' read -ra LOW_ARRAY <<< "$LOWS"

INK_JSON="{"
FIRST=1

for i in "${!NAME_ARRAY[@]}"; do

NAME=$(echo "${NAME_ARRAY[$i]}" | tr -d '"' | xargs)
LEVEL=$(echo "${LEVEL_ARRAY[$i]}" | xargs)
HIGH=$(echo "${HIGH_ARRAY[$i]}" | xargs)
LOW=$(echo "${LOW_ARRAY[$i]}" | xargs)

KEY=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')

PERCENT="null"

if [[ "$LEVEL" =~ ^[0-9]+$ ]] && [[ "$HIGH" =~ ^[0-9]+$ ]] && [ "$HIGH" -gt 0 ]; then
PERCENT=$(( LEVEL * 100 / HIGH ))
fi

STATUS="ok"

if [[ "$REASONS" == *marker-supply-low-warning* ]] && [ "$LEVEL" -le "$LOW" ]; then
STATUS="low"
fi

if [ "$LEVEL" = "0" ]; then
STATUS="empty"
fi

if [ $FIRST -eq 0 ]; then
INK_JSON="$INK_JSON,"
fi

INK_JSON="$INK_JSON\"$KEY\":{
\"level\":$LEVEL,
\"percent\":$PERCENT,
\"low_threshold\":$LOW,
\"status\":\"$STATUS\"
}"

FIRST=0

done

INK_JSON="$INK_JSON}"
fi


echo "{
\"printer\":\"$MODEL\",
\"ip\":\"$IP\",
\"state\":\"$STATE\",
\"state_reasons\":\"$REASONS\",
\"ink\":$INK_JSON
}"
