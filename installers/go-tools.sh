#!/usr/bin/env bash

go install golang.org/x/tools/cmd/goimports@latest 
go install mvdan.cc/gofumpt@latest 
go install golang.org/x/tools/gopls@latest 
go install github.com/ramya-rao-a/go-outline@latest 
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/josharian/impl@latest
go install github.com/cweill/gotests/gotests@latest
go install github.com/fatih/gomodifytags@latest

# golangci-lint
# binary will be $(go env GOPATH)/bin/golangci-lint
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
