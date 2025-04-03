setting_storage() {
    clear
    print_color "${MAGENTA}" "Configuring fstab... \n"

    arch-chroot $ROOT_MOUNTPOINT echo -e "# <file system> <dir> <type> <options> <dump> <pass>" |
        arch-chroot $ROOT_MOUNTPOINT tee /etc/fstab &>/dev/null

    arch-chroot $ROOT_MOUNTPOINT echo -e "UUID=$(get_partinfo "UUID" $EFI_PARTITION)     ${ESP_MOUNTPOINT#${ROOT_PARTITION}}       $(get_partinfo "type" $EFI_PARTITION)      umask=0077      0       1" |
        arch-chroot $ROOT_MOUNTPOINT tee -a /etc/fstab &>/dev/null

    arch-chroot $ROOT_MOUNTPOINT echo -e "UUID=$(get_partinfo "UUID" $ROOT_PARTITION)     /       $(get_partinfo "type" $ROOT_PARTITION)      errors=remount-ro      0       1" |
        arch-chroot $ROOT_MOUNTPOINT tee -a /etc/fstab &>/dev/null

    if [[ "${#EXTRA_STORAGE[@]}" -gt 0 ]]; then
        for i in "${!EXTRA_STORAGE[@]}"; do
            arch-chroot $ROOT_MOUNTPOINT echo -e "$(get_partinfo "UUID" ${EXTRA_STORAGE[$i]})     ${EXTRA_STORAGE_MOUNTPOINT[$i]}       $(get_partinfo "type" ${EXTRA_STORAGE[$1]})      defaults,uid=$(id -u $USERNAME),uid=$(id -g $USERNAME),nofail      0       0" |
                arch-chroot $ROOT_MOUNTPOINT tee -a /etc/fstab &>/dev/null
        done
    fi

    if [[ $SWAP_METHOD == "1" ]]; then
        if [[ "${SWAP_PARTITION}" == "/swapfile" ]]; then
            arch-chroot $ROOT_MOUNTPOINT echo -e "/swapfile     none        swap        defaults        0       0" |
                arch-chroot $ROOT_MOUNTPOINT tee -a /etc/fstab &>/dev/null
        else
            arch-chroot $ROOT_MOUNTPOINT echo -e "UUID=$(get_partition "UUID" $ROOT_PARTITION)     none        swap        defaults        0       0" |
                arch-chroot $ROOT_MOUNTPOINT tee -a /etc/fstab &>/dev/null
        fi
    fi
}
