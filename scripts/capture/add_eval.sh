#!/bin/bash


ARGUMENT_LIST=(
    "s"
    "d"
)

ARGUMENT_LIST_LONG=(
    "source"
    "destination"
)


commands=$(cat <<'EOF'
for argument in ${!ARGUMENT_LIST[@]}; do
echo "-${ARGUMENT_LIST[${argument}]} | --${ARGUMENT_LIST_LONG[${argument}]} )"
echo "${ARGUMENT_LIST_LONG[${argument}]}=\$2"
echo "shift 2"
echo ";;"
echo ""
done
EOF
)

eval "${commands}"
