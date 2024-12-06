password_prompt() {
    # -- Set user password
    print_color $CYAN "=> Enter your username password (It will visible throughout install, be careful): "
    read USER_PASSWORD

    if [[ -z "$USER_PASSWORD" ]]; then
        error "This option cannot be empty, run script again\n"
        exit 0
    fi

    # -- Set root password
    print_color $CYAN "=> Enter your root password [Empty allowed] (It will visible throughout install, be careful): "
    read ROOT_PASSWORD
}
