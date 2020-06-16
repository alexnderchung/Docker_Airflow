#!/usr/bin/env bash

#Mounts all devices described at /etc/fstab.
sudo mount -a

AIRFLOW_HOME="/usr/local/airflow"
CMD="airflow"

#Run 'airflow initdb'
sleep 30
echo "Running airflow initdb"
$CMD initdb
sleep 30
echo "Running airflow scheduler"
$CMD scheduler
sleep 30
echo "Running airflow webserver"
$CMD webserver
echo "Finished running commands"
#Replace current shell and run 'airflow webserver'
#exec $CMD "$@"
