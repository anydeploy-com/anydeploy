#!/bin/bash


anynet_x86="/nfs/any"
anynet_amd64="/nfs/any64"


# Checking if anynet already exists"
    if [ -d "${anynet_amd64}" ]; then
      echo "Exists"
    else
      echo "dir doesnt exist"
    fi
