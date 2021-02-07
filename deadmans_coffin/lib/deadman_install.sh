#!/bin/bash

MAIN=deadman
DAEMON=deadmans_daemon.sh
BIN=/usr/local/bin/
SHARE=/usr/local/share/$MAIN
ALARM=../media/alarm.ogg

ASKPASS=$(which ssh-askpass)
if ! [[ ASKPASS ]]
then
	zenity --info --text="Please install 'ssh-askpass' to use this installer!"
	xdg-open "apt:ssh-askpass"
else
    SUDO_ASKPASS=$ASKPASS sudo -A rm -r -f $SHARE
    if [[ $? == 1 ]]
    then
        exit
    fi
    
    sudo cp $MAIN $BIN
    sudo chmod 755 $BIN$MAIN

    sudo cp $DAEMON $BIN
    sudo chmod 755 $BIN$DAEMON

    sudo mkdir -p $SHARE
    sudo cp $ALARM $SHARE

    zenity --question --cancel-label="Ok" --ok-label="Run deadman" --title="deadman" --width=250 --icon-name=face-devilish \
        --text="Everything is done - thanks for installing!\nYou can now remove the coffin (before it begins to smell...)."
    if [[ $? != 1 ]]
    then
        deadman
    fi
fi

