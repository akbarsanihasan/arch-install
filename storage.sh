setting_storage() {
    clear
    print_color "${MAGENTA}" "Mounting extra storage.. \n"

    if [[ "${#EXTRA_STORAGE[@]}" -gt 0 ]]; then
        for i in "${!EXTRA_STORAGE[@]}"; do
            clear
            print_color "${MAGENTA}" "Mounting ${EXTRA_STORAGE[$i]} to ${EXTRA_STORAGE_MOUNTPOINT[$i]}...\n"

            mount --mkdir "${EXTRA_STORAGE[$i]}" "${ROOT_MOUNTPOINT}"/"${EXTRA_STORAGE_MOUNTPOINT[$i]}"
            arch-chroot "${ROOT_MOUNTPOINT}" chown -R "${USERNAME}" "${EXTRA_STORAGE_MOUNTPOINT[$i]}"
        done
    fi

    arch-chroot $ROOT_MOUNTPOINT echo -e "# <file system> <dir> <type> <options> <dump> <pass>" | tee /etc/fstab &>/dev/null
    arch-chroot $ROOT_MOUNTPOINT echo -e "UUID=$(get_partinfo "UUID" $EFI_PARTITION)     ${ESP_MOUNTPOINT#${ROOT_PARTITION}}       $(get_partinfo "type" $EFI_PARTITION)      umask=0077      0       1" | tee -a /etc/fstab &>/dev/null
    arch-chroot $ROOT_MOUNTPOINT echo -e "UUID=$(get_partinfo "UUID" $ROOT_PARTITION)     /       $(get_partinfo "type" $ROOT_PARTITION)      errors=remount-ro      0       1" | tee -a /etc/fstab &>/dev/null
    if [[ "${#EXTRA_STORAGE[@]}" -gt 0 ]]; then
        for i in "${!EXTRA_STORAGE[@]}"; do
            arch-chroot $ROOT_MOUNTPOINT echo -e "$(get_partinfo "UUID" ${EXTRA_STORAGE[$i]})     ${EXTRA_STORAGE_MOUNTPOINT[$1]}       $(get_partinfo "type" ${EXTRA_STORAGE[$1]})      defaults,uid=$(id -u $USERNAME),uid=$(id -g $USERNAME),nofail      0       0" | tee -a /etc/fstab &>/dev/null
        done
    fi
    if [[ $SWAP_METHOD == "1" ]]; then
        if [[ "${SWAP_PARTITION}" == "/swapfile" ]]; then
            arch-chroot $ROOT_MOUNTPOINT echo -e "/swapfile     none        swap        defaults        0       0"
        else
            arch-chroot $ROOT_MOUNTPOINT echo -e "UUID=$(get_partition "UUID" $ROOT_PARTITION)     none        swap        defaults        0       0"
        fi
    fi
}
