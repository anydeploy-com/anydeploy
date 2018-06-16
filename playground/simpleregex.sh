#!/bin/bash

gender="male"

if [ "$gender" = "male" ]; then echo "it's a man"; else echo "it's a female"; fi

if [ -z $(lspci) ]; then echo "dupa"; else echo "cipa"; fi
