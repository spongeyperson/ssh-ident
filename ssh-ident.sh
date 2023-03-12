#!/bin/bash

echo -e "\e[34m::\e[37m Do you want to configure SSH identities? (y/N)\e[0m"
echo -e "\e[32m==> \e[0m\c\r"; read choice
case "$choice" in
    y|Y|yes|YES ) choice="y";;
    * ) choice="n";;
esac

if [ "$choice" = "y" ]; then
    echo -e "\e[34m::\e[37m Enter Username: \e[0m"
    echo -e "\e[32m==> \e[0m\c\r"; read username
    echo -e "\e[34m::\e[37m Enter IP Address: \e[0m"
    echo -e "\e[32m==> \e[0m\c\r"; read ip_address
    echo -e "\e[34m::\e[37m Enter Hostname: \e[0m"
    echo -e "\e[34m::\e[31m\e[5m \e[7mDO NOT\e[0m\e[31m append .local"
    echo -e "\e[32m==> \e[0m\c\r"; read hostname
    hostname="${hostname%.local}"

    # Create SSH identity files
    private_key=~/.ssh/ssh-identities/$hostname
    public_key="$private_key.pub"
    ssh-keygen -t rsa -b 4096 -f "$private_key" -C "$username@$hostname" -N ""

    echo -e "\e[32m==✅ \e[0mSSH identity of \e[5m\e[4mhostname\e[0m created.\e[0m"
    echo -e "  \e[31mPrivate Key Location:\e[0m $private_key"
    echo -e "  \e[32mPublic Key Location:\e[0m $public_key"

    # Copy identity file to remote host
    echo -e "\e[32m==\e[0m"
    ssh-copy-id -i "$public_key" "$username@$ip_address"
    echo -e "\e[32m==✅ \e[0mSSH Public Key Copied to $hostname"

    # Append host configuration to ~/.ssh/config
    printf "Host $hostname\n\
        Hostname $ip_address\n\
        IdentityFile $private_key\n\
        User $username\n" >> ~/.ssh/config


    echo -e "\e[32m==✅ \e[0mSSH identity configuration complete.\e[0m"
    echo -e "\e[34m:: \e[0mYou can now SSH using:"
    echo -e "\e[0m"
    echo -e "\e[34m==> \e[0m\e[4mssh $hostname \e[0m\e[34m<==\e[0m"
    echo -e "\e[0m"
else
    echo -e "\e[31m❌ \e[0mSSH identity configuration skipped.\e[0m"
fi
