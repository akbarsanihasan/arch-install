is_usb_device() {
	local dev="$1"

	if [[ "$dev" =~ ^nvme[0-9]+n[0-9]+p[0-9]+$ ]]; then
		dev="${dev%p[0-9]*}"
	else
		dev="${dev%%[0-9]*}"
	fi

	udevadm info --query=property --name="/dev/$dev" | grep -q '^ID_BUS=usb'

	return $?
}

setting_storage() {
	clear
	print_color "$MAGENTA" "Configuring fstab... \n"

	disks=("$(lsblk -p -l -n -f -o name)")
	esp_uuid=$(get_partinfo "uuid" "$EFI_PARTITION")
	esp_type=$(get_partinfo "type" "$EFI_PARTITION")

	root_uuid=$(get_partinfo "uuid" "$ROOT_PARTITION")
	root_type=$(get_partinfo "type" "$ROOT_PARTITION")

	echo -e "# <file system> <dir> <type> <options> <dump> <pass>" | tee "$ROOT_MOUNTPOINT"/etc/fstab &>/dev/null
	echo -e "UUID=$esp_uuid     ${ESP_MOUNTPOINT#${ROOT_MOUNTPOINT}}       $esp_type      umask=0077      0       1" | tee -a "$ROOT_MOUNTPOINT"/etc/fstab &>/dev/null
	echo -e "UUID=$root_uuid     /     $root_type        errors=remount-ro      0       1" | tee -a "$ROOT_MOUNTPOINT"/etc/fstab &>/dev/null

	for extra_disk_part in "${disks[@]}"; do
		local extra_type=$(get_partinfo "type" "$extra_disk_part")
		local extra_uuid=$(get_partinfo "uuid" "$extra_disk_part")
		local extra_label=$(get_partinfo "label" "$extra_disk_part")
		local extra_mountpoint="/media/$extra_label"
		local uid=$(arch-chroot "$ROOT_MOUNTPOINT" id -u "$USERNAME")
		local gid=$(arch-chroot "$ROOT_MOUNTPOINT" id -g "$USERNAME")

		if [[ -z $extra_label ]]; then
			extra_mountpoint="/media/$extra_uuid"
		fi

		if [[ -n "$extra_type" ]] &&
			[[ "$extra_disk_part" != "$EFI_PARTITION" ]] &&
			[[ "$extra_disk_part" != "$EFI_PARTITION" ]] &&
			[[ "$extra_disk_part" != "$ROOT_PARTITION" ]] &&
			! is_usb_device "$extra_disk_part" &&
			([[ "$extra_disk_part" =~ [0-9]$ ]] || [[ "$extra_disk_part" =~ ^nvme[0-9]+n[0-9]+p[0-9]+$ ]]); then

			echo "dev: $extra_disk_part"
			echo "type: $extra_type"
			echo "uuid: $extra_uuid"
			echo "label: $extra_label"
			echo "mount_point: $extra_mountpoint"
			echo "is_usb: $(is_usb_device "$extra_disk_part")"
			echo -e "\n"

			mkdir -p "$ROOT_MOUNTPOINT"/"$extra_mountpoint"

			case "$extra_type" in
			ntfs | exfat)
				echo -e "UUID=$extra_uuid $extra_mountpoint $extra_type defaults,uid=$uid,gid=$gid,nofail 0 0" | tee -a "$ROOT_MOUNTPOINT"/etc/fstab
				;;
			ext4)
				arch-chroot "$ROOT_MOUNTPOINT" chown -R "$USERNAME" "$extra_mountpoint"
				echo -e "UUID=$extra_uuid $extra_mountpoint $extra_type defaults,nofail 0 0" | tee -a "$ROOT_MOUNTPOINT"/etc/fstab
				;;
			esac
		fi
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
