#!/bin/bash

SOURCE="https://raw.githubusercontent.com/Nikilauz/deadman.sh/main"
MAIN=deadman
DAEMON=deadmans_daemon.sh
ALARM=alarm.ogg
BIN=/usr/local/bin
SHARE=/usr/local/share/deadman

sudo rm -f $BIN/$MAIN $BIN/$DAEMON
sudo wget -P $BIN $SOURCE/$MAIN $SOURCE/$DAEMON
sudo chmod 755 $BIN/$MAIN $BIN/$DAEMON

sudo rm -r -f $SHARE
sudo mkdir -p $SHARE
sudo wget -P $SHARE $SOURCE/$ALARM

zenity --question --cancel-label="Ok" --ok-label="Run deadman" --title="deadman" --width=250 --icon-name=face-devilish \
    --text="Everything is done - thanks for installing!"
if ! (($?)); then
    deadman
fi
