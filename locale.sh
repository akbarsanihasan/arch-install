setting_locale() {
    clear
    print_color "${MAGENTA}" "Setting locale and language...\n"

    ln -sf /usr/share/zoneinfo/"${TIMEZONE}" "${ROOT_MOUNTPOINT}"/etc/localtime
    timedatectl set-ntp true &>/dev/null
    hwclock --systohc &>/dev/null

    ADDITIONAL_LOCALE="id_ID.UTF-8"

    sed -i '/^#en_GB.UTF-8/s/^#//' "${ROOT_MOUNTPOINT}"/etc/locale.gen
    sed -i '/^#en_US.UTF-8/s/^#//' "${ROOT_MOUNTPOINT}"/etc/locale.gen
    sed -i "/^#$ADDITIONAL_LOCALE/s/^#//" "${ROOT_MOUNTPOINT}"/etc/locale.gen

    echo "LANG=en_GB.UTF-8" | tee "${ROOT_MOUNTPOINT}"/etc/locale.conf &>/dev/null
    echo "LANGUAGE=en_GB.UTF-8" | tee -a "${ROOT_MOUNTPOINT}"/etc/locale.conf &>/dev/null
    echo "LC_TIME=$ADDITIONAL_LOCALE" | tee -a "${ROOT_MOUNTPOINT}"/etc/locale.conf &>/dev/null
    echo "LC_ADDRESS=$ADDITIONAL_LOCALE" | tee -a "${ROOT_MOUNTPOINT}"/etc/locale.conf &>/dev/null
    echo "LC_IDENTIFICATION=$ADDITIONAL_LOCALE" | tee -a "${ROOT_MOUNTPOINT}"/etc/locale.conf &>/dev/null
    echo "LC_TELEPHONE=$ADDITIONAL_LOCALE" | tee -a "${ROOT_MOUNTPOINT}"/etc/locale.conf &>/dev/null
    echo "LC_PAPER=$ADDITIONAL_LOCALE" | tee -a "${ROOT_MOUNTPOINT}"/etc/locale.conf &>/dev/null
    echo "LC_MONETARY=$ADDITIONAL_LOCALE" | tee -a "${ROOT_MOUNTPOINT}"/etc/locale.conf &>/dev/null
    echo "LC_NUMERIC=$ADDITIONAL_LOCALE" | tee -a "${ROOT_MOUNTPOINT}"/etc/locale.conf &>/dev/null
    echo "LC_MEASUREMENT=$ADDITIONAL_LOCALE" | tee -a "${ROOT_MOUNTPOINT}"/etc/locale.conf &>/dev/null

    arch-chroot "${ROOT_MOUNTPOINT}" locale-gen

    success "Successfully setting locale\n"
    sleep 3
}
