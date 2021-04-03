#!/bin/bash

SOURCE="https://raw.githubusercontent.com/Nikilauz/deadman.sh/main"
MAIN=deadman
DAEMON=deadmans_daemon.sh
ALARM=alarm.ogg
BIN=/usr/local/bin
SHARE=/usr/local/share/deadman

rm -f $BIN/$MAIN $BIN/$DAEMON
wget -P $BIN $SOURCE/$MAIN $SOURCE/$DAEMON
chmod 755 $BIN/$MAIN $BIN/$DAEMON

rm -r -f $SHARE
mkdir -p $SHARE
wget -P $SHARE $SOURCE/$ALARM

zenity --question --cancel-label="Ok" --ok-label="Run deadman" --title="deadman" --width=250 --icon-name=face-devilish \
    --text="Everything is done - thanks for installing!"
if ! (($?)); then
    deadman
fi
