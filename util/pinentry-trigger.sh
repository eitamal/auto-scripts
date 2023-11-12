#!/usr/bin/env bash

# HACK: The purpose of this script is to trigger the pinentry prompt if it's
# necessary for non-interactive processes that rely on gpg (e.g., pass).
gpg --sign </dev/null >/dev/null
