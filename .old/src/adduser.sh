adduser() {
    clear
    print_color $MAGENTA "Adding user...\n"

    useradd -mG wheel -R $MOUNT_POINT $USERNAME || true

    arch-chroot $MOUNT_POINT sh -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\" | passwd $USERNAME"
    if [[ -n "$ROOT_PASSWORD" ]]; then
        arch-chroot $MOUNT_POINT sh -c "echo -e \"$ROOT_PASSWORD\n$ROOT_PASSWORD\" | passwd root"
    fi

    arch-chroot $MOUNT_POINT sh -c "chsh -s $(which zsh)"
    arch-chroot $MOUNT_POINT sh -c "chsh -s $(which zsh) $USERNAME"

    sed -E -i 's/^# (%wheel ALL=\(ALL:ALL\) ALL)/\1/' $MOUNT_POINT/etc/sudoers || true

    success "Successfully adding user\n"
    sleep 3
}
