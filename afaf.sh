#!/bin/bash

function script_help {
	echo "Usage: $(basename $0) [option] <file>"
	echo -e "\n!IMPORTANT!\t\tTo be able to create and delete users/groups\n\t\t\tyour user must be in the sudoers group!"
	echo "Available options:"
	echo -e "-h, --help\t\tPrints this message"
	echo -e "-l, --list\t\tPrints list of users to be created from the specified file"
	echo -e "-a, --add \t\tAdd users from the specified file"
	echo -e "-d, --delete\t\tDelete users from the specified file"
}

function list {
	echo -e "\nUsers with these parameters will be created:\n"
	while IFS=: read -r fuser fpass fgroup fdir fshell
	do
		# display fields
		printf 'Username: %s, Password: %s, Group: %s, Home Directory: %s, Shell: %s\n\n' "$fuser" "$fpass" "$fgroup" "$fdir" "$fshell"
	done < "$file"
}

function proceed_file {
	while IFS=: read -r fuser fpass fgroup fdir fshell
	do
		# create groups
		echo -e "\nCreating group "$fgroup""
		groupadd "$fgroup"
		# create users
		echo -e "\nCreating user "$fuser""
		useradd -m "$fuser" -g "$fgroup" -d "$fdir" -s "$fshell"
		# adding password
		echo -e "\nSetting system password for "$fuser""
		passwd "$fuser" <<< "$fpass"$'\n'"$fpass"
	done < "$file"
}

function delete_user_group {
	while IFS=: read -r fuser fpass fgroup fdir fshell
	do
	# delete user
	echo -e "\nDeleting user "$fuser""
	userdel -r "$fuser"
	# delete group
	echo -e "\nDeleting group "$fgroup""
	groupdel "$fgroup"
	done < "$file"
}

opt=$1
param=$2
case $opt
in
	-h|--help)
	script_help
	;;
	-l|--list)
	file="$param"
	list
	;;
	-a|--add)
	file="$param"
	proceed_file
	;;
	-d|--delete)
	file="$param"
	delete_user_group
	;;
esac

if [ $# -eq 0 ]; then
	script_help
	exit 1
fi
