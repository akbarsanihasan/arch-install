setting_plymouth(){
    clear
    print_color $MAGENTA "Setting plymouth...\n"

    hooks_line=$(grep '^HOOKS=' $MOUNT_POINT/etc/mkinitcpio.conf)
    new_hooks_line=$(echo "$hooks_line" | sed 's/\budev\b/udev plymouth/')

    sed -i "s|^HOOKS=.*$|$new_hooks_line|" $MOUNT_POINT/etc/mkinitcpio.conf

    echo -e "[Daemon]\n" >$MOUNT_POINT/etc/plymouth/plymouthd.conf
    echo -e "Theme=bgrt" >>$MOUNT_POINT/etc/plymouth/plymouthd.conf

    success "Plymouth has been set\n"
    sleep 3
}

