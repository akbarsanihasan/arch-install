delete_efi_entry() {
    label="$1"
    entry_numbers=()

    while IFS= read -r entry_number; do
        entry_number="${entry_number/\*/}"
        entry_number="${entry_number#Boot}"
        entry_numbers+=("$entry_number")
    done < <(efibootmgr | grep -i "$label" | awk '{print $1}')

    if [ ${#entry_numbers[@]} -gt 0 ]; then
        for entry_number in "${entry_numbers[@]}"; do
            efibootmgr -b "$entry_number" -B
        done

        echo "EFI boot entry(s) with label '$label' deleted successfully"
    fi
}

format_partition(){
    echo -e
    print_color $MAGENTA "Formatting selected partition...\n"

    if check_swap; then
        mount $ROOT_PARTITION $MOUNT_POINT
        arch-chroot $MOUNT_POINT swapoff -a || true
    fi

    umount -l $ROOT_PARTITION 2>/dev/null || true
    umount -l $EFI_PARTITION 2>/dev/null || true

    umount -l $ESP_MOUNT_POINT 2>/dev/null || true
    umount -l $MOUNT_POINT/boot/efi 2>/dev/null || true
    umount -l $MOUNT_POINT -R 2>/dev/null || true

    if [ -z "$(blkid -s TYPE -o value $EFI_PARTITION | grep -E "v?fat$")" ]; then
        mkfs.fat -F32 -n EFI $EFI_PARTITION
    fi
    mkfs.ext4 -F -L Archlinux $ROOT_PARTITION

    mount $ROOT_PARTITION $MOUNT_POINT
    mount $EFI_PARTITION $ESP_MOUNT_POINT --mkdir

    rm -rf $MOUNT_POINT/boot/{EFI/systemd,EFI/Archlinux,*.img,loader,vmlinuz-*,grub} 2>/dev/null || true
    rm -rf $MOUNT_POINT/boot/efi/{EFI/systemd,EFI/Archlinux,*.img,loader,vmlinuz-*,grub} 2>/dev/null || true
    rm -rf $ESP_MOUNT_POINT/{EFI/systemd,EFI/Archlinux,*.img,loader,vmlinuz-*,grub} 2>/dev/null || true
}

set_mirror(){
    echo -e
    print_color $MAGENTA "Setting pacman and reflector... \n"

    if [[ ! -e /etc/pacman.d/mirrorlist.bak ]]; then
        cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    fi
    reflector --verbose --score 12 \
        --age 12 \
        --protocol https --sort rate \
        --save /etc/pacman.d/mirrorlist


    if [[ ! -e /etc/pacman.conf.bak ]]; then
        cp /etc/pacman.conf /etc/pacman.conf.bak
    fi
    sed -i '/^#ParallelDownloads[[:space:]]*=[[:space:]]*[0-9]\+/s/^#//' /etc/pacman.conf
    sed -i '/^#Color/s/^#//' /etc/pacman.conf
    sed -i '/^#[[:space:]]*\[multilib\]/,/^#[[:space:]]*Include = \/etc\/pacman.d\/mirrorlist/s/^#//' /etc/pacman.conf
    pacman-key --init && pacman-key --populate || true
    pacman -Sy
}

prep() {
    clear

    format_partition

    delete_efi_entry "Linux Boot Manager"
    delete_efi_entry "Archlinux"

    set_mirror
}
