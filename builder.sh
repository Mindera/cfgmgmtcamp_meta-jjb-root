#!/usr/bin/env bash

set -e # Stop script at error

# Variables
LOCALCONF="";
if [ -z "${LOG_LEVEL}" ]; then LOG_LEVEL="DEBUG"; fi

# Local environment
if [ -z "${JJB_GLOBALS_PATH}" ]; then JJB_GLOBALS_PATH=/tmp/jjb-globals; fi
if ! [ -f "/etc/jenkins_jobs/jenkins_jobs.ini" ]; then
    LOCALCONF="--conf .jenkins/jenkins_jobs.ini";
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

echo -e "\n>>> Remove old macros."
rm -r $JJB_GLOBALS_PATH/globals

echo -e "\n>>> Update macros and templates in the system"
cp -r globals $JJB_GLOBALS_PATH

echo -e "\n>>> Creating meta_repositories_jobscreator.yml"
python meta_repositories_jobscreator.py

echo -e "\n>>> Running JJB for meta_repositories_jobscreator.yml"
jenkins-jobs -l $LOG_LEVEL $LOCALCONF update -r $JJB_GLOBALS_PATH:target/meta_repositories_jobscreator.yml

echo -e "\n>>> Deactivate virtual env"
deactivate
