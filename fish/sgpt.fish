# Override the shell_gpt command with the one that uses the OpenAI API key
function sgpt --description "Run shell_gpt with it's corresponding OpenAI API key" --wraps sgpt
    with_openai sgpt $(command -s sgpt) $argv
end
