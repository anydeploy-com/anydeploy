#!/bin/bash

replace () {
var=$2
new_val=$3

sed -e "s/^$var *=*.*/$var = $new_val/; s/^$var [^=]*$/$var $new_val/" "$1" | grep $var

}
