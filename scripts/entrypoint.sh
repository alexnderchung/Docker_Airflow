#!/usr/bin/env bash

#Mounts all devices described at /etc/fstab.
sudo mount -a

AIRFLOW_HOME="/usr/local/airflow"
CMD="airflow"

#Run 'airflow initdb'
sleep 30
$CMD initdb
sleep 30
$CMD scheduler
sleep 30
$CMD webserver
#Replace current shell and run 'airflow webserver'
#exec $CMD "$@"
