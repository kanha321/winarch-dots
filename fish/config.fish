if status is-interactive
    # Pretty system greeting with fastfetch (only if inside Windows Terminal and interactive TTY)
    function fish_greeting
        if type -q fastfetch; and test -t 1
            # Run fastfetch only if terminal line contains "Windows Terminal"
            if fastfetch 2>/dev/null | string match -q "*term*Windows Terminal*"
                clear
                fastfetch
            end
        end
    end

    # cls => clear + fastfetch
    alias cls 'clear; and type -q fastfetch; and fastfetch'

    # Prompt (starship)
    if type -q starship
        starship init fish | source
    end

    # Smarter cd (zoxide)
    if type -q zoxide
        zoxide init fish --cmd cd | source
        alias z "cd"
    end

    # eza as default ls + helpful variations
    if type -q eza
        set -l eza_common --icons=auto --group --git --time-style=relative --color=auto
        alias ls "eza $eza_common"
        alias la "eza -a $eza_common"
        alias ll "eza -lah $eza_common"
        alias lt "eza -T --level=2 $eza_common"
        alias tree "eza -T $eza_common"
        alias lS "eza -lah --sort=size $eza_common"
        alias lD "eza -lah --sort=date $eza_common"
    end

    # Nicer Fish colors (adjust to taste)
    set -g fish_color_normal normal
    set -g fish_color_command brcyan
    set -g fish_color_param white
    set -g fish_color_quote brgreen
    set -g fish_color_comment brblack
    set -g fish_color_error brred
    set -g fish_color_operator bryellow
    set -g fish_color_valid_path --underline
    set -g fish_color_autosuggestion brblack
    set -g fish_color_selection white --bold --background=blue
    set -g fish_color_search_match --background=brblack

    # Windows Terminal tweaks
    if set -q WT_SESSION
        set -gx COLORTERM truecolor
        set -gx PAGER 'less -R'
    end

    # WSL helpers: open in Windows, clipboard, browser
    if test -n "$WSL_DISTRO_NAME"
        # Open files/dirs with default Windows app
        function open --description 'Open path with Windows default app'
            set target $argv[1]
            if test -z "$target"
                set target .
            end

            if type -q wslview
                wslview "$target"
            else if type -q explorer.exe
                set -l winpath (wslpath -w "$target" 2>/dev/null); or set winpath "$target"
                cmd.exe /c start "" "$winpath" >/dev/null 2>&1
            else if type -q xdg-open
                xdg-open "$target" >/dev/null 2>&1 &
            end
        end
        alias o open

        # Clipboard: pbcopy/pbpaste via Windows
        if type -q clip.exe
            function pbcopy --description 'Copy to Windows clipboard'
                if test (count $argv) -gt 0
                    printf "%s" "$argv" | clip.exe
                else
                    cat | clip.exe
                end
            end
        end
        if type -q powershell.exe
            function pbpaste --description 'Paste from Windows clipboard'
                powershell.exe -NoProfile -Command "Get-Clipboard" | string replace -r '\r' ''
            end
        end

        # Prefer Windows-aware browser
        if type -q wslview
            set -gx BROWSER wslview
        end
    end
end
