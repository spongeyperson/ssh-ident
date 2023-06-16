#!/bin/bash
#Spongey's Shitty SSH Security Script.
#Revision v5.0
#Copyright 2023 spongeyperson
#https://spongey.xyz
#tyler@spongey.xyz

#This script was created with the help of online tools. I do not pretend
#to know how to make scripts or program anything (at the time of writing this).
#This script is a learning experience for me. 

#USE THIS SCRIPT AT YOUR OWN RISK.

#TODO: Allow User to configure encryption bits. Default to 4096 and only allow that as minimum
#TODO: Make Reverse script which deletes known identity files and / or incorporate into this script.


# Greeting
echo -e "\e[0m"
echo -e "\e[96m##################################"
echo -e "\e[96m# Welcome to \e[93mSpongey's\e[0m           \e[96m#\e[0m"
echo -e "\e[96m# \e[4mNo Excuses\e[0m \e[96mSSH Security Script #\e[0m"
echo -e "\e[96m# \e[31mrev. 5.0\e[0m                       \e[96m#\e[0m"
echo -e "\e[96m##################################"
# Reset, then ask user to continue script

# Ask User to configure SSH Identities
echo -e "\e[0m"
echo -e "\e[34m::\e[37m Do you want to configure SSH identities? (y/N)\e[0m"
echo -e "\e[32m==> \e[0m\c\r"; read choice
case "$choice" in
    y|Y|yes|YES ) choice="y";;
    * ) choice="n";;
esac

# Ask user for Username, IP Address, Port Number, and Hostname of SSH Identities
if [ "$choice" = "y" ]; then
    read -p $'\e[34m::\e[37m Enter Username: \e[0m' username
    while [ -z "$username" ]; do
        read -p $'\e[31m❗ Username cannot be empty. Please enter a valid Username\e[0m\n\e[34m::\e[37m Enter Username: \e[0m' username
    done

    read -p $'\e[34m::\e[37m Enter IP Address: \e[0m' ip_address
    while [ -z "$ip_address" ]; do
        read -p $'\e[31m❗ IP Address cannot be empty. Please enter a valid IP Address\e[0m\n\e[34m::\e[37m Enter IP Address: \e[0m' ip_address
    done

# Ask user for port number. Only allow port number that is valid (0-65535), no input = port 22 default.
while true; do
    read -p $'\e[34m::\e[37m Enter Port (default: 22): \e[0m' port_number
    port_number=${port_number:-22}

    # Check if the input is a number
    if [[ $port_number =~ ^[0-9]+$ ]]; then
        # Check if the number is within the allowed range
        if ((port_number >= 0 && port_number <= 65535)); then
            break  # Valid input, exit the loop
        else
            echo -e "\e[31m❗ Invalid port number. Please enter a number within the range 0-65535.\e[0m"
        fi
    else
        echo -e "\e[31m❗ Invalid input. Please enter a valid number.\e[0m"
    fi
done

    read -p $'\e[34m::\e[37m Enter Hostname: \e[0m' hostname
    while [ -z "$hostname" ]; do
        read -p $'\e[31m❗ Hostname cannot be empty. Please enter a valid Hostname\e[0m\n\e[34m::\e[37m Enter Hostname: \e[0m' hostname
    done
    hostname="${hostname%.local}"


# Prompt user to create ssh-identities directory if it doesn't exist
ssh_identities_dir=~/.ssh/ssh-identities
if [ ! -d "$ssh_identities_dir" ]; then
    echo -e "\e[34m::\e[37m $ssh_identities_dir does not exist. Do you want to create it? (y/N)\e[0m"
    echo -e "\e[32m==> \e[0m\c\r"; read create_ssh_identities_dir
    case "$create_ssh_identities_dir" in
        y|Y|yes|YES ) mkdir -p "$ssh_identities_dir";;
        * ) echo -e "\e[31m❌ \e[0mSSH identity configuration skipped.\e[0m"; exit 1;;
    esac
fi


    # Create SSH identity files
    private_key=~/.ssh/ssh-identities/$hostname
    public_key="$private_key.pub"
    ssh-keygen -t rsa -b 4096 -f "$private_key" -C "$username@$hostname" #-N ""

    echo -e "\e[32m==✅ \e[0mSSH identity of \e[5m\e[4mhostname\e[0m created.\e[0m"
    echo -e "  \e[31mPrivate Key Location:\e[0m $private_key"
    echo -e "  \e[32mPublic Key Location:\e[0m $public_key"

    # Copy identity file to remote host
    echo -e "\e[32m==\e[0m"
    ssh-copy-id -i "$public_key" -p "$port_number" "$username@$ip_address" 
    echo -e "\e[32m==✅ \e[0mSSH Public Key Copied to \e[4m$hostname"

    # Append host configuration to ~/.ssh/config
    printf "Host $hostname\n\
        Hostname $ip_address\n\
        Port $port_number\n\
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
