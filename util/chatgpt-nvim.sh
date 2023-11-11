#!/usr/bin/env bash

gopass show --password --nosync --noparsing api/openai/chatgpt.nvim 2>/dev/null | tr -d '\n'
