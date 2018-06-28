#!/bin/bash

# TODO - include functions - add formatting, logging etc.
# This script only redirects to the script that triggers capture.

user=$(whoami)
path="$(pwd)"

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)
    case "$KEY" in
            vmid)              vmid=${VALUE} ;;
            task)              task=${VALUE} ;;
            sucessful)              sucessful=${VALUE} ;;
            *)
    esac
done
if [ $sucessful = "yes" ]; then
echo "<h2> Task: ${task} : Operation Sucessful</h2>"
else
echo "<h2> Task: ${task} : Operation Failed</h2>"
fi
echo "<p>"
echo "<strong>User</strong>=${user}</br>"
echo "<strong>Path</strong>=${path}</br>"
echo "</p>"

touch /anydeploy/tmp/${vmid}
echo "${task}" > /anydeploy/tmp/${vmid}

echo "<h2>Variables passed below</h2>";
listvars=$(printenv | grep "SUDO_COMMAND" | sed 's/SUDO_COMMAND=.\/deployment_done.sh//g')
echo ${listvars}


echo "<h2>Calling Capture Deamon</h2>"

cd /anydeploy/scripts/capture/
./deployment_done.sh &
