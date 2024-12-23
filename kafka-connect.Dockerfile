FROM confluentinc/cp-kafka-connect-base:7.6.1
RUN confluent-hub install --no-prompt debezium/debezium-connector-postgresql:2.5.4
