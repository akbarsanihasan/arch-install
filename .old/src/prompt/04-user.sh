user_prompt() {
    # -- Create username
    clear
    print_color $CYAN "=> Enter your username: "
    read USERNAME

    if [[ -z "$USERNAME" ]]; then
        error "This option cannot be empty, run script again\n"
        exit 0
    fi
}
