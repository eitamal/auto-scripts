function nvim --description "Run Neovim with with the ChatGPT.nvim OpenAI API key" --wraps nvim
    set --local script_path realpath "$(status dirname)/../chatgpt-nvim.sh"
    # HACK: call the script once to overcome the pinentry prompt issue
    $script_path >/dev/null; and OPENAI_API_KEY=($script_path) command nvim $argv
end
