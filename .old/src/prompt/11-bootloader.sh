bootloader_prompt() {
    # -- Select Botloader
    clear
    print_color $WHITE "1) Grub\n"
    print_color $WHITE "2) Systemd-boot\n"
    print_color $CYAN "=> Choose your bootloader: "
    read -r BOOTLOADER

    if [[ -z "$BOOTLOADER" ]]; then
        print_color $RED "This option cannot be empty, run script again\n"
        exit 0
    fi

    if ! [[ "$BOOTLOADER" =~ [12] ]]; then
        print_color $RED "\nChoice INVALID"
        exit 0
    fi
}
