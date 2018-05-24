#!/bin/bash

source spinner.sh

task_1() {
  apt update -y #&> /anydeploy/tmp/update
}

task_2() {
  apt upgrade -y #&> /anydeploy/tmp/upgrade
  sleep 5
}

# Fix echo for output+ remove cursor
stty -echo && tput civis

spinner "Task 1" task_1 #output1
spinner "Task 2" task_2 #output2
tput el


# Revert regular echo + revert cursor
tput cnorm && stty echo
