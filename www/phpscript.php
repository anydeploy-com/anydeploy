<?php
// This script sends signal to the server that deployment process has been completed.

// Tasks

// 1. VM Creation
// 2. VM Execution
// 3. Installation
// 4. First Run
// 5. Post Installation - Drivers
// 6. Post Installation - Apps
// 7. Post installation - Updates
// 8. Shutdown
// 9. Capture raw with losetup 

$vmid="vm123"; // Virtual Machine ID to be captured

$cmd = "./deployment_done.sh $vmid"; // Command To Run
echo shell_exec($cmd); // Execute Command


// Add wait for VM to shutdown and start capturing using losetup partclone
?>
