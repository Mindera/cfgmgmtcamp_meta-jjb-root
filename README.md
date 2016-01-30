# meta-jjb-root

## Description
#####- meta-jjb-root job:
The goal of meta-jjb-root job is to create (and update) dynamically the "{Project}-jjb" for several projects given their git URL.

For each "{Project}-jjb" the goal is to create (and update) dynamically all the jobs related to the respective project. It will look for files at '.jenkins' folder at the project root, and run JJB using the file 'jobs.yml'.

**Note**: The definition of this {Project}-jjb will recursive load files in the path defined by the variable *$JJB_GLOBALS_PATH*. This variable by default is the path where the globals macros and templates defined in this repository are stored.

#####- This repository:
Not only versions and stores meta-jjb-root config files, but also global files for Jenkins Job Builder (JJB), like macros and templates.

## Requirements:
- python
- virtualenv

## Instalation and configuration of JJB
http://ci.openstack.org/jenkins-job-builder/installation.html

#### jenkins_config.ini eg:
    # Jenkins Jobs Ini example:
    [job_builder]
    ignore_cache=true
    keep_descriptions=false
    recursive=true
    allow_duplicates=false

    [jenkins]
    url=http://JENKINK_URL/
    user=YOUR_USER_NAME
    password=YOUR_API_KEY

## Test and update meta-jjb-root job:
    jenkins-jobs -l DEBUG --ignore-cache --conf .jenkins/jenkins_config.ini update -r globals:.jenkins/jobs.yml

## Simulate a meta-jjb-root run locally
    JJB_GLOBALS_PATH=/tmp/jjb-globals bash builder.sh
