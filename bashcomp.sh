#!/usr/bin/env bash

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

declare -A CMD_EXTS
CMD_EXTS[sxiv]="jpg jpeg png gif bmp tiff tif webp svg ico ppm pgm pbm xpm heic avif"
CMD_EXTS[sxbv]="pdf djvu cbz cbr epub xps"
CMD_EXTS[mpv]="mp4 mkv avi mov webm flv wmv m4v ts m2ts vob 3gp mp3 flac ogg wav aac m4a opus wma"
CMD_EXTS[nvim]="txt md rst log conf ini toml yaml yml json xml sh py js ts c h cpp go rs lua vim css html"
CMD_EXTS[vim]="txt md rst log conf ini toml yaml yml json xml sh py js ts c h cpp go rs lua vim css html"
CMD_EXTS[vi]="txt md rst log conf ini toml yaml yml json xml sh py js ts c h cpp go rs lua vim css html"
CMD_EXTS[cat]="txt md rst log conf ini toml yaml yml json xml sh py js ts c h cpp hpp go rs lua vim css html"
CMD_EXTS[bat]="txt md rst log conf ini toml yaml yml json xml sh py js ts c h cpp hpp go rs lua vim css html"
CMD_EXTS[less]="txt md rst log conf ini toml yaml yml json xml sh py js ts c h cpp hpp go rs lua vim css html log"
CMD_EXTS[tail]="log txt"
CMD_EXTS[head]="log txt"
CMD_EXTS[tar]="tar gz bz2 xz tgz tbz2 txz"
CMD_EXTS[unzip]="zip"
CMD_EXTS[unrar]="rar"
CMD_EXTS[gzip]="gz"
CMD_EXTS[gunzip]="gz"

declare -A CMD_CONTEXT
CMD_CONTEXT[cp]="file:dir"
CMD_CONTEXT[mv]="file:dir"
CMD_CONTEXT[ln]="file:dir"
CMD_CONTEXT[rsync]="path:path"
CMD_CONTEXT[scp]="file:dir"
CMD_CONTEXT[install]="file:dir"
CMD_CONTEXT[chmod]="file:both"
CMD_CONTEXT[chown]="file:both"
CMD_CONTEXT[chgrp]="file:both"
CMD_CONTEXT[mkdir]="dir:dir"
CMD_CONTEXT[touch]="file:file"
CMD_CONTEXT[diff]="file:file"
CMD_CONTEXT[cmp]="file:file"
CMD_CONTEXT[zip]="file:both"
CMD_CONTEXT[unzip]="file:dir"
CMD_CONTEXT[tar]="file:dir"
CMD_CONTEXT[find]="path:path"
CMD_CONTEXT[grep]="file:dir"
CMD_CONTEXT[rg]="file:dir"
CMD_CONTEXT[ag]="file:dir"

SPECIAL_CMDS="sudo git docker systemctl"

quote_string() {
    local s="$1"
    if [[ "$s" == *[[:space:]]* || "$s" == *"'"* || "$s" == *'"'* ]]; then
        s="${s//\'/\'\\\'\'}"
        echo "'$s'"
    else
        echo "$s"
    fi
}

get_arg_type() {
    local cmd="$1"
    local i="$2"
    local ctx="${CMD_CONTEXT[$cmd]}"
    [[ -z "$ctx" ]] && echo "both" && return
    IFS=':' read -ra a <<< "$ctx"
    [[ $i -le ${#a[@]} ]] && echo "${a[$((i-1))]}" || echo "${a[-1]}"
}

complete_dir() {
    local word="$1"
    local prefix="$2"
    local after="$3"

    local base="."
    local sub="$word"

    [[ "$word" == */* ]] && base="${word%/*}" && sub="${word##*/}"

    local dirs
    dirs=$(find "$base" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sed 's|^\./||' | grep -i "^$sub" | sort)

    local count
    count=$(echo "$dirs" | grep -c .)

    if [[ $count -eq 1 ]]; then
        local c="${dirs%/}/"
        READLINE_LINE="${prefix}${c}${after}"
        READLINE_POINT=$(( ${#prefix} + ${#c} ))
            return
    fi

    if [[ $count -gt 1 ]]; then
        local c
        c=$(echo "$dirs" | fzf --height=50% --layout=reverse --border --prompt="cd ❯ " --query="$sub" 2>/dev/tty)
        if [[ -n "$c" ]]; then
            c="${c%/}/"
            READLINE_LINE="${prefix}${c}${after}"
            READLINE_POINT=$(( ${#prefix} + ${#c} ))
        fi
        return
    fi

    local c
    c=$(find "$base" -maxdepth 4 -type d 2>/dev/null | sed 's|^\./||' | fzf --height=50% --layout=reverse --border --prompt="z ❯ " 2>/dev/tty)

    if [[ -n "$c" ]]; then
        c="${c%/}/"
        READLINE_LINE="${prefix}${c}${after}"
        READLINE_POINT=$(( ${#prefix} + ${#c} ))
    fi
}

_fzf_tab_complete() {
    local cur="${READLINE_LINE}"
    local point="${READLINE_POINT}"

    local before="${cur:0:$point}"
    local after="${cur:$point}"
    local word="${before##* }"
    local prefix="${before:0:$((point - ${#word}))}"

        local cmd
        cmd=$(echo "$before" | awk '{print $1}')

        for s in $SPECIAL_CMDS; do
            [[ "$cmd" == "$s" ]] && return
        done

        if [[ "$cmd" == "cd" ]]; then
            complete_dir "$word" "$prefix" "$after"
            return
        fi

        if [[ -n "${CMD_CONTEXT[$cmd]}" ]]; then
            local argn
            argn=$(echo "$before" | wc -w)
            local type
            type=$(get_arg_type "$cmd" "$argn")

            local base="."
            local sub="$word"

            [[ "$word" == */* ]] && base="${word%/*}" && sub="${word##*/}"

            local candidates
            candidates=$(find "$base" -maxdepth 4 2>/dev/null | sed 's|^\./||' | grep -i "^$sub" | sort -u)

            if [[ -z "$candidates" ]]; then
                candidates=$(find "$base" -maxdepth 4 2>/dev/null | sed 's|^\./||' | sort -u)
            fi

            local c
            c=$(echo "$candidates" | fzf --height=50% --layout=reverse --border --prompt="$cmd ❯ " --query="$sub" 2>/dev/tty)

            if [[ -n "$c" ]]; then
                c=$(quote_string "$c")
                READLINE_LINE="${prefix}${c} ${after}"
                READLINE_POINT=$(( ${#prefix} + ${#c} + 1 ))
            fi

            return
        fi

        if [[ -n "${CMD_EXTS[$cmd]}" ]]; then
            local exts="${CMD_EXTS[$cmd]}"
            local base="."
            [[ "$word" == */* ]] && base="${word%/*}"

            local pattern=""
            for e in $exts; do
                pattern="$pattern -o -iname '*.$e'"
            done
            pattern="${pattern# -o }"

            local files dirs merged c

            files=$(eval "find \"$base\" -maxdepth 1 -type f \( $pattern \) 2>/dev/null" \
                | sed 's|^\./||')

            dirs=$(find "$base" -maxdepth 1 -type d 2>/dev/null \
                | sed 's|^\./||' \
                | grep -Ev '(^\.git$|/\.git$|^\.?$|^\.\.?$)')

            merged=$(printf "%s\n%s\n" "$dirs" "$files" | sed '/^$/d' | sort -u)

            if [[ -z "$merged" ]]; then
                merged=$(find "$base" -maxdepth 1 -type f -o -type d 2>/dev/null \
                    | sed 's|^\./||' \
                    | grep -Ev '(^\.git$|/\.git$|^\.?$|^\.\.?$)' \
                    | sort -u)
            fi

            c=$(echo "$merged" | fzf \
                --height=50% \
                --layout=reverse \
                --border \
                --prompt="$cmd ❯ " \
                --query="$word" \
                2>/dev/tty)

            if [[ -n "$c" ]]; then
                [[ -d "$c" ]] && c="${c%/}/"
                c=$(quote_string "$c")
                READLINE_LINE="${prefix}${c} ${after}"
                READLINE_POINT=$(( ${#prefix} + ${#c} + 1 ))
            fi

            return
        fi

        local candidates
        if [[ -z "$prefix" ]]; then
            candidates=$(compgen -A command -A alias -A builtin -A function -- "$word")
        else
            candidates=$(compgen -f -- "$word")
        fi

        local c
        c=$(echo "$candidates" | fzf --height=50% --layout=reverse --border --prompt="❯ " --query="$word" 2>/dev/tty)

        if [[ -n "$c" ]]; then
            c=$(quote_string "$c")
            READLINE_LINE="${prefix}${c} ${after}"
            READLINE_POINT=$(( ${#prefix} + ${#c} ))
        fi
}

_fzf_tab_complete_internal() {
    _fzf_tab_complete
}

bind -x '"\t": _fzf_tab_complete'
