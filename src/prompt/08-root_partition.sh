root_partition_prompt() {
    print_color $CYAN "=> Pick your root partition, all DATA wil be ERASED and FORMAT, (/dev/xxx): "
    read ROOT_PARTITION

    if [[ -z "$ROOT_PARTITION" ]]; then
        error "This option cannot be empty, run script again\n"
        exit 0
    fi

    if [ -z "$(blkid $ROOT_PARTITION)" ]; then
        error "root partition doesn't exist, create the partition and run the script again\n"
        exit 0
    fi

    if [ -n "$(blkid -s TYPE -o value $ROOT_PARTITION)" ]; then
        warn "$ROOT_PARTITION have fstype of $(blkid -s TYPE -o value $ROOT_PARTITION) will be FORMATED and ERASED for ROOT partition\n"
        sleep 1
        warn "If this is a mistake ABORT by pressing ctrl-c\n"
        sleep 1
    fi
}
