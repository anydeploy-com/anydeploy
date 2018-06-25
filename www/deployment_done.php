<?php
// This script sends signal to the server that deployment process has been completed.

$vmid="vm123"; // Virtual Machine ID to be captured
$task="Sample Task";


$cmd = "sudo ./deployment_done.sh vmid=$vmid task=$task"; // Command To Run
echo shell_exec($cmd); // Execute Command


// Add wait for VM to shutdown and start capturing using losetup partclone
?>
