function with_openai --description 'Run a command with an OpenAI API key environment variable'
    set --local env_val $(get_api_key "openai/$argv[1]" 2> /dev/null | string trim)
    if test -z "$env_val"
        echo "No API key retrieved for the key: $_flag_key" >&2 && return 1
    end
    env --ignore-environment OPENAI_API_KEY=$env_val $argv[2..-1]
end

# function with_openai --description 'Run a command with an OpenAI API key environment variable'
#     argparse --ignore-unknown 'k/key=' 'p/pass=?!type --query "$_flag_value"' 'e/env=?' -- $argv
#     and argparse --min-args 1 -- $argv
#     or echo "Usage: with_openai [-k|--key <key>] [-p|--pass <pass>] [-e|--env <env>] <cmd> [<cmd_args>...]" >&2 && return 1
#
#     if not set --local --query _flag_key
#         echo "No key provided" >&2 && return 1
#     end
#     set --local --query _flag_pass || set _flag_pass get_api_key
#     set --local --query _flag_env || set _flag_env OPENAI_API_KEY
#
#     set --local cmd_args
#     set --local arg_idx 0
#     for arg in $argv
#         set arg_idx (math $arg_idx + 1)
#         if test "$arg" = --
#             set cmd_args $argv[$arg_idx..-1]
#             break
#         end
#         string match --quiet -- '-*' $arg || set cmd_args $cmd_args $arg
#     end
#
#     set --local env_val $($_flag_pass "openai/$_flag_key" 2> /dev/null | string trim)
#     if test -z "$env_val"
#         echo "No API key retrieved for the key: $_flag_key" >&2 && return 1
#     end
#     env -v --ignore-environment "$_flag_env=$env_val command $cmd_args"
# end
