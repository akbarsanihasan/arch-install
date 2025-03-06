setting_package_config() {
    clear
    print_color $MAGENTA "Setting reflector...\n"

    arch-chroot $MOUNT_POINT echo "--score 12" >/etc/xdg/reflector/reflector.conf
    arch-chroot $MOUNT_POINT echo "--age 12" >>/etc/xdg/reflector/reflector.conf
    arch-chroot $MOUNT_POINT echo "--protocol https" >>/etc/xdg/reflector/reflector.conf
    arch-chroot $MOUNT_POINT echo "--sort rate" >>/etc/xdg/reflector/reflector.conf
    arch-chroot $MOUNT_POINT echo "--save /etc/pacman.d/mirrorlist" >>/etc/xdg/reflector/reflector.conf

    arch-chroot $MOUNT_POINT systemctl enable reflector.timer

    arch-chroot $MOUNT_POINT cp /etc/pacman.conf /etc/pacman.conf.bak
    arch-chroot $MOUNT_POINT sed -i '/^#ParallelDownloads[[:space:]]*=[[:space:]]*[0-9]\+/s/^#//' /etc/pacman.conf
    arch-chroot $MOUNT_POINT sed -i '/^#Color/s/^#//' /etc/pacman.conf
    arch-chroot $MOUNT_POINT sed -i '/^#[[:space:]]*\[multilib\]/,/^#[[:space:]]*Include = \/etc\/pacman.d\/mirrorlist/s/^#//' /etc/pacman.conf

    arch-chroot $MOUNT_POINT cp /etc/makepkg.conf /etc/makepkg.conf.bak
    arch-chroot $MOUNT_POINT sed -i 's/^#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf

    print_color $GREEN "Reflector has been set \n"
    sleep 3
}
