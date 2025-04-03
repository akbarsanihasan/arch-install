setting_pacman() {
    clear
    print_color "${MAGENTA}" "Configuring reflector...\n"

    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "--score 32" | arch-chroot "${ROOT_MOUNTPOINT}" tee /etc/xdg/reflector/reflector.conf &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "--protocol https" | arch-chroot "${ROOT_MOUNTPOINT}" tee -a /etc/xdg/reflector/reflector.conf &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "--sort rate" | arch-chroot "${ROOT_MOUNTPOINT}" tee -a /etc/xdg/reflector/reflector.conf &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "--save /etc/pacman.d/mirrorlist" | arch-chroot "${ROOT_MOUNTPOINT}" tee -a /etc/xdg/reflector/reflector.conf &>/dev/null

    arch-chroot "${ROOT_MOUNTPOINT}" systemctl enable reflector.timer

    arch-chroot "${ROOT_MOUNTPOINT}" cp /etc/pacman.conf /etc/pacman.conf.bak
    arch-chroot "${ROOT_MOUNTPOINT}" sed -i '/^#ParallelDownloads[[:space:]]*=[[:space:]]*[0-9]\+/s/^#//' /etc/pacman.conf
    arch-chroot "${ROOT_MOUNTPOINT}" sed -i '/^#Color/s/^#//' /etc/pacman.conf
    arch-chroot "${ROOT_MOUNTPOINT}" sed -i '/^#[[:space:]]*\[multilib\]/,/^#[[:space:]]*Include = \/etc\/pacman.d\/mirrorlist/s/^#//' /etc/pacman.conf

    arch-chroot "${ROOT_MOUNTPOINT}" cp /etc/makepkg.conf /etc/makepkg.conf.bak
    arch-chroot "${ROOT_MOUNTPOINT}" sed -i "s/^#MAKEFLAGS=\".*\"/MAKEFLAGS=\"-j\$(nproc)\"/" /etc/makepkg.conf

    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "[Unit]" | arch-chroot "${ROOT_MOUNTPOINT}" tee /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "Description=Refresh Pacman mirrorlist weekly with Reflector.\n" | arch-chroot "${ROOT_MOUNTPOINT}" tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "[Timer]" | arch-chroot "${ROOT_MOUNTPOINT}" tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "OnCalendar=weekly" | arch-chroot "${ROOT_MOUNTPOINT}" tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "Persistent=true" | arch-chroot "${ROOT_MOUNTPOINT}" tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "AccuracySec=1us" | arch-chroot "${ROOT_MOUNTPOINT}" tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "RandomizedDelaySec=12h" | arch-chroot "${ROOT_MOUNTPOINT}" tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "[Install]" | arch-chroot "${ROOT_MOUNTPOINT}" tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "WantedBy=timers.target" | arch-chroot "${ROOT_MOUNTPOINT}" tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null

    print_color "${GREEN}" "Configuring reflector\n"
    sleep 3
}
