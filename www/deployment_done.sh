#!/bin/bash

user=$(whoami)
path="$(pwd)"

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)
    case "$KEY" in
            vmid)              vmid=${VALUE} ;;
            task)    task=${VALUE} ;;
            *)
    esac
done

echo "<h2> Task completed: ${task} </h2>"

echo "<p>"
echo "<strong>User</strong>=${user}</br>"
echo "<strong>Path</strong>=${path}</br>"
echo "</p>"

touch /anydeploy/tmp/${vmid}
echo "${task}" > /anydeploy/tmp/${vmid}

echo "<h2>Variables passed below</h2>";
listvars=$(printenv | grep "SUDO_COMMAND" | sed 's/SUDO_COMMAND=.\/deployment_done.sh//g')
echo ${listvars}

echo "<h2>Sample function</h2>";

if [ $operating_system = "win7" ]; then
  echo "Operating System is Crappy Windows 7"
else
  echo "Operating System isn't Crappy Windows 7"
fi
