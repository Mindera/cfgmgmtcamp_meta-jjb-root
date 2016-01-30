#!/usr/bin/env bash

set -e # Stop script at error

# Variables
if [ -z "${LOG_LEVEL}" ]; then LOG_LEVEL="DEBUG"; fi
CONF=""

# For demo purpose only. Bear in mind that this file normally have jenkins automatic (bot) user password.
# It's up to you keep it on the SCM
DEMO=true
if [ "$DEMO" = true ]; then
    CONF="--conf .jenkins/jenkins_demo_config.ini";
fi

# Local environment
if [ -z "${JJB_GLOBALS_PATH}" ]; then JJB_GLOBALS_PATH=/tmp/jjb-globals; fi

# Do the magic
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

if [ -d $JJB_GLOBALS_PATH ]; then
    echo -e "\n>>> Remove old macros in $JJB_GLOBALS_PATH"
    rm -r $JJB_GLOBALS_PATH
fi

echo -e "\n>>> Update macros and templates in the system"
cp -R globals $JJB_GLOBALS_PATH

echo -e "\n>>> Creating meta_repositories_jobscreator.yml"
python meta_repositories_jobscreator.py

echo -e "\n>>> Running JJB for meta_repositories_jobscreator.yml"
echo "Running... " jenkins-jobs -l $LOG_LEVEL $CONF update -r $JJB_GLOBALS_PATH:target/meta_repositories_jobscreator.yml
jenkins-jobs -l $LOG_LEVEL $CONF update -r $JJB_GLOBALS_PATH:target/meta_repositories_jobscreator.yml

echo -e "\n>>> Deactivate virtual env"
deactivate
