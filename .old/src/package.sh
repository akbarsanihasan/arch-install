package() {
    clear
    print_color $MAGENTA "Preparing your partition... \n"
    sleep 3

    local BASE_PACKAGE="base sudo linux-firmware"
    local NETWORK_PACKAGE="networkmanager wpa_supplicant wireless_tools netctl openssh iptables-nft"
    local REFLECTOR_PACKAGE="reflector pacman-contrib"
    local PLYMOUTH_PACKAGE="plymouth"
    local FS_PACKAGE="ntfs-3g exfatprogs virtiofsd"
    local OTHER_PACKAGE="git vim zsh"

    if [[ $KRNL == "1" ]]; then
        local KRNL_PACKAGE="linux linux-headers"
    elif [[ $KRNL == "2" ]]; then
        local KRNL_PACKAGE="linux-zen linux-zen-headers"
    else
        error "Failed to get kernel"
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
        $OTHER_PACKAGE

    success "setting root partition"
    sleep 3
}
