#!/bin/bash

. /anydeploy/scripts/includes/functions.sh

# test success
start_spinner 'sleeping for 2 secs...'
sleep 2
stop_spinner $?



start_spinner 'checking dependencies'
sleep 2
stop_spinner $?


deps=(debootstrap)
check_deps
