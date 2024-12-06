package() {
    clear
    print_color $MAGENTA "Preparing your partition... \n"
    sleep 3

    BASE_PACKAGE="base sudo linux-firmware"
    NETWORK_PACKAGE="networkmanager wpa_supplicant wireless_tools netctl openssh"
    AUDIO="pipewire pipewire-audio pipewire-pulse pipewire-jack pipewire-alsa wireplumber"
    REFLECTOR_PACKAGE="reflector pacman-contrib"
    PLYMOUTH_PACKAGE="plymouth"
    FS_PACKAGE="ntfs-3g exfatprogs"
    OTHER_PACKAGE="git vim zsh"

    if [[ $KRNL == "1" ]]; then
        KRNL_PACKAGE="linux linux-headers"
    elif [[ $KRNL == "2" ]]; then
        KRNL_PACKAGE="linux-zen linux-zen-headers"
    else
        error "Failed to get kernel"
    fi

    if [[ -n "$BLUETOOTH_USB" ]] || [[ -n "$BLUETOOTH_PCI" ]]; then
        BLUETOOTH_PACAKGE="bluez bluez-utils blueman"
    fi

    if [[ $BOOTLOADER == "1" ]]; then
        BOOTLOADER_PACKAGE="grub os-prober efibootmgr dosfstools mtools"
    elif [[ $BOOTLOADER == "2" ]]; then
        BOOTLOADER_PACKAGE="efibootmgr dosfstools mtools"
    else
        error "Failed to get bootloader"
    fi

    if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
        MICROCODE_PACKAGE="intel-ucode"
    elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
        MICROCODE_PACKAGE="amd-ucode"
    else
        warning "Unknown cpu, no microcode installed\n"
        sleep 3
    fi

    if [[ "$SWAP_METHOD" == "2" ]]; then
        SWAP_PACKAGE="zram-generator"
    fi

    pacstrap $MOUNT_POINT \
        $KRNL_PACKAGE \
        $BASE_PACKAGE \
        $BOOTLOADER_PACKAGE \
        $MICROCODE_PACKAGE \
        $SWAP_PACKAGE \
        $NETWORK_PACKAGE \
        $REFLECTOR_PACKAGE \
        $PLYMOUTH_PACKAGE \
        $FS_PACKAGE \
        $AUDIO \
        $BLUETOOTH_PACAKGE \
        $OTHER_PACKAGE

    if [[ -n "$BLUETOOTH_USB" ]] || [[ -n "$BLUETOOTH_PCI" ]]; then
        arch-chroot $MOUNT_POINT systemctl enable bluetooth
    fi

    success "setting root partition"
    sleep 3
}
