# INFO
# This file is for testing and demonstration purposes only. The recipes do not
# perform any actually useful actions.
#───────────────────────────────────────────────────────────────────────────────

set quiet := true

# streaming
demo-progressbar:
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
demo-quickfix:
    rg --vimgrep "local"

demo-failure:
    #!/usr/bin/env zsh
    echo "failure"
    sleep 0.1
    exit 1

demo-success:
    #!/usr/bin/env zsh
    echo "success"
    sleep 0.1
    exit 0

# asks for input
demo-in-terminal:
    #!/usr/bin/env zsh
    echo "Enter something: "
    read -r input
    echo
    echo "Input was: $input"
