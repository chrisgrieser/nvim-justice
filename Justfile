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
    echo "failure"
    sleep 0.1
    exit 1

demo-success:
    echo "success"
    sleep 0.1
    exit 0

