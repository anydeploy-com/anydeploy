#!/bin/bash

any64_export=$(grep "/nfs/any64" /etc/exports) 

if [ ! -z "${any64_export}" ] ; then echo "/etc/exports already contains entry for any64, skipping" 
else
echo "/nfs/any64 *(rw,no_root_squash,async,insecure,no_subtree_#!/bin/bash
