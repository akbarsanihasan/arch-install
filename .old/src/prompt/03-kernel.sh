kernel_prompt() {
    clear
    print_color $WHITE "1) Linux\n"
    print_color $WHITE "2) Linux-zen\n"
    print_color $CYAN "=> Pick your kernel(1/2): "
    read -r KRNL

    if [[ -z "$KRNL" ]]; then
        KRNL=1
    fi

    if [[ ! "$KRNL" =~ [12] ]]; then
        echo -e
        error "Option must be 1/2\n"
        exit 0
    fi
}
