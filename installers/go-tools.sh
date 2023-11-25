#!/usr/bin/env bash

pkgs=(
    golang.org/x/tools/cmd/goimports@latest
    mvdan.cc/gofumpt@latest
    golang.org/x/tools/gopls@latest
    github.com/ramya-rao-a/go-outline@latest
    github.com/go-delve/delve/cmd/dlv@latest
    github.com/josharian/impl@latest
    github.com/cweill/gotests/gotests@latest
    github.com/fatih/gomodifytags@latest
    go.uber.org/mock/mockgen@latest
    github.com/kyoh86/richgo@latest
    golang.org/x/vuln/cmd/govulncheck@latest
    github.com/onsi/ginkgo/v2/ginkgo@latest
    github.com/segmentio/golines@latest
    github.com/davidrjenni/reftools/cmd/fillstruct@latest
    golang.org/x/tools/cmd/guru@latest
    github.com/motemen/go-iferr/cmd/goiferr@latest
    honnef.co/go/tools/cmd/staticcheck@latest
)

for pkg in "${pkgs[@]}"; do
    go install "$pkg"
done

# golangci-lint
# binary will be $(go env GOPATH)/bin/golangci-lint
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
