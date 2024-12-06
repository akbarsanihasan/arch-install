network() {
    clear
    print_color $MAGENTA "Setting network...\n"

    echo "$HOSTNAME" >$MOUNT_POINT/etc/hostname
    echo -e "127.0.0.1 localhost" >$MOUNT_POINT/etc/hosts
    echo -e "::1 localhost " >>$MOUNT_POINT/etc/hosts
    echo -e "127.0.0.1 $HOSTNAME" >>$MOUNT_POINT/etc/hosts

    arch-chroot $MOUNT_POINT systemctl enable NetworkManager sshd

    success "setting network\n"
    sleep 3
}
