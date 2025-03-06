setting_network() {
    clear
    print_color "${MAGENTA}" "Setting network...\n"

    echo "$HOSTNAME" | tee "${ROOT_MOUNTPOINT}"/etc/hostname &>/dev/null
    echo -e "127.0.0.1 localhost" | tee "${ROOT_MOUNTPOINT}"/etc/hosts &>/dev/null
    echo -e "::1 localhost " | tee "${ROOT_MOUNTPOINT}"/etc/hosts &>/dev/null
    echo -e "127.0.0.1 $HOSTNAME" | tee "${ROOT_MOUNTPOINT}"/etc/hosts &>/dev/null

    arch-chroot "${ROOT_MOUNTPOINT}" systemctl enable NetworkManager sshd

    success "setting network\n"
    sleep 3
}
