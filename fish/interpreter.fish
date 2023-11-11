# Override the open-interpreter command with the one that uses the OpenAI API key
function interpreter --description "Run Open Interpreter with it's corresponding OpenAI API key" --wraps interpreter
    with_openai open-interpreter $(command -s interpreter) $argv
end
