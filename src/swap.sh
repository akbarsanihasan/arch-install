enable_swap() {
    clear
    print_color $MAGENTA "Setting Swap...\n"

    TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
    SWAP_SIZE_DEFAULT=8192
    SWAP_SIZE_HALF=$((TOTAL_RAM / 2))
    SWAP_SIZE=$SWAP_SIZE_DEFAULT

    if check_swap; then
        print_color $YELLOW "Swap file or partition already exists.\n"
        exit 0
    fi

    if [[ $SWAP_PARTITION == "/swapfile" ]]; then
        if [[ ! "$HIBERNATION" =~ [Nn] ]]; then
            SWAP_SIZE=$TOTAL_RAM
        else
            if [ $SWAP_SIZE_HALF -lt $SWAP_SIZE_DEFAULT ]; then
                SWAP_SIZE=$SWAP_SIZE_HALF
            fi
        fi

        arch-chroot $MOUNT_POINT dd if=/dev/zero of=/swapfile bs=1M count=$SWAP_SIZE status=progress
        arch-chroot $MOUNT_POINT chmod 600 $SWAP_PARTITION
    fi

    arch-chroot $MOUNT_POINT mkswap $SWAP_PARTITION -f
    arch-chroot $MOUNT_POINT swapon $SWAP_PARTITION

    success "Swap succesfully created\n"
}

enable_zram() {
    clear
    print_color $MAGENTA "Setting zram with zram generator...\n"

    echo "[zram0]" >$MOUNT_POINT/etc/systemd/zram-generator.conf
    echo "compression-algorithm = zstd" >>$MOUNT_POINT/etc/systemd/zram-generator.conf
    echo "swap-priority=100" >>$MOUNT_POINT/etc/systemd/zram-generator.conf
    echo "nfs-type = swap" >>$MOUNT_POINT/etc/systemd/zram-generator.conf

    arch-chroot $MOUNT_POINT systemctl daemon-reload
    arch-chroot $MOUNT_POINT systemctl start /dev/zram0

    success "Zram successfully set\n"
    info "Check zram with zramctl or swapon after reboot\n"
    sleep 3
}

setting_swap() {
    if [[ $SWAP_METHOD == "1" ]]; then
        enable_swap || true
    elif [[ $SWAP_METHOD == "2" ]]; then
        enable_zram
    else
        warn "INVALID SWAP choice, no swap configured\n"
        warn "Cannot setting hibernation\n"
    fi
}
