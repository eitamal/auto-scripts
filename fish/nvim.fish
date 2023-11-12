function nvim --description "Run Neovim with with the ChatGPT.nvim OpenAI API key" --wraps nvim
    set --local script_path realpath
    sh (realpath "$(status dirname)/../util/pinentry-trigger.sh"); and command nvim $argv
end
