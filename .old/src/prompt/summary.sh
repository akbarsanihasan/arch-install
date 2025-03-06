print_summary() {
    clear

    print_color $BLUE "  _____                                                 \n"
    print_color $BLUE " / ____|                                             _ \n"
    print_color $BLUE "| (___  _   _ _ __ ___  _ __ ___   __ _ _ __ _   _  (_)\n"
    print_color $BLUE " \\___ \\| | | | '_ \`_ \\ | '_ \` _ \\ / _\` | '__| | | |    \n"
    print_color $BLUE " ____) | |_| | | | | | | | | | | | (_| | |  | |_| |  _ \n"
    print_color $BLUE "|_____/ \\__,_|_| |_| |_|_| |_| |_|\\__,_|_|   \\__, | (_)\n"
    print_color $BLUE "                                              __/ |    \n"
    print_color $BLUE "                                             |___/     \n"

    print_color $GREEN "Kernel: "
    if [[ "$KRNL" == "1" ]]; then
        echo -e "Linux"
    elif [[ "$KRNL" == "2" ]]; then
        echo "Linux zen"
    else
        echo -e "No"
    fi

    print_color $GREEN "Timezone: "
    echo -e "$TIME_ZONE"

    print_color $GREEN "Username: "
    echo -e "$USERNAME"

    print_color $GREEN "Password: "
    echo -e "$USER_PASSWORD"

    print_color $GREEN "Root password: "
    echo -e "$ROOT_PASSWORD"

    print_color $GREEN "Hostname: "
    echo -e "$HOSTNAME"

    print_color $GREEN "EFI partition: "
    echo -e "$EFI_PARTITION"

    print_color $GREEN "ROOT partition: "
    echo -e "$ROOT_PARTITION"

    print_color $GREEN "Swap: "
    if [[ "$SWAP_METHOD" == "1" ]]; then
        echo "Swap"
        print_color $GREEN "Swap partition: "
        echo "$SWAP_PARTITION"
    elif [[ "$SWAP_METHOD" == "2" ]]; then
        echo "ZRAM"
    else
        echo -e "No"
    fi

    print_color $GREEN "Extra disk: \n"
    for i in ${!EXTRA_DISKS[@]}; do
        echo "~ ${EXTRA_DISKS[$i]} -> ${EXTRA_DISKS_MOUNT_POINT[$i]}"
    done

    print_color $GREEN "Hibernation: "
    if [[ "$HIBERNATION" =~ [Nn] ]]; then
        echo -e "No"
    else
        echo -e "Yes"
    fi

    print_color $GREEN "Bootloader: "
    if [[ "$BOOTLOADER" == "1" ]]; then
        echo "Grub"
    elif [[ "$BOOTLOADER" == "2" ]]; then
        echo "Systemd-boot"
    else
        echo -e "Failed to get bootloader"
    fi

    print_color $CYAN "Proceed to install? (y/n) "
    read -r PROCEED
}
