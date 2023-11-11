function ll --wraps=eza --description 'List contents of directory using long format, including git status'
    # eza displays sizes in human readable format by default
    eza --long --git --icons=auto $argv
end
