#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source ../../global.conf                              # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions


##############################################################################
#                               Parse arguments                              #
##############################################################################

ARGUMENT_LIST=(
    "s"
    "d"
)

ARGUMENT_LIST_LONG=(
    "source"
    "destination"
)

USAGE_DESC="USAGE: ./capture [-s | --source] <source> [-d | --destination] <destination>"
USAGE_SAMPLE="SAMPLE: ./capture.sh -source \"/dev/sda\" -destination \"/images/Windows 7/\" "

# read arguments
opts=$(getopt \
    --name "$(basename "$0")" \
    --options "$(printf "%s:," "${ARGUMENT_LIST[@]}")" \
    --longoptions "$(printf "%s:," "${ARGUMENT_LIST_LONG[@]}")" \
    -- "$@"
)

required_arguments() {

  if [ -z "${source}" ]; then
    echo "<source> argument must be provided"
  fi

if [ -z "${destination}" ]; then
  echo "<destination> argument must be provided"
fi

if [ -z "${source}" ] || [ -z "${destination}" ]; then
  echo ""
  echo "${USAGE_DESC}"
  echo ""
  exit 1
fi
}

eval set --$opts

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s | --source )
            source="${2}"
            shift 2
            ;;

        -d | --destination )
            destination="${2}"
            shift 2
            ;;

        *)
            required_arguments
            break
            ;;
    esac
done


echo source: ${source}
echo destination: ${destination}
