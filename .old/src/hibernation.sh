setting_hibernation_grub() {
    EXISTING_OPTIONS=$(grep "GRUB_CMDLINE_LINUX_DEFAULT" $MOUNT_POINT/etc/default/grub | grep -oP '(?<=\")[^\"]+(?=\")')

    # # For my hackintosh OpenLinuxBoot
    # EXISTING_STUB_OPTIONS=$(grep "options" $MOUNT_POINT/boot/loader/entries/archlinux.conf | sed 's/^options //')

    if [[ $SWAP_PARTITION == "/swapfile" ]]; then
        HIBERNATION_UUID=$(blkid -s UUID -o value $ROOT_PARTITION)
        RES_OFFSET=$(arch-chroot $MOUNT_POINT filefrag -v /swapfile | awk 'NR==4 {gsub(/[^0-9]/, "", $4); print $4}')
        NEW_OPTIONS="GRUB_CMDLINE_LINUX_DEFAULT=\"$EXISTING_OPTIONS resume=UUID=$HIBERNATION_UUID resume_offset=$RES_OFFSET\""

        # # For my hackintosh OpenLinuxBoot
        # NEW_OPTIONS_STUB="options $EXISTING_STUB_OPTIONS resume=UUID=$HIBERNATION_UUID resume_offset=$RES_OFFSET"
    else
        HIBERNATION_UUID=$(blkid -s UUID -o value $SWAP_PARTITION)
        NEW_OPTIONS="GRUB_CMDLINE_LINUX_DEFAULT=\"$EXISTING_OPTIONS resume=UUID=$HIBERNATION_UUID\""

        # # For my hackintosh OpenLinuxBoot
        # NEW_OPTIONS_STUB="options $EXISTING_STUB_OPTIONS resume=UUID=$HIBERNATION_UUID"
    fi

    if [ -z "$HIBERNATION_UUID" ]; then
        print_color $YELLOW "Failed to obtain UUID. Exiting."
        exit 1
    fi

    # For my hackintosh OpenLinuxBoot
    # sed -i "s|^options.*|${NEW_OPTIONS_STUB}|" $MOUNT_POINT/boot/loader/entries/archlinux.conf
    sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT.*|${NEW_OPTIONS}|" $MOUNT_POINT/etc/default/grub
    sed -i '/^HOOKS=/s/udev/udev resume/' $MOUNT_POINT/etc/mkinitcpio.conf
}

setting_hibernation_systemd() {
    ESP_MOUNT_POINT="$MOUNT_POINT/boot" # Override esp mount point
    EXISTING_OPTIONS=$(grep "options" $ESP_MOUNT_POINT/loader/entries/archlinux.conf | sed 's/^options //')

    if [[ $SWAP_PARTITION == "/swapfile" ]]; then
        HIBERNATION_UUID=$(blkid -s UUID -o value $ROOT_PARTITION)
        RES_OFFSET=$(arch-chroot $MOUNT_POINT filefrag -v /swapfile | awk 'NR==4 {gsub(/[^0-9]/, "", $4); print $4}')

        NEW_OPTIONS="options $EXISTING_OPTIONS resume=UUID=$HIBERNATION_UUID resume_offset=$RES_OFFSET"
    else
        HIBERNATION_UUID=$(blkid -s UUID -o value $SWAP_PARTITION)
        NEW_OPTIONS="options $EXISTING_OPTIONS resume=UUID=$HIBERNATION_UUID"
    fi

    if [ -z "$HIBERNATION_UUID" ]; then
        print_color $YELLOW "Failed to obtain UUID for hibernation. Exiting."
        exit 1
    fi
}

setting_hibernation(){
    clear
    print_color $MAGENTA "Setting hibernation...\n"

    if [[ ! "$HIBERNATION" =~ [Nn] ]]; then
        if [[ "$BOOTLOADER" == "1" ]]; then
            setting_hibernation_grub || true
        elif [[ $BOOTLOADER == "2" ]]; then
            setting_hibernation_systemd || true
        else
            error "INVALID bootloader choice\n"
            error "Bootloader not installed, you won't be able to boot to your Operating System\n"
            sleep 3
        fi
        success "Setting hibernation\n"
    fi
}
