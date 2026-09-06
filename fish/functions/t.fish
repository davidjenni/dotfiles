function t --description "Attach to a tmux session, either a formerly visited zoxide directory or named after the current directory '.'"
    argparse --move-unknown --unknown-arguments=none 'h/help&' -- $argv || return
    if set -ql _flag_help
        echo "Attach to a tmux session, either a formerly visited zoxide directory or named after the current directory '.'"
        echo "Usage: t [zoxide_dir_query | '.'] [-h | --help]"
        return 1
    end
    set -l _candidate $argv
    if test "$_candidate" = "."
        set _dir $PWD
    else
        set -l _Q (test -n "$_candidate"; and echo "$_candidate"; or echo '')
        set _dir (zoxide query -l | fzf --ansi --query=$_Q \
            --height=50% --layout=reverse-list --border --margin=1 --padding=1)
        echo "dir=$_dir"
        if test -z "$_dir"
            # user bailed out of fzf
            return
        end
    end
    set -l _session (string replace -ra '[.:]' _ (path basename $_dir))

    # '-t=' forces an exact match instead of tmux's prefix matching
    if not tmux has-session -t="$_session" 2>/dev/null
        tmux new-session -d -s $_session -c $_dir
    end

    if set -q TMUX
        # already inside tmux: attaching would nest, so switch the client instead
        tmux switch-client -t="$_session"
    else
        tmux attach-session -t="$_session"
    end
end
