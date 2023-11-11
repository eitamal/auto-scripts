function ls --wraps=eza --description 'List contents of directory'
    # eza uses colours by default, so we don't need to pass --color
    eza --icons=auto $argv
end
