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
}
