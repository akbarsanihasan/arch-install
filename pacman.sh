setting_pacman() {
    clear
    print_color "${MAGENTA}" "Setting reflector...\n"

    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "--score 32" | tee /etc/xdg/reflector/reflector.conf &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "--protocol https" | tee -a /etc/xdg/reflector/reflector.conf &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "--sort rate" | tee -a /etc/xdg/reflector/reflector.conf &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "--save /etc/pacman.d/mirrorlist" | tee -a /etc/xdg/reflector/reflector.conf &>/dev/null

    arch-chroot "${ROOT_MOUNTPOINT}" systemctl enable reflector.timer

    arch-chroot "${ROOT_MOUNTPOINT}" cp /etc/pacman.conf /etc/pacman.conf.bak
    arch-chroot "${ROOT_MOUNTPOINT}" sed -i '/^#ParallelDownloads[[:space:]]*=[[:space:]]*[0-9]\+/s/^#//' /etc/pacman.conf
    arch-chroot "${ROOT_MOUNTPOINT}" sed -i '/^#Color/s/^#//' /etc/pacman.conf
    arch-chroot "${ROOT_MOUNTPOINT}" sed -i '/^#[[:space:]]*\[multilib\]/,/^#[[:space:]]*Include = \/etc\/pacman.d\/mirrorlist/s/^#//' /etc/pacman.conf

    arch-chroot "${ROOT_MOUNTPOINT}" cp /etc/makepkg.conf /etc/makepkg.conf.bak
    arch-chroot "${ROOT_MOUNTPOINT}" sed -i "s/^#MAKEFLAGS=\".*\"/MAKEFLAGS=\"-j\$(nproc)\"/" /etc/makepkg.conf

    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "[Unit]" | tee /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "Description=Refresh Pacman mirrorlist weekly with Reflector.\n" | tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "[Timer]" | tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "OnCalendar=weekly" | tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "Persistent=true" | tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "AccuracySec=1us" | tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "RandomizedDelaySec=12h" | tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "[Install]" | tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null
    arch-chroot "${ROOT_MOUNTPOINT}" echo -e "WantedBy=timers.target" | tee -a /usr/lib/systemd/system/reflector.timer &>/dev/null

    print_color "${GREEN}" "Reflector has been set \n"
    sleep 3
}
