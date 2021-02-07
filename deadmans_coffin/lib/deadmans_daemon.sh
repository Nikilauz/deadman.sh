#!/bin/bash

TIMER=20
TIMEOUT=$(( 60 * $2 ))
ALARM=/usr/local/share/deadman/*.ogg

function get_pointer() {
    while read
    do
        if [[ `echo $REPLY` =~ "slave pointer" ]]
        then
            POINTER+=(${REPLY:50:2})
        fi
    done < <(xinput)
}

function alarm() {
    pactl set-sink-mute @DEFAULT_SINK@ 0
    for (( i=1; `detect_mouse_move` == 0; i++ ))
    do
        pactl set-sink-volume @DEFAULT_SINK@ `echo "+"$((i * 5))"%"`
        paplay $ALARM
        pactl set-sink-volume @DEFAULT_SINK@ `echo "-"$((i * 5))"%"`
    done
}

function detect_mouse_move() {
    for p in "${POINTER[@]}"
    do
        res+=$(timeout `echo 0.$((10/${#POINTER[@]}))` xinput test $p)
    done
    if [[ ${#res} > 0 ]]
    then
        echo 1
    else
        echo 0
    fi
}

function countdown() {
    for i in $(eval echo "{1..$TIMER}")
    do
        if [[ `detect_mouse_move` == 1 ]]
        then
            echo 100
            return
        fi
        if [ $i == $TIMER ]
        then
            echo 100
            alarm
            return
        fi
        echo $(($i * (100 / $TIMER)))
    done
}

echo $$ > $1
get_pointer

while true
do
    INACTIVE=0
    while (( INACTIVE < TIMEOUT ))
    do
        if [[ `detect_mouse_move` == 1 ]]
        then
            INACTIVE=0
        else
            xdg-screensaver reset
            ((INACTIVE++))
        fi
        printf "\b\b\b\b\b\b$INACTIVE  "
    done
    printf "\n"
    (sleep 1 && wmctrl -F -a "deadman" -b add,above) &(countdown | zenity --progress --auto-close \
        --no-cancel --width=200 --title="deadman" --text="Hey, are you still alive?\nMove your mouse!")
done

