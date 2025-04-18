setting_fstab() {
	clear
	print_color "$MAGENTA" "Configuring fstab... \n"

	mapfile -t disks < <(lsblk -pnr -o NAME,TYPE | awk '$2 == "part" { print $1 }')
	esp_uuid=$(get_partinfo "uuid" "$EFI_PARTITION")
	esp_type=$(get_partinfo "type" "$EFI_PARTITION")

	root_uuid=$(get_partinfo "uuid" "$ROOT_PARTITION")
	root_type=$(get_partinfo "type" "$ROOT_PARTITION")

	echo -e "# <file system> <dir> <type> <options> <dump> <pass>" | tee "$ROOT_MOUNTPOINT"/etc/fstab &>/dev/null
	echo -e "UUID=$esp_uuid     ${ESP_MOUNTPOINT#${ROOT_MOUNTPOINT}}       $esp_type      umask=0077      0       1" | tee -a "$ROOT_MOUNTPOINT"/etc/fstab &>/dev/null
	echo -e "UUID=$root_uuid     /     $root_type        errors=remount-ro      0       1" | tee -a "$ROOT_MOUNTPOINT"/etc/fstab &>/dev/null

	for disk in "${disks[@]}"; do
		uid=$(arch-chroot "$ROOT_MOUNTPOINT" id -u "$USERNAME")
		gid=$(arch-chroot "$ROOT_MOUNTPOINT" id -g "$USERNAME")

		disk_fstype=$(get_partinfo "type" "$disk")
		disk_uuid=$(get_partinfo "uuid" "$disk")
		disk_label=$(get_partinfo "label" "$disk")
		disk_mountpoint="/media/$disk_label"

		if [[ -z $disk_label ]]; then
			disk_mountpoint="/media/$disk_uuid"
		fi

		if [[ -z $disk_fstype ]]; then
			continue
		fi

		if [[ $disk == "$EFI_PARTITION" ]]; then
			continue
		fi

		if [[ $disk == "$ROOT_PARTITION" ]]; then
			continue
		fi

		if [[ $disk == "$SWAP_PARTITION" ]]; then
			continue
		fi

		if udevadm info --query=property --name="$disk" | grep -q '^ID_BUS=usb' &>/dev/null; then
			continue
		fi

		mkdir -p "$ROOT_MOUNTPOINT"/"$disk_mountpoint"
		case "$disk_fstype" in
		ntfs | exfat)
			echo -e "UUID=$disk_uuid $disk_mountpoint $disk_fstype defaults,uid=$uid,gid=$gid,nofail 0 0" | tee -a "$ROOT_MOUNTPOINT"/etc/fstab
			;;
		ext4)
			arch-chroot "$ROOT_MOUNTPOINT" chown -R "$USERNAME" "$disk_mountpoint"
			echo -e "UUID=$disk_uuid $disk_mountpoint $disk_fstype defaults,nofail 0 0" | tee -a "$ROOT_MOUNTPOINT"/etc/fstab
			;;
		esac
	done

	exit 1

	if [[ $SWAP_METHOD == "1" ]]; then
		if [[ "$SWAP_PARTITION" == "/swapfile" ]]; then
			echo -e "/swapfile     none        swap        defaults        0       0" |
				tee -a "$ROOT_MOUNTPOINT"/etc/fstab &>/dev/null
		else
			echo -e "UUID=$(get_partition "UUID" "$ROOT_PARTITION")     none        swap        defaults        0       0" |
				tee -a "$ROOT_MOUNTPOINT"/etc/fstab &>/dev/null
		fi
	fi
}
