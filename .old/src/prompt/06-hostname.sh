hostname_prompt() {
    print_color $CYAN "=> Enter your hostname: "
    read HOSTNAME

    if [[ -z "$HOSTNAME" ]]; then
        error "This option cannot be empty, run script again\n"
        exit 0
    fi
}

