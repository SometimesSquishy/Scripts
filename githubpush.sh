GPGYN=2621838FD499A791
GTOK=U2FsdGVkX1+KUmNRBbeT8y/W5z50/QQM3AmXZ+kIF6L2XLeXgip9ozGkFa0dBKXRE4VQaFQ08lR1oqwq9gS44A==
USR=sometimessquishy





#!/usr/bin/env bash
#To run this go into your folder you want to push and then run the script
#TO DO###
#make it not use cat to put at top of file


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )




# Pulling github token, then 256b encrypting it to be stored.
if [[ -z "$GTOK" ]]; then
	echo "what is your github token?"
	read -rs GTOKEN

	echo "what would you like your password to be?"
	read -rs PASSWD

	GTOKENC=$(echo $GTOKEN | openssl aes-256-cbc -a -salt -pass pass:$PASSWD -pbkdf2)

	echo -n "GTOK="$GTOKENC"" | sed 's/[[:space:]]//g' | cat -s - $SCRIPT_DIR/githubpush.sh > temp && mv temp $SCRIPT_DIR/githubpush.sh
	chmod +x $SCRIPT_DIR/githubpush.sh
	exit
fi




# Grabbing user name, and then saving it
if [[ -z "$USR"  ]]; then
	echo "what is your user name?"
	read -r USR
	echo $USR
	sed  -i "1i USR=$USR" $SCRIPT_DIR/githubpush.sh
else
	echo "is $USR your correct username?"
fi



# Creating GPG pair to sign on uploads, then saving private key in file.
if [[ -z "$GPG" ]]; then
	echo -e "would you like to make a gpg key to sign your update things \nThis will require you to open a web browser window \nif yes then press enter"
	read -r GPGYN

	if [[ -z "$GPGYN" ]]; then
		echo "do you need to create a gpg key? y for yes, enter for no."
		read -r GPGGENKEYYY

			if [[ "GPGGENKEYY" = "y" ]]; then
		gpg --generate-key
			else

	POSSGPG=$(gpg --list-secret-keys --keyid-format=long | grep sec | awk -F'/' '{print $2}' | awk '{print $1}'); git config --global user.signingkey $POSSGPG; git config --global commit.gpgsign true
	sed -i "1i GPGYN=$POSSGPG" $SCRIPT_DIR/githubpush.sh

	echo "to make your things verified you need to go to https://github.com/settings/gpg/new and add your key."


	PUBGPG=$(gpg --armor --export $POSSGPG); echo "Your GPG key is:\n $PUBGPG"

	fi
fi

fi

# Grabbing repo name through using just the base name of the directory you are in.
# Will work great as long as you dont rename your repo.
REPO=$(basename $PWD)

echo "is $REPO youre repository? press n if no."
read -r REPOSI


if [[ "$REPOSI" = "n" ]]; then
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
