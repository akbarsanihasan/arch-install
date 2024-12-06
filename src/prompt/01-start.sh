start_prompt() {
    clear

    echo -en "\e[33m
    ░██╗░░░░░░░██╗░█████╗░██████╗░███╗░░██╗██╗███╗░░██╗░██████╗░
    ░██║░░██╗░░██║██╔══██╗██╔══██╗████╗░██║██║████╗░██║██╔════╝░
    ░╚██╗████╗██╔╝███████║██████╔╝██╔██╗██║██║██╔██╗██║██║░░██╗░
    ░░████╔═████║░██╔══██║██╔══██╗██║╚████║██║██║╚████║██║░░╚██╗
    ░░╚██╔╝░╚██╔╝░██║░░██║██║░░██║██║░╚███║██║██║░╚███║╚██████╔╝
    ░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝╚═╝╚═╝░░╚══╝░╚═════╝░

    This script is intended to automate my archlinux installation process

    make sure you have complete all step down below:

    1. Create a partition (important), this script doesn't have support for btrfs (only support for ext partition) partition
    2. Make sure your EFI partition atleast 500M or 1G
    3. Proceed with caution, if you screwed up. i suggest to start over from beginning

    \e[0m"

    print_color $CYAN "Proceed to install (Yes/No): "
    read -n1 -r INSTALL_CONFIRM

    if [[ "$INSTALL_CONFIRM" =~ [Nn] ]]; then
        clear
        print_color $GREEN "Good bye\n"
        exit 0
    fi
}
