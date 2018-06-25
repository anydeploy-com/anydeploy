<?php
// This script sends signal to the server that deployment process has been completed.

// Example call: http://localhost/deployment_done.php?vmid=101&task=installation

// Get all passed arguments and attach to variables
extract($_REQUEST);


// build single string of parameters from passed array
$params=http_build_query($_REQUEST,'',' ');

// build command to pass to bash
$cmd = "sudo ./deployment_done.sh $params";

// Execute bash
echo shell_exec($cmd);

// Add wait for VM to shutdown and start capturing using losetup partclone
?>
