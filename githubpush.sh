




#!/usr/bin/env bash
#To run this go into your folder you want to push and then run the script
#TO DO###
#make it not use cat to put at top of file




# getting directory and name of script so it cna be renamed and put in near any directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_NAME=$( basename "$0" )
SCRIPTA=$( echo "$SCRIPT_DIR/$SCRIPT_NAME" )


# (-) commands
if [ "$1" = "-h" ]; then
	echo -e "-i	initiate a new git repository \n-r	reset your credentials"
	exit
fi
if [ "$1" = "-i" ]; then
	echo "initializing your git project"
	git init
	exit
fi
if [ "$1" = "-r" ]; then
	echo "wiping your credentials (as long as they are still at the top of your folder!"
	sed -ie '0,/GTOK/ s/GTOK[^ ]*//g' $SCRIPTA
	sed -ie '0,/USR/ s/USR[^ ]*//g' $SCRIPTA
	sed -ie '0,/GPG/ s/GPG[^ ]*//g' $SCRIPTA
	sed -i '1 i\\n\n\n' $SCRIPTA
	exit
fi



# Pulling github token, then 256b encrypting it to be stored.
# also checking operating system to know if you need to make changes or smth
if [ -z "$GTOK" ]; then

	#just checking OS type to make sure scrip twill work
	case "$OSTYPE" in
        linux*) echo "linuxchads win again" ;;
        darwin*) echo "run brew install gnu-sed to get the superior sed then edit the script to run using gsed." ;;
        bsd*) echo "If you can install gnu-sed use it. Or, you could go through the script and change sed syntax" ;;
        *) echo "what OS is $OSTYPE???" ;;
esac


	echo "what is your github token?"
	read -rs GTOKEN

	echo "what would you like your password to be?"
	read -rs PASSWD

	GTOKENC=$(echo $GTOKEN | openssl aes-256-cbc -a -salt -pass pass:$PASSWD -pbkdf2)

	echo -n "GTOK="$GTOKENC"" | sed 's/[[:space:]]//g' | cat -s - $SCRIPTA > temp && mv temp $SCRIPTA
	chmod +x $SCRIPTA
	exit
fi

# Grabbing user name, and then saving it
if [ -z "$USR"  ]; then
	echo "what is your user name?"
	read -r USR
	echo $USR
	sed  -i "1i USR=$USR" $SCRIPTA
else
	echo "is $USR your correct username?"
fi

# Creating GPG pair to sign on uploads then (not) saving it to file as no need to do that
if [ -z "$GPG" ]; then
	echo -e "would you like to make a gpg key to sign your update things \nThis will require you to open a web browser window \nif yes then press enter"
	read -r GPGYN

	if [ -z "$GPGYN" ]; then
		echo "do you need to create a gpg key? y for yes, enter for no."
		read -r GPGGENKEYYY

			if [ "GPGGENKEYY" = "y" ]; then
				#generating gpg key
				echo "follow these steps"
				gpg --generate-key
	else
	#Taking your gpg you created or not and setting it as your global key on git

	POSSGPG=$(gpg --list-secret-keys --keyid-format=long | grep sec | awk -F'/' '{print $2}' | awk '{print $1}'); git config --global user.signingkey $POSSGPG; git config --global commit.gpgsign true

	#putting a random text into $GPG to no longer ask you for the key
	sed -i "1i GPG=zinga" $SCRIPTA

	echo "to make your things verified you need to go to https://github.com/settings/gpg/new and add your key."

	#telling you what your pub gpg key for the already set global git gpg key.
	PUBGPG=$(gpg --armor --export $POSSGPG); echo -e "Your GPG key is: \n$PUBGPG"
			fi
		fi
	fi

# Grabbing repo name through using just the base name of the directory you are in.
# Will work great as long as you dont rename your repo.
REPO=$(basename $PWD)

echo "is $REPO your repository? press n if no."
read -r REPOSI

if [ "$REPOSI" = "n" ]; then
	ls
	echo "go to the dir you want to push then."
	exit
fi

# grabbing password to decrypt your stored github token ($GTOK).
echo "remember your password?"
read -rs PW2
UNENCGTOK=$(echo $GTOK | openssl aes-256-cbc -d -a -pass pass:$PW2 -pbkdf2)

# selecting files to be pushed
echo -e "do you want to add all the files in your directory ($PWD) to be edited?
\n>> y << for all files in ($PWD). If not type in file name"
read -r UPDATEE

	if [ "$UPDATEE" = "y" ]; then
	git add *
else
	git add $UPDATEE
	fi

# setting the commit message
echo "what would you like your commit message to be?"
read -r MESSAGE

git commit -S -m "$MESSAGE"

#and finally pushing to github
git push https://$UNENCGTOK@github.com/$USR/$REPO.git

#
