#!/usr/bin/env bash

set -e # Stop script at error

# Variables
LOCALCONF="";
if [ -z "${LOG_LEVEL}" ]; then LOG_LEVEL="DEBUG"; fi

if ! [ -f "/etc/jenkins_jobs/jenkins_jobs.ini" ]; then
    # Local environment
    LOCALCONF="--conf .jenkins/jenkins_jobs.ini";
    JJB_GLOBALS_PATH=/tmp/jjb-globals;
else
    JJB_GLOBALS_PATH=/etc/jenkins_jobs/globals;
fi

echo -e "\n>>>> Variables"
echo -e "LOG_LEVEL=$LOG_LEVEL"
echo -e "LOCALCONF=\"$LOCALCONF\""
echo -e "JJB_GLOBALS_PATH=$JJB_GLOBALS_PATH"

echo -e "\n>>> Create virtualenv"
virtualenv venv --distribute

echo -e "\n>>> Activate virtual env"
. venv/bin/activate

echo -e "\n>>> Installing pip requirements"
pip install -r requirements.txt

if [ -d "$JJB_GLOBALS_PATH" ]; then
    echo -e "\n>>> Remove old macros."
    rm -r $JJB_GLOBALS_PATH
fi

echo -e "\n>>> Update macros and templates in the system"
cp -r globals $JJB_GLOBALS_PATH

echo -e "\n>>> Creating meta_repositories_jobscreator.yml"
python meta_repositories_jobscreator.py

echo -e "\n>>> Running JJB for meta_repositories_jobscreator.yml"
jenkins-jobs -l $LOG_LEVEL $LOCALCONF update -r $JJB_GLOBALS_PATH:target/meta_repositories_jobscreator.yml

echo -e "\n>>> Deactivate virtual env"
deactivate