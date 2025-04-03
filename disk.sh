setting_storage() {
    clear
    print_color "${MAGENTA}" "Configuring fstab... \n"

    echo -e "# <file system> <dir> <type> <options> <dump> <pass>" |
        tee "${ROOT_MOUNTPOINT}"/etc/fstab &>/dev/null

    echo -e "UUID=$(get_partinfo "UUID" $EFI_PARTITION)     ${ESP_MOUNTPOINT#${ROOT_PARTITION}}       $(get_partinfo "type" $EFI_PARTITION)      umask=0077      0       1" |
        tee -a "${ROOT_MOUNTPOINT}"/etc/fstab &>/dev/null

    echo -e "UUID=$(get_partinfo "UUID" $ROOT_PARTITION)     /       $(get_partinfo "type" $ROOT_PARTITION)      errors=remount-ro      0       1" |
        tee -a "${ROOT_MOUNTPOINT}"/etc/fstab &>/dev/null

    if [[ "${#EXTRA_STORAGE[@]}" -gt 0 ]]; then
        for i in "${!EXTRA_STORAGE[@]}"; do
            echo -e "$(get_partinfo "UUID" ${EXTRA_STORAGE[$i]})     ${EXTRA_STORAGE_MOUNTPOINT[$i]}       $(get_partinfo "type" ${EXTRA_STORAGE[$i]})      defaults,uid=$(arch-chroot ${ROOT_MOUNTPOINT} id -u $USERNAME),gid=$(arch-chroot ${ROOT_MOUNTPOINT} id -g $USERNAME),nofail      0       0" |
                tee -a "${ROOT_MOUNTPOINT}"/etc/fstab &>/dev/null
        done
    fi

    if [[ $SWAP_METHOD == "1" ]]; then
        if [[ "${SWAP_PARTITION}" == "/swapfile" ]]; then
            echo -e "/swapfile     none        swap        defaults        0       0" |
                tee -a "${ROOT_MOUNTPOINT}"/etc/fstab &>/dev/null
        else
            echo -e "UUID=$(get_partition "UUID" $ROOT_PARTITION)     none        swap        defaults        0       0" |
                tee -a "${ROOT_MOUNTPOINT}"/etc/fstab &>/dev/null
        fi
    fi
}
