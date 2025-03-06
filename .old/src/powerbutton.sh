setting_powerbutton() {
    clear
    print_color $MAGENTA "Setting power button...\n"

    POWERHANDLETEXT="HandlePowerKey=ignore"
    POWERHANDLE=$(sudo grep -c $POWERHANDLETEXT $MOUNT_POINT/etc/systemd/logind.conf || true)

    if [[ $POWERHANDLE < 1 ]]; then
        print_color $MAGENTA "\nSetting up power button handling...\n"
        sleep 3

        sudo sed -i 's/^#\(HandlePowerKey=\)poweroff/\1ignore/' $MOUNT_POINT/etc/systemd/logind.conf

        success "Powerkey ignored\n"
    else
        success "Powerkey has been ignored\n"
    fi

    sleep 3
}
