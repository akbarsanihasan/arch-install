setting_extra_disk(){
    if [[ ! "$ADD_DISK" =~ [Nn] ]]; then
        for i in ${!EXTRA_DISKS[@]}; do
            clear
            print_color $MAGENTA "Mounting ${EXTRA_DISKS[$i]} to ${EXTRA_DISKS_MOUNT_POINT[$i]}...\n"

            mount --mkdir ${EXTRA_DISKS[$i]} $MOUNT_POINT/${EXTRA_DISKS_MOUNT_POINT[$i]}
            arch-chroot $MOUNT_POINT chown -R $USERNAME ${EXTRA_DISKS_MOUNT_POINT[$i]}
        done

        success "Setting extra disks\n"
    fi
}
