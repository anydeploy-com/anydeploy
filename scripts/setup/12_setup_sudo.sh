#!/bin/bash

 # TODO
# Add following lines to visudo - but first make sure if they dont exists
# This allows deployment_done.sh to do it's job from php call as root


Cmnd_Alias        CMDS = /anydeploy/www/deployment_done.sh

www-data  ALL=NOPASSWD: CMDS
