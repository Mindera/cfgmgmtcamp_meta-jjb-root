#!/usr/bin/env python

import collections
import os
import yaml

from giturlparse import parse

# Read repositories file
repositories_file = open("repository_list.yml", 'r')
repositories = yaml.load(repositories_file)
repositories_file.close()

# Create target directory if it doesn't exist
if not os.path.exists('target'):
    os.makedirs('target')

if not repositories:
    open("target/meta_repositories_jobscreator.yml", 'a').close
    print "No repositories in 'repository_list.yml' file. Exiting..."
    exit(0)

# Validate input and store objects
jjb_projects = {}
for repository_definition in repositories:
    repository_url = None
    project_name = None

    # Check if definition is a simple string or a dict
    if type(repository_definition) is dict:
        repository_url = repository_definition.keys()[0]
        project_name = repository_definition[repository_url]['project_name']
    else:
        repository_url = repository_definition

    # Check if repository_url is valid
    repository_parsed = parse(repository_url)
    if not repository_parsed.valid:
        raise Exception("The url '%s' doesn't appear to be a valid git url." % repository_url)

    # Create a default project_name when not defined
    project_name = project_name or repository_parsed.repo

    # Find project name duplicates
    if project_name in jjb_projects:
        raise Exception("The '%s' project name is duplicated." % project_name)

    # Store projects in a dict
    jjb_projects[project_name] = {
        "giturl": repository_url
    }

# Build jjb repository list object
jjb_repositories = [{k: v} for k, v in jjb_projects.iteritems()]

# Build jjb Meta_repositories_jobscreator project object
jjb_project = [{
    "project": {
        "name": "meta_repositories_jobscreator",
        "jobs": [
            "{repository}-jjb",
        ],
        "repository": jjb_repositories
    }
}]

# Generate yaml from Meta_repositories_jobscreator jjb object
yaml_dumped = yaml.dump(
    jjb_project,
    default_style='',
    default_flow_style=False,
    explicit_start=True,
    indent=2
)

# Write to a file the yaml generated
jjb_root_yaml = open("target/meta_repositories_jobscreator.yml", 'w')
jjb_root_yaml.write(yaml_dumped)
jjb_root_yaml.close()

# Debug: print to console the yaml generated
print "Jenkins Job Build Yaml definition"
print yaml_dumped
