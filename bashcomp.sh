#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Smart Bash Autocomplete
# ─────────────────────────────────────────────────────────────

# ── History Configuration ────────────────────────────────────
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ── File Type Mappings ───────────────────────────────────────
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

# ── Directory Commands ───────────────────────────────────────
DIR_CMDS="cd pushd popd rmdir tree"

# ── Context-Aware Command Mapping ────────────────────────────
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

# ── Special Commands ─────────────────────────────────────────
SPECIAL_CMDS="sudo git docker systemctl"

# ── Helper: Count arguments before cursor ─────────────────────
count_args() {
    local line="$1"
    line="${line%%[[:space:]]*}"
    local args="${line#* }"
    [[ "$args" == "$line" ]] && echo 0 && return
    echo "$args" | wc -w | tr -d ' '
}

# ── Helper: Get argument type ─────────────────────────────────
get_arg_type() {
    local cmd="$1"
    local arg_num="$2"
    
    local context="${CMD_CONTEXT[$cmd]}"
    [[ -z "$context" ]] && echo "both" && return
    
    if [[ "$context" == *"*:"* ]]; then
        echo "$context" | grep -o '\*:[^ ]*' | cut -d: -f2
        return
    fi
    
    local IFS=':' read -ra positions <<< "$context"
    if [[ $arg_num -le ${#positions[@]} ]]; then
        echo "${positions[$((arg_num - 1))]}"
    else
        echo "${positions[-1]}"
    fi
}

# ── Helper: Quote string if needed ────────────────────────────
quote_string() {
    local str="$1"
    if [[ "$str" == *[[:space:]]* ]] || [[ "$str" == *"'"* ]] || [[ "$str" == *'"'* ]]; then
        str="${str//\'/\'\\\'\'}"
        echo "'$str'"
    else
        echo "$str"
    fi
}

# ── Helper: Find files/dirs by type ───────────────────────────
find_candidates() {
    local type="$1"
    local search_dir="$2"
    local prefix="$3"
    local extensions="$4"
    
    [[ -z "$search_dir" ]] && search_dir="."
    
    local find_cmd="find \"$search_dir\" -maxdepth 4"
    
    case "$type" in
        dir)
            find_cmd="$find_cmd -type d"
            ;;
        file)
            find_cmd="$find_cmd -type f"
            if [[ -n "$extensions" ]]; then
                find_cmd="$find_cmd ("
                local first=1
                for ext in $extensions; do
                    [[ $first -eq 0 ]] && find_cmd="$find_cmd -o"
                    find_cmd="$find_cmd -iname '*.${ext}'"
                    first=0
                done
                find_cmd="$find_cmd )"
            fi
            ;;
        cmd)
            find_cmd="$find_cmd -type f -executable"
            ;;
        both|path)
            ;;
    esac
    
    local escaped_prefix=$(printf '%s\n' "$prefix" | sed 's/[.*[\^$]/\\&/g')
    eval "$find_cmd" 2>/dev/null \
        | sed 's|^\./||' \
        | grep -i "^${escaped_prefix}" \
        | sort -u
}

# ── Helper: Complete directories ──────────────────────────────
complete_dir() {
    local word="$1"
    local prefix="$2"
    local after="$3"
    local use_zoxide="$4"
    
    local search_base search_prefix
    if [[ "$word" == */* ]]; then
        search_base="${word%/*}/"
        search_prefix="${word##*/}"
    else
        search_base="./"
        search_prefix="$word"
    fi
    
    local local_dirs
    local_dirs=$(
        find "$search_base" -maxdepth 1 -mindepth 1 -type d 2>/dev/null \
        | sed 's|^\./||' \
        | grep -i "^$(printf '%s\n' "$search_prefix" | sed 's/[.*[\^$]/\\&/g')" \
        | sort
    )
    
    local count=0
    [[ -n "$local_dirs" ]] && count=$(echo "$local_dirs" | grep -c .)
    
    if [[ $count -eq 1 ]]; then
        local chosen="$local_dirs"
        chosen="${chosen%/}/"
        READLINE_LINE="${prefix}${chosen}${after}"
        READLINE_POINT=$(( ${#prefix} + ${#chosen} ))
        return 0
    elif [[ $count -gt 1 ]]; then
        local chosen
        chosen=$(echo "$local_dirs" | fzf --height=50% --layout=reverse --border=rounded --prompt="📁 cd ❯ " --info=inline --bind="tab:down,shift-tab:up" --select-1 --exit-0 --query="$search_prefix" 2>/dev/tty)
        if [[ -n "$chosen" ]]; then
            chosen="${chosen%/}/"
            READLINE_LINE="${prefix}${chosen}${after}"
            READLINE_POINT=$(( ${#prefix} + ${#chosen} ))
        fi
        return 0
    fi
    
    if [[ "$use_zoxide" == "yes" ]]; then
        local chosen
        chosen=$(
            zoxide query -l 2>/dev/null \
            | grep -i "$(printf '%s\n' "$search_prefix" | sed 's/[.*[\^$]/\\&/g')" \
            | fzf --height=50% --layout=reverse --border=rounded --prompt="📁 zoxide ❯ " --info=inline --bind="tab:down,shift-tab:up" --select-1 --exit-0 --query="$search_prefix" 2>/dev/tty
        )
        if [[ -n "$chosen" ]]; then
            chosen="${chosen%/}/"
            READLINE_LINE="${prefix}${chosen}${after}"
            READLINE_POINT=$(( ${#prefix} + ${#chosen} ))
        fi
    fi
}

# ── Helper: Handle sudo/special commands ──────────────────────
handle_special() {
    local cur="$1"
    local point="$2"
    
    if [[ "$cur" =~ ^(sudo|doas|nice|time)\ + ]]; then
        local before_special="${cur:0:point}"
        local after_special="${cur:point}"
        local cmd_part="${before_special##* }"
        
        READLINE_LINE="$cmd_part"
        READLINE_POINT=${#cmd_part}
        
        _fzf_tab_complete_internal
        
        READLINE_LINE="$cur"
        READLINE_POINT="$point"
        return 0
    fi
    
    return 1
}

# ── Main Completion Function ──────────────────────────────────
_fzf_tab_complete() {
    local cur="${READLINE_LINE}"
    local point="${READLINE_POINT}"
    
    local before="${cur:0:$point}"
    local after="${cur:$point}"
    local word="${before##* }"
    local prefix="${before:0:$((point - ${#word}))}"
    
    local cmd
    cmd=$(echo "$before" | awk '{print $1}')
    
    local arg_num
    arg_num=$(count_args "$before")
    
    for special in $SPECIAL_CMDS; do
        if [[ "$cmd" == "$special" ]]; then
            handle_special "$cur" "$point"
            return
        fi
    done
    
    for dir_cmd in $DIR_CMDS; do
        if [[ "$cmd" == "$dir_cmd" ]]; then
            local use_zoxide="no"
            [[ "$cmd" == "cd" ]] && use_zoxide="yes"
            complete_dir "$word" "$prefix" "$after" "$use_zoxide"
            return
        fi
    done
    
    if [[ -n "${CMD_CONTEXT[$cmd]}" ]]; then
        local arg_type
        arg_type=$(get_arg_type "$cmd" "$arg_num")
        
        local search_dir="."
        local search_prefix="$word"
        
        if [[ "$word" == */* ]]; then
            search_dir="${word%/*}"
            search_prefix="${word##*/}"
            [[ -z "$search_dir" ]] && search_dir="."
        fi
        
        local extensions=""
        if [[ -n "${CMD_EXTS[$cmd]}" ]]; then
            extensions="${CMD_EXTS[$cmd]}"
        fi
        
        local candidates
        candidates=$(find_candidates "$arg_type" "$search_dir" "$search_prefix" "$extensions")
        
        local count=0
        [[ -n "$candidates" ]] && count=$(echo "$candidates" | grep -c .)
        
        if [[ $count -eq 0 ]]; then
            echo -en "\a"
            return
        elif [[ $count -eq 1 ]]; then
            local match
            match=$(echo "$candidates" | head -n1)
            match=$(quote_string "$match")
            [[ -d "$match" ]] && match="${match%/}/" || match="${match} "
            READLINE_LINE="${prefix}${match}${after}"
            READLINE_POINT=$(( ${#prefix} + ${#match} ))
        else
            local icon="📄"
            [[ "$arg_type" == "dir" ]] && icon="📁"
            [[ "$arg_type" == "cmd" ]] && icon="⚡"
            
            local chosen
            chosen=$(echo "$candidates" | fzf --height=50% --layout=reverse --border=rounded --prompt="${icon} ${cmd} ❯ " --info=inline --bind="tab:down,shift-tab:up" --select-1 --exit-0 --query="$search_prefix" 2>/dev/tty)
            
            if [[ -n "$chosen" ]]; then
                chosen=$(quote_string "$chosen")
                [[ -d "$chosen" ]] && chosen="${chosen%/}/" || chosen="${chosen} "
                READLINE_LINE="${prefix}${chosen}${after}"
                READLINE_POINT=$(( ${#prefix} + ${#chosen} ))
            fi
        fi
        return
    fi
    
    if [[ -n "${CMD_EXTS[$cmd]}" ]]; then
        local exts="${CMD_EXTS[$cmd]}"
        local search_dir="${word:-.}"
        
        if [[ "$search_dir" == */* ]]; then
            search_dir="${search_dir%/*}"
        fi
        
        local find_cmd="find \"$search_dir\" -maxdepth 4 -type f ("
        local first=1
        for ext in $exts; do
            [[ $first -eq 0 ]] && find_cmd="$find_cmd -o"
            find_cmd="$find_cmd -iname '*.${ext}'"
            first=0
        done
        find_cmd="$find_cmd )"
        
        local chosen
        chosen=$(
            eval "$find_cmd" 2>/dev/null \
            | sed 's|^\./||' \
            | sort -u \
            | fzf --height=50% --layout=reverse --border=rounded --prompt="${cmd} ❯ " --info=inline --bind="tab:down,shift-tab:up" --select-1 --exit-0 --query="$word" 2>/dev/tty
        )
        
        if [[ -n "$chosen" ]]; then
            chosen=$(quote_string "$chosen")
            chosen="${chosen} "
            READLINE_LINE="${prefix}${chosen}${after}"
            READLINE_POINT=$(( ${#prefix} + ${#chosen} ))
        fi
        return
    fi
    
    local candidates
    if [[ -z "$prefix" || "$prefix" =~ ^[[:space:]]+$ ]]; then
        candidates=$(compgen -A function -A alias -A builtin -A command -- "$word" 2>/dev/null | sort -u)
    else
        candidates=$(compgen -f -- "$word" 2>/dev/null | sort -u)
    fi
    
    local count=0
    [[ -n "$candidates" ]] && count=$(echo "$candidates" | grep -c .)
    
    if [[ $count -eq 0 ]]; then
        echo -en "\a"
        return
    elif [[ $count -eq 1 ]]; then
        local match
        match=$(echo "$candidates" | head -n1)
        match=$(quote_string "$match")
        [[ -d "$match" ]] && match="${match%/}/" || match="${match} "
        READLINE_LINE="${prefix}${match}${after}"
        READLINE_POINT=$(( ${#prefix} + ${#match} ))
    else
        local chosen
        chosen=$(echo "$candidates" | fzf --height=50% --layout=reverse --border=rounded --prompt="❯ " --info=inline --bind="tab:down,shift-tab:up" --select-1 --exit-0 --query="$word" 2>/dev/tty)
        
        if [[ -n "$chosen" ]]; then
            chosen=$(quote_string "$chosen")
            [[ -d "$chosen" ]] && chosen="${chosen%/}/" || chosen="${chosen} "
            READLINE_LINE="${prefix}${chosen}${after}"
            READLINE_POINT=$(( ${#prefix} + ${#chosen} ))
        fi
    fi
}

# ── Internal function to avoid recursion issues ───────────────
_fzf_tab_complete_internal() {
    _fzf_tab_complete
}

# ── Bind Tab ─────────────────────────────────────────────────
bind -x '"\t": _fzf_tab_complete'

echo "✓ Smart bash autocomplete loaded (fzf + zoxide)"
