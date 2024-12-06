generate_disk_info() {
    clear
    print_color $CYAN "Select partition: "
    echo "${EXTRA_DISKS[@]}"
    separator
    lsblk -o name,start,size,type,fstype
    separator
    print_color $CYAN "=> Enter partition, (/dev/xxx): "
    read DISK

    if [[ -z "$DISK" ]]; then
        error "Cannot be empty\n"
        exit 0
    fi

    if [[ -z "$(blkid $DISK)" ]]; then
        error "Disk partition doesn't exist, create the partition and run the script again\n"
        exit 0
    fi

    if [[ " ${EXTRA_DISKS[@]} " =~ " ${DISK} " ]]; then
        error "Partition already added.\n"
        exit 0
    fi

    if [[ -z "$(blkid -s TYPE -o value $DISK)" ]]; then
        error "Selected partition is not formated.\n"
        exit 0
    fi

    if [[ -z "$(get_disk_label $DISK)" ]]; then
        EXTRA_DISK_MOUNT_POINT_PATH="/media/$(blkid -s UUID -o value $DISK)"
    else
        EXTRA_DISK_MOUNT_POINT_PATH="/media/$(get_disk_label $DISK)"
    fi

    print_color $CYAN "=> Enter mount point for $DISK, (default: $EXTRA_DISK_MOUNT_POINT_PATH): "
    read DISK_MOUNT_POINT

    if [[ -z "$DISK_MOUNT_POINT" ]]; then
        EXTRA_DISK_MOUNT_POINT=$EXTRA_DISK_MOUNT_POINT_PATH
    fi

    EXTRA_DISKS+=($DISK)
    EXTRA_DISKS_MOUNT_POINT+=($EXTRA_DISK_MOUNT_POINT)

    clear
    print_color $CYAN "=> Add more partition? (y/n) "
    read -r ADD_MORE

    if [[ ! "$ADD_MORE" =~ [Nn] ]]; then
        generate_disk_info
    fi
}

extradisk_prompt() {
    clear
    EXTRA_DISKS=()
    EXTRA_DISKS_MOUNT_POINT=()

    print_color $CYAN "=> Add parition or drive and mount? (y/n) "
    read -r ADD_DISK

    if [[ ! "$ADD_DISK" =~ [Nn] ]]; then
        generate_disk_info
    fi
}
