grub() {
    clear
    print_color $MAGENTA "Installing grub...\n"

    ROOT_ID=$(blkid -s UUID -o value $ROOT_PARTITION)

    grub-install --target=x86_64-efi --efi-directory=$ESP_MOUNT_POINT --boot-directory=$MOUNT_POINT/boot --bootloader-id=Archlinux

    EXISTING_OPTIONS=$(grep "GRUB_CMDLINE_LINUX_DEFAULT" $MOUNT_POINT/etc/default/grub | grep -oP '(?<=\")[^\"]+(?=\")')
    NEW_OPTIONS="GRUB_CMDLINE_LINUX_DEFAULT=\"$EXISTING_OPTIONS splash\""

    sed -i 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=5/' $MOUNT_POINT/etc/default/grub
    sed -i 's/^#GRUB_DISABLE_OS_PROBER=/GRUB_DISABLE_OS_PROBER=/' $MOUNT_POINT/etc/default/grub
    sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT.*|${NEW_OPTIONS}|" $MOUNT_POINT/etc/default/grub

    echo -e "menuentry \"Shutdown\" {" >>$MOUNT_POINT/etc/grub.d/40_custom
    echo -e "	echo \"System shutting down...\"" >>$MOUNT_POINT/etc/grub.d/40_custom
    echo -e "	halt" >>$MOUNT_POINT/etc/grub.d/40_custom
    echo -e "}" >>$MOUNT_POINT/etc/grub.d/40_custom

    echo -e "menuentry \"Restart\" {" >>$MOUNT_POINT/etc/grub.d/40_custom
    echo -e "	echo \"System restarting...\"" >>$MOUNT_POINT/etc/grub.d/40_custom
    echo -e "	reboot" >>$MOUNT_POINT/etc/grub.d/40_custom
    echo -e "}" >>$MOUNT_POINT/etc/grub.d/40_custom

    # Add efistub for my hackintosh OpenLinuxBoot.efi
    # mkdir -p $MOUNT_POINT/boot/loader/entries/
    # echo "title   Archlinux" >"$MOUNT_POINT/boot/loader/entries/archlinux.conf"
    # echo "linux   /vmlinuz-linux" >>"$MOUNT_POINT/boot/loader/entries/archlinux.conf"
    # if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
    #     echo "initrd  /intel-ucode.img" >>"$MOUNT_POINT/boot/loader/entries/archlinux.conf"
    # elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
    #     echo "initrd  /amd-ucode.img" >>"$MOUNT_POINT/boot/loader/entries/archlinux.conf"
    # else
    #     print_color $YELLOW "Unknown cpu, no microcode installed\n"
    # fi

    # if [[ $KRNL == "1" ]]; then
    #     echo "initrd  /initramfs-linux.img" >>"$MOUNT_POINT/boot/loader/entries/archlinux.conf"
    # elif [[ $KRNL == "2" ]]; then
    #     echo "initrd  /initramfs-linux-zen.img" >>"$MOUNT_POINT/boot/loader/entries/archlinux.conf"
    # else
    #     error "Failed to get kernel"
    # fi

    # echo "options root=UUID=$ROOT_ID rw log_level=3 quiet splash" >>"$ESP_MOUNT_POINT/loader/entries/archlinux.conf"

    success "Grub installed successfully.\n"
    sleep 3
}

systemd() {
    clear
    print_color $MAGENTA "Installing systemd boot...\n"

    mkdir -p $MOUNT_POINT/etc/pacman.d/hooks 2>/dev/null

    if [ ! -d "$ESP_MOUNT_POINT" ]; then
        error "EFI System Partition (ESP) not found at $ESP_MOUNT_POINT. Adjust the mount point."
        exit 0
    fi

    bootctl --esp-path=$ESP_MOUNT_POINT install || true

    echo "default archlinux*" >"$ESP_MOUNT_POINT/loader/loader.conf"
    echo "timeout 5" >>"$ESP_MOUNT_POINT/loader/loader.conf"
    echo "console-mode max" >>"$ESP_MOUNT_POINT/loader/loader.conf"

    ROOT_ID=$(blkid -s UUID -o value $ROOT_PARTITION)

    echo "title   Archlinux" >"$ESP_MOUNT_POINT/loader/entries/archlinux.conf"

    if [[ $KRNL == "1" ]]; then
        echo "linux   /vmlinuz-linux" >>"$ESP_MOUNT_POINT/loader/entries/archlinux.conf"
    elif [[ $KRNL == "2" ]]; then
        echo "linux   /vmlinuz-linux-zen" >>"$ESP_MOUNT_POINT/loader/entries/archlinux.conf"
    else
        error "Failed to get kernel"
    fi

    if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
        echo "initrd  /intel-ucode.img" >>"$ESP_MOUNT_POINT/loader/entries/archlinux.conf"
    elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
        echo "initrd  /amd-ucode.img" >>"$ESP_MOUNT_POINT/loader/entries/archlinux.conf"
    else
        print_color $YELLOW "Unknown cpu, no microcode installed\n"
    fi

    if [[ $KRNL == "1" ]]; then
        echo "initrd  /initramfs-linux.img" >>"$ESP_MOUNT_POINT/loader/entries/archlinux.conf"
    elif [[ $KRNL == "2" ]]; then
        echo "initrd  /initramfs-linux-zen.img" >>"$ESP_MOUNT_POINT/loader/entries/archlinux.conf"
    else
        error "Failed to get kernel"
    fi

    echo "options root=UUID=$ROOT_ID rw log_level=3 quiet splash" >>"$ESP_MOUNT_POINT/loader/entries/archlinux.conf"

    echo "[Trigger]" >$MOUNT_POINT/etc/pacman.d/hooks/95-systemd-boot.hook
    echo "Type = Package" >>$MOUNT_POINT/etc/pacman.d/hooks/95-systemd-boot.hook
    echo "Operation = Upgrade" >>$MOUNT_POINT/etc/pacman.d/hooks/95-systemd-boot.hook
    echo "Target = systemd" >>$MOUNT_POINT/etc/pacman.d/hooks/95-systemd-boot.hook

    echo -e "\n" >>$MOUNT_POINT/etc/pacman.d/hooks/95-systemd-boot.hook

    echo "[Action]" >>$MOUNT_POINT/etc/pacman.d/hooks/95-systemd-boot.hook
    echo "Description = Gracefully upgrading systemd-boot..." >>$MOUNT_POINT/etc/pacman.d/hooks/95-systemd-boot.hook
    echo "When = PostTransaction" >>$MOUNT_POINT/etc/pacman.d/hooks/95-systemd-boot.hook
    echo "Exec = /usr/bin/systemctl restart systemd-boot-update.service" >>$MOUNT_POINT/etc/pacman.d/hooks/95-systemd-boot.hook

    # rm -rf $ESP_MOUNT_POINT/EFI/Linux
    success "Systemd-boot installed successfully.\n"
    sleep 3
}

bootloader() {
    if [[ $BOOTLOADER == "1" ]]; then
        grub
    elif [[ $BOOTLOADER == "2" ]]; then
        systemd
    else
        error "INVALID bootloader choice\n"
        error "Bootloader not installed, you won't be able to boot to your Operating System\n"
        sleep 3
    fi
}
