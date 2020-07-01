
# coding: utf-8

# In[ ]:

import airflow
from airflow.operators.python_operator import PythonOperator
from airflow.models import DAG

import requests

import time
import zipfile
import os
import pandas as pd
import pandas_datareader.data as web
import datetime


def pull_BAC_data():
    print("Start Retreiving Data...")
    symbol = 'BAC'
    left = web.DataReader('AAN','yahoo').shift(periods = 1).reset_index()
    right = web.DataReader('AAN','yahoo').reset_index()
    data = pd.merge(left = left, right = right, how = 'outer', on = 'Date', suffixes = ('Prior','Current')).dropna()
    transformed_data = pd.concat([data, data.loc[:,data.columns.difference(['Date','VolumePrior','VolumeCurrent'])].div(data.OpenCurrent, axis = 0).round(decimals = 3).add_suffix('Percent')], axis = 1)
    transformed_data.to_csv(f'/tmp/work /{symbol}.csv')
    print("Data Retrieved!")


def pull_AAN_data():
    print("Start Retreiving Data...")
    symbol = 'AAN'
    left = web.DataReader('AAN','yahoo').shift(periods = 1).reset_index()
    right = web.DataReader('AAN','yahoo').reset_index()
    data = pd.merge(left = left, right = right, how = 'outer', on = 'Date', suffixes = ('Prior','Current')).dropna()
    transformed_data = pd.concat([data, data.loc[:,data.columns.difference(['Date','VolumePrior','VolumeCurrent'])].div(data.OpenCurrent, axis = 0).round(decimals = 3).add_suffix('Percent')], axis = 1)
    transformed_data.to_csv(f'/tmp/work /{symbol}.csv')
    print("Data Retrieved!")
    
    
# dag
args = {"owner": "Scrape test", "start_date": airflow.utils.dates.days_ago(2)}

dag = DAG(dag_id="scrape_test", default_args=args, schedule_interval=None)


# tasks
BAC_Task = PythonOperator(task_id="pull_BAC_data", python_callable=pull_BAC_data, dag=dag)

AAN_Task = PythonOperator(task_id="pull_AAN_data", python_callable=pull_AAN_data, dag=dag)


# dependencies
BAC_Task.set_upstream(AAN_Task)

