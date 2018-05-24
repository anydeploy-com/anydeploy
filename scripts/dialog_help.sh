!/usr/bin/env bash
alias echo="echo -e"
items=(
    item_1 "Item 1" "\nSelected Items...\n"
    item_2 "Item 2" "Selected Item 2"
    item_3 "Item 3" "Selected Item 3"
)

dialog --item-help --menu '\nSelected Items...\n' 0 0 0 "${items[@]}"
