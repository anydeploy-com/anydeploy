#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source ../../global.conf                              # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions


##############################################################################
#                      Verify if variables were passed                       #
##############################################################################

ARGUMENT_LIST=(
    "o"
    "t"
)

ARGUMENT_LIST_LONG=(
    "arg-one"
    "arg-two"
)

# read arguments
opts=$(getopt \
    --name "$(basename "$0")" \
    --options "$(printf "%s:," "${ARGUMENT_LIST[@]}")" \
    --longoptions "$(printf "%s:," "${ARGUMENT_LIST_LONG[@]}")" \
    -- "$@"
)

eval set --$opts

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o | --arg-one )
            argOne=$2
            shift 2
            ;;

        -t | --arg-two )
            argTwo=$2
            shift 2
            ;;

        *)
            break
            ;;
    esac
done


echo one: ${argOne}
echo two: ${argTwo}
