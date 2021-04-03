#!/bin/bash

function get_arg() {
    local RESULT="$(echo $1 | grep -E -o -e "$2.+")"
    ([[ $RESULT ]] && (echo ${RESULT:${#2}} | awk '{printf("%s", $1)}')) || echo $3
}

function get_pointer() {
    while read; do
        if [[ $(echo $REPLY) =~ "slave pointer" ]]; then
            local ID=$(echo $REPLY | grep -E -o -e "id=.+" | awk '{printf("%s", $1)}')
            POINTER+=(${ID:3})
        fi
    done < <(xinput)
}

function alarm() {
    for ((i = 1; $(detect_mouse_move) == 0; i++)); do
        paplay --volume $(($i * 10000)) $ALARM_FILE
        (( i == 42 )) && cvlc https://tinyurl.com/8dz9z78p --play-and-exit
    done
}

function detect_mouse_move() {
    function detect() {
        local RES=""
        for p in "${POINTER[@]}"; do
            RES+=$(timeout $(echo 0.$((10 / ${#POINTER[@]}))) xinput test $p)
        done
        echo $RES
    }
    if [[ $(
        detect &
        sleep 1
        kill $! 2>/dev/null
    ) ]]; then
        echo 1
    else
        echo 0
    fi
}

function countdown() {
    for i in $(eval echo "{1..$COUNTDOWN}"); do
        if (($(detect_mouse_move))); then
            echo 100
            return
        fi
        if [ $i == $COUNTDOWN ]; then
            echo 100
            alarm
            return
        fi
        echo $(($i * (100 / $COUNTDOWN)))
    done
}

COUNTDOWN=$(get_arg "$(echo "$@")" "-c " "20")
TIMER=$((60 * $(get_arg "$(echo "$@")" "-t " "5")))
ALARM_FILE=$(get_arg "$(echo "$@")" "--alarm-file=")

echo $COUNTDOWN

get_pointer

while true; do
    INACTIVE=0
    while ((INACTIVE < TIMER)); do
        if (($(detect_mouse_move))); then
            INACTIVE=0
        else
            xdg-screensaver reset
            ((INACTIVE++))
        fi
        printf "\b\b\b\b\b\b$INACTIVE  "
    done
    printf "\n"
    (sleep 1 && wmctrl -F -a "deadman" -b add,above) &
    (countdown | zenity --progress --auto-close \
        --no-cancel --width=200 --title="deadman" --text="Hey, are you still alive?\nMove your mouse!")
done
