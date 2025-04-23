set quiet := true

masonPath := "$HOME/.local/share/nvim/mason/bin/"

#───────────────────────────────────────────────────────────────────────────────

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


#───────────────────────────────────────────────────────────────────────────────

stylua:
    #!/usr/bin/env zsh
    {{ masonPath }}/stylua --check --output-format=summary . && return 0
    {{ masonPath }}/stylua .
    echo "\nFiles formatted."

lua_ls_check:
    {{ masonPath }}/lua-language-server --check .
