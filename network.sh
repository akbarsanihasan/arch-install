setting_network() {
    clear
    print_color "${MAGENTA}" "Setting network...\n"

    arch-chroot "${ROOT_MOUNTPOINT}" echo "$HOST_NAME" | arch-chroot "${ROOT_MOUNTPOINT}" tee /etc/hostname &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "127.0.0.1 localhost" | arch-chroot "${ROOT_MOUNTPOINT}" tee /etc/hosts &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "::1 localhost " | arch-chroot "${ROOT_MOUNTPOINT}" tee /etc/hosts &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "127.0.0.1 $HOST_NAME" | arch-chroot "${ROOT_MOUNTPOINT}" tee /etc/hosts &>/dev/null

    arch-chroot "${ROOT_MOUNTPOINT}" systemctl enable NetworkManager

    success "setting network\n"
    sleep 3
}
