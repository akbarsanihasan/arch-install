locale() {
    clear
    clear
    print_color $MAGENTA "Setting locale and language...\n"

    ln -sf /usr/share/zoneinfo/$TIME_ZONE $MOUNT_POINT/etc/localtime
    timedatectl set-ntp true || true
    hwclock --systohc || true

    ADDITIONAL_LOCALE="id_ID.UTF-8"

    sed -i '/^#en_GB.UTF-8/s/^#//' $MOUNT_POINT/etc/locale.gen
    sed -i '/^#en_US.UTF-8/s/^#//' $MOUNT_POINT/etc/locale.gen
    sed -i "/^#$ADDITIONAL_LOCALE/s/^#//" $MOUNT_POINT/etc/locale.gen

    echo "LANG=en_GB.UTF-8" >>$MOUNT_POINT/etc/locale.conf
    echo "LANGUAGE=en_GB.UTF-8" >>$MOUNT_POINT/etc/locale.conf
    echo "LC_TIME=$ADDITIONAL_LOCALE" >>$MOUNT_POINT/etc/locale.conf
    echo "LC_ADDRESS=$ADDITIONAL_LOCALE" >>$MOUNT_POINT/etc/locale.conf
    echo "LC_IDENTIFICATION=$ADDITIONAL_LOCALE" >>$MOUNT_POINT/etc/locale.conf
    echo "LC_TELEPHONE=$ADDITIONAL_LOCALE" >>$MOUNT_POINT/etc/locale.conf
    echo "LC_PAPER=$ADDITIONAL_LOCALE" >>$MOUNT_POINT/etc/locale.conf
    echo "LC_MONETARY=$ADDITIONAL_LOCALE" >>$MOUNT_POINT/etc/locale.conf
    echo "LC_NUMERIC=$ADDITIONAL_LOCALE" >>$MOUNT_POINT/etc/locale.conf
    echo "LC_MEASUREMENT=$ADDITIONAL_LOCALE" >>$MOUNT_POINT/etc/locale.conf

    arch-chroot $MOUNT_POINT locale-gen

    success "Successfully setting locale\n"
    sleep 3
}
