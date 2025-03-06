setting_ssh(){
    arch-chroot $MOUNT_POINT echo -e "PasswordAuthentication no" | sudo tee /etc/ssh/sshd_config.d/01-disable_password.conf
    arch-chroot $MOUNT_POINT echo -e "ChallengeResponseAuthentication no" | sudo tee -a /etc/ssh/sshd_config.d/01-disable_password.conf
    arch-chroot $MOUNT_POINT echo -e "AuthenticationMethods publickey" | sudo tee -a /etc/ssh/sshd_config.d/01-disable_password.conf
}
