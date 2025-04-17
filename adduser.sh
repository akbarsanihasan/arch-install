adduser() {
	clear
	print_color "$MAGENTA" "Adding user...\n"

	useradd -mG wheel -R "$ROOT_MOUNTPOINT" "$USERNAME" || true

	arch-chroot "$ROOT_MOUNTPOINT" sh -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\" | passwd $USERNAME" &>/dev/null
	if [[ -n "$ROOT_PASSWORD" ]]; then
		arch-chroot "$ROOT_MOUNTPOINT" sh -c "echo -e \"$ROOT_PASSWORD\n$ROOT_PASSWORD\" | passwd root" &>/dev/null
	fi

	arch-chroot "$ROOT_MOUNTPOINT" sh -c "chsh -s $(which zsh)"
	arch-chroot "$ROOT_MOUNTPOINT" sh -c "chsh -s $(which zsh) $USERNAME"

	sed -E -i 's/^# (%wheel ALL=\(ALL:ALL\) ALL)/\1/' "$ROOT_MOUNTPOINT"/etc/sudoers

	success "Successfully adding user\n"
	sleep 3
}
