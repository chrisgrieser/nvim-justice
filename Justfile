set quiet

# streaming
progressbar-demo:
    #!/usr/bin/env zsh
    char="+"
    progress=""
    for i in {1..20}; do
        progress="$progress$char"
        printf "\33[2K\r"
        printf "$progress"
        sleep 0.1
    done
    printf "\33[2K\r"
    echo "Done."

# quickfix
quickfix-demo:
    rg --vimgrep "recipe"

failure-demo:
    #!/usr/bin/env zsh
    echo "failure"
    sleep 0.1
    exit 1

success-demo:
    #!/usr/bin/env zsh
    echo "success"
    sleep 0.1
    exit 0

# terminal
in-terminal-demo:
    #!/usr/bin/env zsh
    echo "Enter something: "
    read -r input
    echo
    echo "Input was: $input"

args-demo one two:
    echo {{ one }}
    echo {{ two }}
