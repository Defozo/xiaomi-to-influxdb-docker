#!/bin/bash

DB_NAME=${DB_NAME:=mydb}
DB_URL=${DB_URL:=localhost:8086}
DB_USERNAME=${DB_USERNAME:=root}
DB_PASSWORD=${DB_PASSWORD:=root}
DB_MEASUREMENTS_TAGS=${DB_MEASUREMENTS_TAGS:=DEVICE_NAME=xiaomi_1}
DB_TEMPERATURE_MEASUREMENT_NAME=${DB_TEMPERATURE_MEASUREMENT_NAME:=temperature}
DB_HUMIDITY_MEASUREMENT_NAME=${DB_HUMIDITY_MEASUREMENT_NAME:=humidity}
DB_PM2_5_MEASUREMENT_NAME=${DB_PM2_5_MEASUREMENT_NAME:=pm2_5}
SENDING_INTERVAL_IN_SECONDS=${SENDING_INTERVAL_IN_SECONDS:=30}
LOGGING_LEVEL=${LOGGING_LEVEL:=DEBUG}

if [ -z "${DEVICE_HOST}" ]; then
    logThis "DEVICE_HOST environment variable not set!" "ERROR";
fi

declare -A levels=([DEBUG]=0 [INFO]=1 [ERROR]=2)

logThis() {
    local log_message=$1
    local log_priority=$2

    #check if level exists
    [[ ${levels[$log_priority]} ]] || return 1

    #check if level is enough
    (( ${levels[$log_priority]} < ${levels[$LOGGING_LEVEL]} )) && return 2

    #log here
    echo "$(date -u +"%F %T %Z") : ${log_priority} : ${log_message}"
}
while true
do
	logThis "Acquiring measurements..." "INFO"
	logThis "Acquiring temperature from ${DEVICE_HOST}..." "DEBUG"
	TEMPERATURE=`miio control ${DEVICE_HOST} temperature | tail -n +2 | jq .value`
	logThis "Acquiring relative humidity from ${DEVICE_HOST}..." "DEBUG"
	HUMIDITY=`miio control ${DEVICE_HOST} relativeHumidity | tail -n +2 | tr -d '\r'`
	logThis "Acquiring PM2.5 from ${DEVICE_HOST}..." "DEBUG"
	PM2_5=`miio control ${DEVICE_HOST} pm2_5 | tail -n +2 | tr -d '\r'`
	logThis "Temperature: ${TEMPERATURE}, Humidity: ${HUMIDITY}, PM2.5: ${PM2_5}" "INFO"

	logThis "Sending measurements to InfluxDB at ${DB_URL}..." "INFO"

	curl_options="-v"
	case ${LOGGING_LEVEL} in
		"ERROR")
			curl_options="--silent --show-error"
			;;
		"INFO")
			curl_options="-s -o /dev/null -I -w \"\n%{http_code}\""
			;;
	esac

	curl_output=$(curl ${curl_options} -XPOST -u "${DB_USERNAME}:${DB_PASSWORD}" "${DB_URL}/write?db=${DB_NAME}" --data-binary "${DB_TEMPERATURE_MEASUREMENT_NAME},${DB_MEASUREMENTS_TAGS} value=${TEMPERATURE}
${DB_HUMIDITY_MEASUREMENT_NAME},${DB_MEASUREMENTS_TAGS} value=${HUMIDITY}
${DB_PM2_5_MEASUREMENT_NAME},${DB_MEASUREMENTS_TAGS} value=${PM2_5}");

	logThis "Sleeping for ${SENDING_INTERVAL_IN_SECONDS} seconds..." "INFO"
	sleep ${SENDING_INTERVAL_IN_SECONDS}
done