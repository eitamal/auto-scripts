# function nvim --description "Run Neovim with with the ChatGPT.nvim OpenAI API key" --wraps nvim
#     set --local --export OPENAI_API_KEY $(get_api_key "openai/chatgpt.nvim" 2> /dev/null | string trim)
#     if test -z "$OPENAI_API_KEY"
#         echo "No API key retrieved for the key: $_flag_key" >&2 && return 1
#     end
#     command nvim $argv
# end

function nvim
    OPENAI_API_KEY=(/home/pluto/dev/scripts/chatgpt-nvim.sh) command nvim $argv
end
