function get_api_key --argument-names api_key --description 'Get an API key from gopass'
    if test (count $argv) -ne 1; or test -z "$api_key"
        echo "Usage: get_api_key <api_key>" >&2
        return 1
    end

    set --local api_path $argv[1]
    echo "$(gopass show --password api/$api_path 2> /dev/null)"
end
