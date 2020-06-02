#!/usr/bin/env bash

#Mounts all devices described at /etc/fstab.
sudo mount -a

AIRFLOW_HOME="/usr/local/airflow"
CMD="airflow"

#Run 'airflow initdb'
$CMD initdb

#Replace current shell and run 'airflow webserver'
#exec $CMD "$@"
exec $CMD webserver -p 8080