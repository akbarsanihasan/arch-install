setting_storage() {
    clear
    print_color "${MAGENTA}" "Configuring fstab... \n"

    esp_uuid=$(get_partinfo "UUID" "$EFI_PARTITION")
    esp_type=$(get_partinfo "type" "$EFI_PARTITION")

    root_uuid=$(get_partinfo "UUID" "$ROOT_PARTITION")
    root_type=$(get_partinfo "type" "$ROOT_PARTITION")

    echo -e "# <file system> <dir> <type> <options> <dump> <pass>" | tee "${ROOT_MOUNTPOINT}"/etc/fstab &>/dev/null
    echo -e "UUID=$esp_uuid     ${ESP_MOUNTPOINT}#${ROOT_MOUNTPOINT}       $esp_type      umask=0077      0       1" | tee -a "${ROOT_MOUNTPOINT}"/etc/fstab &>/dev/null
    echo -e "UUID=$root_uuid     /     $root_type        errors=remount-ro      0       1" | tee -a "${ROOT_MOUNTPOINT}"/etc/fstab &>/dev/null

    if [[ "${#EXTRA_STORAGE[@]}" -gt 0 ]]; then
        for i in "${!EXTRA_STORAGE[@]}"; do
            extra_dev="${EXTRA_STORAGE[$i]}"
            extra_mountpoint="${EXTRA_STORAGE_MOUNTPOINT[$i]}"
            extra_uuid=$(get_partinfo "UUID" "$extra_dev")
            extra_fstype=$(get_partinfo "type" "$extra_dev")

            if [[ "$extra_fstype" == "ntfs" || "$extra_fstype" == "exfat" ]]; then
                uid=$(arch-chroot "$ROOT_MOUNTPOINT" id -u "$USERNAME")
                gid=$(arch-chroot "$ROOT_MOUNTPOINT" id -g "$USERNAME")
                echo -e "UUID=$extra_uuid $extra_mountpoint $extra_fstype defaults,uid=$uid,gid=$gid,nofail 0 0" | tee -a "${ROOT_MOUNTPOINT}"/etc/fstab
            else
                echo -e "UUID=$extra_uuid $extra_mountpoint $extra_fstype defaults,nofail 0 0" | tee -a "${ROOT_MOUNTPOINT}"/etc/fstab
            fi
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
