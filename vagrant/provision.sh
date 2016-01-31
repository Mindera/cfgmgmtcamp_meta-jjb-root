#!/bin/bash

if [ ! -f /usr/bin/svn ];
then
    echo "-------- PROVISIONING SUBVERSION ------------"
    echo "---------------------------------------------"

    ## Install subverison
    apt-get update
    apt-get -y install subversion
else
    echo "CHECK - Subversion already installed"
fi


if [ ! -f /usr/lib/jvm/java-7-oracle/bin/java ];
then
    echo "-------- PROVISIONING JAVA ------------"
    echo "---------------------------------------"

    ## Make java install non-interactive
    ## See http://askubuntu.com/questions/190582/installing-java-automatically-with-silent-option
    echo debconf shared/accepted-oracle-license-v1-1 select true | \
      debconf-set-selections
    echo debconf shared/accepted-oracle-license-v1-1 seen true | \
      debconf-set-selections

    ## Install java 1.7
    ## See http://www.webupd8.org/2012/06/how-to-install-oracle-java-7-in-debian.html
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee /etc/apt/sources.list.d/webupd8team-java.list
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
    apt-get update
    apt-get -y install oracle-java7-installer
else
    echo "CHECK - Java already installed"
fi

if [ ! -f /etc/init.d/jenkins ];
then
    echo "-------- PROVISIONING JENKINS ------------"
    echo "------------------------------------------"


    ## Install Jenkins
    #
    # URL: http://localhost:8080
    # Home: /var/lib/jenkins
    # Start/Stop: /etc/init.d/jenkins
    # Config: /etc/default/jenkins
    # Jenkins log: /var/log/jenkins/jenkins.log
    wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
    sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
    apt-get update
    apt-get -y install jenkins

    # Install plugins
    echo "Instaling plugins."
    plugins_folder="/var/lib/jenkins/plugins"

    plugins=(
        git
        parameterized-trigger
        scm-api
        token-macro
        promoted-builds
        git-client
        matrix-project
        credentials
        mailer
        ssh-credentials
        nested-view
        build-pipeline-plugin
        delivery-pipeline-plugin
        analysis-core
        jquery
        token-macro
        dashboard-view
        maven-plugin
        green-balls
    )

    for plugin in "${plugins[@]}"
    do
        echo "Instaling $plugin ..."
        wget -q -P $plugins_folder http://updates.jenkins-ci.org/latest/$plugin.hpi
        chown jenkins: $plugins_folder/$plugin.hpi
    done
else
    echo "CHECK - Jenkins already installed"
fi

echo "-------- Installing  other requirements ------------"
echo "------------------------------------------------------------------"
apt-get install -y git
apt-get install -y python-setuptools
easy_install pip
pip install --upgrade setuptools
pip install virtualenv
pip install giturlparse.py
pip install jenkins-job-builder
pip install jenkins-view-builder

mkdir -p /etc/jenkins_jobs
cat <<JJBCONFIG > /etc/jenkins_jobs/jenkins_jobs.ini
[job_builder]
keep_descriptions=false
recursive=true
allow_duplicates=false
allow_empty_variables=True

[jenkins]
url=http://localhost:8080/
user=""
password=""
JJBCONFIG
chown -R jenkins: /etc/jenkins_jobs

/etc/init.d/jenkins restart

echo "-------- PROVISIONING DONE ------------"
echo "-- Jenkins: http://localhost:8080      "
echo "---------------------------------------"
