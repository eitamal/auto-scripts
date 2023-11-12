function lt --wraps=eza --description 'List a contents tree of the directory including icons'
    eza --tree --icons=auto $argv
end
