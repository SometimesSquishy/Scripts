



#!/usr/bin/env bash
#To run this go into your folder you want to push and then run the script
#TO DO###
#make it not use cat to put at top of file
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


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

if [[ -z "$USR"  ]]; then
	echo "what is your user name?"
	read -r USR
	echo $USR
	sed  -i "1i USR=$USR" $SCRIPT_DIR/githubpush.sh
else
	echo "is $USR your correct username?"
fi

echo "what is your repo name?"
read REPO

echo "remember your password? ;)"
read -rs PW2
UNENCGTOK=$(echo $GTOK | openssl aes-256-cbc -d -a -pass pass:$PW2 -pbkdf2)

git push https://$UNENCGTOK@github.com/$USR/$REPO.git

#e
