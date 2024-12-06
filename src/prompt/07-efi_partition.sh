efi_partition_prompt() {
    # -- Select EFI partition
    clear
    separator
    lsblk -o name,start,size,type,fstype
    separator
    print_color $CYAN "=> Pick your efi partition, (/dev/xxx): "
    read EFI_PARTITION

    if [[ -z "$EFI_PARTITION" ]]; then
        error "This option cannot be empty, run script again\n"
        exit 0
    fi

    if [[ -z "$(blkid $EFI_PARTITION)" ]]; then
        error "EFI partition doesn't exist, create the partition and run the script again\n"
        exit 0
    fi

    if [ -n "$(blkid -s TYPE -o value $EFI_PARTITION)" ]; then # -- There is multiple ridiculous code like this here, it's very amusing
        if [ -z "$(blkid -s TYPE -o value $EFI_PARTITION | grep -E "v?fat$")" ]; then
            warn "$EFI_PARTITION have fstype of $(blkid -s TYPE -o value $EFI_PARTITION) will be FORMATED and ERASED for EFI partition\n"
            warn "If this is a mistake ABORT by pressing ctrl-c\n"
            sleep 2
        fi
    fi
}

