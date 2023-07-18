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


############# DEV

## TO DO List:
#TODO: Add Invalid IP Address Check
#TODO: Allow User to configure encryption bits. Default to 4096 and only allow that as minimum
#TODO: Make Reverse script which deletes known identity files and / or incorporate into this script.
#TODO: Globalize Greeting (Will be done in next release) 
#TODO: Check if user put in the full username (user@ipaddress) in the "Enter Username" Field.



#####key######
#- unfinished
#x finished
#####key######

##Issues:
#- entering no hostname tries to rename ~/.ssh/identities and fails to fail
#x no port default 22
#- no check for existing file, hostname should come first.
#- ssh-copy-id is failing with `too many arguments, expected a target hostname, got: <blank>`


##Changes to List:
#- Major Version changed from 4.1 -> 5.0
#- Added Checks to read Username, IP Address, Port Number (with valid range), and Hostname. Don't allow empty or invalid values
#- Fixed `ssh-copy-id` incorrect syntax (not 100% sure, but it might have changed)
#- Fixed Missing escape for "SSH Public Key Copied" echo

############# DEV

## Define Global Version
version=5.0
## Main (Original) Greeting
clear
echo -e "\e[0m"
echo -e "\e[96m##################################"
echo -e "\e[96m# Welcome to \e[93mSpongey's\e[0m           \e[96m#\e[0m"
echo -e "\e[96m# \e[4mNo Excuses\e[0m \e[96mSSH Security Script #\e[0m"
echo -e "\e[96m# \e[31mrev. $version\e[0m                       \e[96m#\e[0m"
echo -e "\e[96m##################################"

## Ask User to configure SSH Identities, if not, exit script.
echo -e "\e[0m"
echo -e "\e[34m::\e[37m Do you want to configure SSH identities? (y/N)\e[0m"
echo -e "\e[32m==> \e[0m\c\r"; read choice
case "$choice" in
    y|Y|yes|YES ) choice="y";;
    * ) choice="n";;
esac


## USERNAME Question
# Ask User for Username, if invalid, return invalid warning.
    ## <DEV> Deprecated
    #read -p $'\e[34m::\e[37m Enter Username: \e[0m' username
    ## <DEV>
    if [ "$choice" = "y" ]; then
        echo -e "\e[34m::\e[37m Enter Username: \e[0m"
        echo -e "\e[32m==> \e[0m\c\r"; read username
        while [ -z "$username" ]; do
            # <DEV> Deprecated
            #read -p $'\e[31m❗ Username cannot be empty. Please enter a valid Username\e[0m\n\e34m::\e[37m Enter Username: \e[0m' username
            # <DEV>
            clear
            echo -e "\e[0m"
            echo -e "\e[96m##################################"
            echo -e "\e[96m# Welcome to \e[93mSpongey's\e[0m           \e[96m#\e[0m"
            echo -e "\e[96m# \e[4mNo Excuses\e[0m \e[96mSSH Security Script #\e[0m"
            echo -e "\e[96m# \e[31mrev. $version\e[0m                       \e[96m#\e[0m"
            echo -e "\e[96m##################################\n"
            echo -e "\e[31m❗ Username cannot be empty. Please enter a valid Username.\e[0m"
            echo -e "\e[34m::\e[37m Enter Username: \e[0m"
            echo -e "\e[32m==> \e[0m\c\r"; read username
        done

## IP ADDRESS Question
# Ask User for IP Address, if invalid, return invalid warning.
    ## <DEV> Deprecated
    #read -p $'\e[34m::\e[37m Enter IP Address: \e[0m' ip_address
    ## <DEV>
    echo -e "\e[34m::\e[37m Enter IP Address: \e[0m"
    echo -e "\e[32m==> \e[0m\c\r"; read ip_address
    while [ -z "$ip_address" ]; do
        # <DEV> Deprecated
        #read -p $'\e[31m❗ IP Address cannot be empty. Please enter a valid IP Address\e[0m\n\e[34m::\e[37m Enter IP Address: \e[0m' ip_address
        # <DEV>
        clear
        echo -e "\e[0m"
        echo -e "\e[96m##################################"
        echo -e "\e[96m# Welcome to \e[93mSpongey's\e[0m           \e[96m#\e[0m"
        echo -e "\e[96m# \e[4mNo Excuses\e[0m \e[96mSSH Security Script #\e[0m"
        echo -e "\e[96m# \e[31mrev. $version\e[0m                       \e[96m#\e[0m"
        echo -e "\e[96m##################################\n"
        echo -e "\e[31m❗ IP Address cannot be empty. Please enter a valid IP Address.\e[0m"
        echo -e "\e[34m::\e[37m Enter IP Address: \e[0m"
        echo -e "\e[32m==> \e[0m\c\r"; read ip_address
    done

## PORT Question
# Ask user for port number. Only allow port number that is valid (0-65535), no input = port 22 default.
while true; do
    echo -e "\e[34m::\e[37m Enter Port (default: 22): \e[0m"
    echo -e "\e[32m==> \e[0m\c\r"; read port_number
    port_number=${port_number:-22}
    # Check if the input is a number
    if [[ $port_number =~ ^[0-9]+$ ]]; then
        # Check if the number is within the allowed range
        if ((port_number >= 0 && port_number <= 65535)); then
            break  # Valid input, exit the loop
        else
            clear
            echo -e "\e[0m"
            echo -e "\e[96m##################################"
            echo -e "\e[96m# Welcome to \e[93mSpongey's\e[0m           \e[96m#\e[0m"
            echo -e "\e[96m# \e[4mNo Excuses\e[0m \e[96mSSH Security Script #\e[0m"
            echo -e "\e[96m# \e[31mrev. $version\e[0m                       \e[96m#\e[0m"
            echo -e "\e[96m##################################\n"
            echo -e "\e[31m❗ Invalid port number.\e[0m"
            echo -e "\e[31m❗ Please enter a number within the range \e[4m0-65535\e[0m\e[31m.\e[0m"
            echo -e "\e[31m❗ Or use defaults.\e[0m"
        fi
    else
        clear
        echo -e "\e[0m"
        echo -e "\e[96m##################################"
        echo -e "\e[96m# Welcome to \e[93mSpongey's\e[0m           \e[96m#\e[0m"
        echo -e "\e[96m# \e[4mNo Excuses\e[0m \e[96mSSH Security Script #\e[0m"
        echo -e "\e[96m# \e[31mrev. $version\e[0m                       \e[96m#\e[0m"
        echo -e "\e[96m##################################\n"
        echo -e "\e[31m❗ Invalid input.\e[0m"
        echo -e "\e[31m❗ Please enter a \e[4m\e[5mnumber\e[0m\e[31m within the range \e[4m0-65535\e[0m\e[31m.\e[0m"
        echo -e "\e[31m❗ Or use defaults.\e[0m"
    fi
done

## HOSTNAME Question
# TODO: Check if user inputted `.local` and remove it.
# Ask User for Hostname, if invalid, return invalid warning.
    ## <DEV> Deprecated
    #read -p $'\e[34m::\e[37m Enter Hostname: \e[0m' hostname
    ## <DEV>
    echo -e "\e[34m::\e[37m Enter Hostname: \e[0m"
    echo -e "\e[32m==> \e[0m\c\r"; read hostname
    while [ -z "$hostname" ]; do
        #read -p $'\e[31m❗ Hostname cannot be empty. Please enter a valid Hostname\e[0m\n\e[34m::\e[37m Enter Hostname: \e[0m' hostname
        clear
        echo -e "\e[0m"
        echo -e "\e[96m##################################"
        echo -e "\e[96m# Welcome to \e[93mSpongey's\e[0m           \e[96m#\e[0m"
        echo -e "\e[96m# \e[4mNo Excuses\e[0m \e[96mSSH Security Script #\e[0m"
        echo -e "\e[96m# \e[31mrev. $version\e[0m                       \e[96m#\e[0m"
        echo -e "\e[96m##################################\n"
        echo -e "\e[31m❗ Hostname cannot be empty. Please enter a valid Hostname.\e[0m"
        echo -e "\e[34m::\e[37m Enter Hostname: \e[0m"
        echo -e "\e[32m==> \e[0m\c\r"; read hostname
    done
    hostname="${hostname%.local}"

    # echo -e "ℹ️ \e[0mYou will now be asked to enter a SSH Key Passphrase."
    # echo -e "ℹ️ \e[0mIt's your choice if you want a passphrase, however the"
    # echo -e "ℹ️ \e[0mdefault should 'empty' should be fine, though if 


# Prompt user to create ssh-identities directory if it doesn't exist. **ONLY IF** it doesn't exist. Otherwise skip
ssh_identities_dir=~/.ssh/ssh-identities
if [ ! -d "$ssh_identities_dir" ]; then
    echo -e "\e[34m::\e[37m $ssh_identities_dir does not exist. Do you want to create it? (y/N)\e[0m"
    echo -e "\e[32m==> \e[0m\c\r"; read create_ssh_identities_dir
    case "$create_ssh_identities_dir" in
        y|Y|yes|YES ) mkdir -p "$ssh_identities_dir";;
        * ) echo -e "\e[31m❌ \e[0mSSH identity configuration skipped.\e[0m"; exit 1;;
    esac
fi

clear
echo -e "\e[0m"
echo -e "\e[96m##################################"
echo -e "\e[96m# Welcome to \e[93mSpongey's\e[0m           \e[96m#\e[0m"
echo -e "\e[96m# \e[4mNo Excuses\e[0m \e[96mSSH Security Script #\e[0m"
echo -e "\e[96m# \e[31mrev. $version\e[0m                       \e[96m#\e[0m"
echo -e "\e[96m##################################\n"
echo -e "\e[34m::\e[37m Enter SSH RSA Key Passphrase (default: No Passphrase): \e[0m"
echo -e "\e[34m::\e[37m Transferring Input to \e[93mssh-keygen\e[0m\e[37m...\e[0m\n"


    # Create SSH identity files
    private_key=~/.ssh/ssh-identities/$hostname
    public_key="$private_key.pub"
    ssh-keygen -t rsa -b 4096 -f "$private_key" -C "$username@$hostname" #-N ""
    echo -e "\n\e[34m::\e[37m Press \e[4mEnter\e[0m\e[37m to continue this script.\e[0m"
    echo -e "\e[31m❗ Please Note: Screen will be \e[4m\e[5mcleared\e[0m\e[31m upon pressing Enter.\e[0m"
    echo -e "\e[31m❗ \e[4mWRITE DOWN WHAT YOU NEED NOW.\e[0m"; read -r
    
    clear
    echo -e "\e[34m::\e[37m Welcome Back!\e[0m\n"
    echo -e "\e[32m==✅ \e[0mSSH identity of \e[5m\e[4mhostname\e[0m created.\e[0m"
    echo -e "  \e[31mPrivate Key Location:\e[0m $private_key"
    echo -e "  \e[32mPublic Key Location:\e[0m $public_key"
    echo -e "\e[32m==✅\e[0m"

    # Copy identity file to remote host
    echo -e "\e[34m::\e[37m Please Enter Password & Accept Key Fingerprint for your Remote.\e[0m"
    echo -e "\e[34m::\e[37m This \e[4mshould\e[0m be the \e[4mlast\e[0m time you'll need to do this.\e[0m\n"
    echo -e "\e[34m::\e[37m Transferring Input to \e[93mssh-copy-id\e[0m\e[37m...\e[0m\n"
    ssh-copy-id -i "$public_key" -p "$port_number" "$username@$ip_address"
    echo -e "\e[32m==✅ \e[0mSSH Public Key Copied to \e[4m$hostname\e[0m"

    # Append host configuration to ~/.ssh/config
    # TODO: Add Check if this already exists before writing changes.
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
