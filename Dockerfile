FROM ubuntu:18.04
LABEL maintainer="Alex"

#Set environment variable AIRFLOW_HOME
ENV AIRFLOW_HOME /usr/local/airflow

# Folder Structure:
# Airflow
# ├── apt_get_requirements.txt
# ├── config
# │   └── airflow.cfg
# ├── Dockerfile
# ├── pip_requirements.txt
# └── scripts
#     └── entrypoint.sh

#Copy entrypoint bash script and airflow configuration file
COPY scripts/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

#Copy requirement files to install dependencies
COPY ./apt_get_requirements.txt /tmp/apt_get_requirements.txt
COPY ./pip_requirements.txt /tmp/pip_requirements.txt

#Updates the package lists for upgrades for packages that need upgrading, as well as new packages that have just come to the repositories.
RUN apt-get update \
    #Install python3 and libffi
    && apt-get -y install $(cat /tmp/apt_get_requirements.txt) \
    #Add user airflow
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    #Install dependencies for airflow and dbs
    && pip install -r /tmp/pip_requirements.txt \
    #Removes unused packages with its config files and its dependencies with auto-yes and being run quietly in the packground (quiet level 2)
    && apt-get purge --auto-remove -yqq \
    #Removes packaes that have been installed as dependencies and are no longer used and removes them with auto-yes and (quiet level 2)
    && apt-get autoremove -yqq --purge \
    #Clears out the local repository of retrieved package files. Removes everything but the lock file from /var/cache/apt/archives/ and /var/cache/apt/archives/partial/
    && apt-get clean \
    #Force deletion of the following folders and sub folders.
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

#Change ownership of the files in the ${AIRFLOW_HOME} directory to "airflow:" recursively
RUN chown -R airflow: ${AIRFLOW_HOME} \
    #Make directories and parent directories as neeed for /tmp/work/
    && mkdir -p /tmp/work/ \
    #Change ownership of the files in the ${AIRFLOW_HOME} directory to "airflow:" recursively
    && chown -R airflow: /tmp/work \
    #Changing permissions to read & write & execute for user (4+2+1), read & execute for the group (4+1), read & execute for others (4+1) on entrypoint.sh
    && chmod 755 /entrypoint.sh \
    #Changing permissions to add executable to the user on /etc/sudoers
    && chmod u+w /etc/sudoers \
    #Adds text to sudoers file which enables passwordless sudo
    && echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers


#Exposes the ports needed for airflow, Celery Flower, Celery webserver for workers
EXPOSE 8080 5555 8793

#Create the working directory the specified airflow home directory:/usr/local/airflow
WORKDIR ${AIRFLOW_HOME}

#Set the user name to airflow for running any RUN, CMD, and ENTRYPOINT instructions that follow.
USER airflow

#Create airflow logs folder
RUN mkdir /usr/local/airflow/logs

#Execute bash file
ENTRYPOINT ["/entrypoint.sh"]
