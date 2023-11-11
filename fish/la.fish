function la --wraps=eza --description 'List contents of directory, including hidden files and git status'
    # eza's --all doesn't include . and .. - which is what we want
    eza --all --long --git --icons=auto $argv
end
