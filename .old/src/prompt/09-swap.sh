swap_method_prompt() {
    # -- Select The way swap
    clear
    print_color $WHITE "1) SWAP\n"
    print_color $WHITE "2) Zram\n"
    print_color $CYAN "=> Choose your swap method, pick other if you don't want to swap(1/2): "
    read -r SWAP_METHOD

    if [[ ! "$SWAP_METHOD" =~ [12] ]]; then
        warn "No swap configured\n"
        warn "Cannot setting hibernation\n"
    fi

    if [[ "$SWAP_METHOD" == "2" ]]; then
        warn "Cannot setting hibernation with Zram\n"
    fi
}

swap_partition_prompt() {
    clear
    separator
    lsblk -o name,start,size,type,fstype
    separator
    print_color $CYAN "=> Enter your swap device either your swap partition (/dev/xxx) or swapfile (swapfile has to be /swapfile): "
    read SWAP_PARTITION

    if [[ -z "$SWAP_PARTITION" ]]; then
        print_color $RED "Option cannot be empty, run script again\n"
        exit 0
    fi

    if [ "$SWAP_PARTITION" != "/swapfile" ]; then
        if [ -z "$(blkid $SWAP_PARTITION)" ]; then
            print_color $RED "Swap partition doesn't exist make the swap partition first, then run the script again\n"
            exit 0
        fi
        if [ -n "$(blkid -s TYPE -o value $SWAP_PARTITION)" ] && [ "$(blkid -s TYPE $SWAP_PARTITION -o value | tr '[:upper:]' '[:lower:]')" != "swap" ]; then
            warn "$EFI_PARTITION have fstype of $(blkid -s TYPE -o value $EFI_PARTITION) will be FORMATED and ERASED for EFI partition\n"
            warn "If this is a mistake ABORT by pressing ctrl-c\n"
        fi
    fi
}

hibernation_prompt() {
    print_color $CYAN "=> Configure hibernation (yes/no) "
    read -r HIBERNATION
}

swap_prompt(){
    swap_method_prompt

    if [[ "$SWAP_METHOD" == "1" ]]; then
        swap_partition_prompt
        hibernation_prompt
    else
        HIBERNATION="n"
    fi
}
