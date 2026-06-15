#!/usr/bin/env bash

_do_sim_vcs_completions()
{
    local curr

    curr="${COMP_WORDS[COMP_CWORD]}"

    local opts="vcs-cli vcs-gui vcs-fsim"

    COMPREPLY=( $(compgen -W "${opts}" -- ${curr}) )
}

complete -F _do_sim_vcs_completions ./do_sim_vcs.sh