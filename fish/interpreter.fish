# Override the open-interpreter command with the one that uses the OpenAI API key
function interpreter --description "Run open-interpreter with it's corresponding OpenAI API key" --wraps interpreter
    OPENAI_API_KEY=(pass openai/interpreter) $argv
end
