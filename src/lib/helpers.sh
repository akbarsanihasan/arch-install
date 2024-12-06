print_color() {
    color_code="$1"
    text="$2"
    echo -en "\e[${color_code}m${text}\e[0m"
}

success() {
    local warn_text=$1

    print_color $GREEN "Success: "
    print_color $WHITE "$warn_text"
}

info() {
    local info_text=$1

    print_color $BLUE "Info: "
    print_color $WHITE "$info_text"
}

warn() {
    local warn_text=$1

    print_color $YELLOW "Warning: "
    print_color $WHITE "$warn_text"
}

error() {
    local error_text=$1

    print_color $RED "Error: "
    print_color $WHITE "$error_text"
}

get_disk_label() {
    local partition=$1
    blkid -o value -s LABEL $partition
}

separator() {
    print_color $GREEN "#------------------------------------------------------------------------------------------------#\n"
}

check_swap() {
    if [ -f /proc/swaps ] && [ $(wc -l < /proc/swaps) -gt 1 ]; then
        return 0
    else
        return 1
    fi
}
