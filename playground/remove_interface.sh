#!/bin/bash


sed '/eth1/,/^$/ s/.*//g' interfaces
