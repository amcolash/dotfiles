#!/bin/sh
# Doom One color scheme for Linux TTY
# Applied early during login process

if [ "$TERM" = "linux" ]; then
    # Black
    printf "\e]P02A2E38\e]P85F646A"
    # Red
    printf "\e]P1FF6C6B\e]P9FF6C6B"
    # Green
    printf "\e]P299BE65\e]PA99BE65"
    # Yellow
    printf "\e]P3ECBE7B\e]PBECBE7B"
    # Blue
    printf "\e]P451AFEF\e]PC51AFEF"
    # Magenta
    printf "\e]P5C678DD\e]PDC678DD"
    # Cyan
    printf "\e]P646D9FF\e]PE46D9FF"
    # White
    printf "\e]P7DFDFDF\e]PFBBC2CF"
    # Clear screen to apply colors
    clear
fi
