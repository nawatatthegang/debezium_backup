#!/bin/bash

PORT=8084

if [[ $# -eq 0 ]]; then
	echo "Usage:"

	echo -e "./utils.sh get [connector name]"
	echo -e "\tGets the config for the connector"
	echo -e "./utils.sh status [connector name]"
	echo -e "\tGets the status for the connector"

	echo -e "./utils.sh add [path to connector config]"
	echo -e "\tAdds connector to Kafka Connect"
	echo -e "./utils.sh update [connector name] [path to new connector config]"
	echo -e "\tUpdates connector specified by name with the new config"
	echo -e "./utils.sh delete [connector name]"
	echo -e "\tRemoves connector from Kafka Connect"

	echo -e "./utils.sh pause [connector name]"
	echo -e "\tPauses connector"
	echo -e "./utils.sh resume [connector name]"
	echo -e "\tResumes connector"

	echo -e "./utils.sh stop [connector name]"
	echo -e "\tStops connector"
	echo -e "./utils.sh restart [connector name]"
	echo -e "\tRestarts connector"
fi

if [[ $1 == "get" ]]; then
	curl "http://localhost:$PORT/connectors/$2" | jq
elif [[ $1 == "status" ]]; then
	curl "http://localhost:$PORT/connectors/$2/status" | jq

elif [[ $1 == "add" ]]; then
	curl -X POST -H "Content-Type:application/json" -d "@$2" http://localhost:$PORT/connectors
elif [[ $1 == "update" ]]; then
	curl -X PUT -H "Content-Type:application/json" -d "$(jq '.config' $3)" "http://localhost:$PORT/connectors/$2/config"
elif [[ $1 == "delete" ]]; then
	curl -X DELETE "http://localhost:$PORT/connectors/$2"

elif [[ $1 == "pause" ]]; then
	curl -X PUT "http://localhost:$PORT/connectors/$2/pause"
elif [[ $1 == "resume" ]]; then
	curl -X PUT "http://localhost:$PORT/connectors/$2/resume"

elif [[ $1 == "stop" ]]; then
	curl -X PUT "http://localhost:$PORT/connectors/$2/stop"
elif [[ $1 == "restart" ]]; then
	curl -w "%{http_code}" -X POST "http://localhost:$PORT/connectors/$2/restart?includeTasks=true"
fi
