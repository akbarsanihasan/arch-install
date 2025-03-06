timezone_prompt() {
    # -- Select timezone
    clear
    print_color $CYAN "=> Set your timezone: \n"

    TIME_ZONE=$(tzselect)
    echo -e
}
