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
    gorm.io/gen/tools/gentool@latest
    github.com/haya14busa/goplay/cmd/goplay@latest
    mvdan.cc/sh/v3/cmd/shfmt@latest
)

# Install Go packages in parallel, checking for errors
for pkg in "${pkgs[@]}"; do
    go install "$pkg" &
done

wait

# Check for any failed background jobs
for job in $(jobs -p); do
    wait "$job" || echo "Installation failed for job $job"
done

# Install golangci-lint
GOLANGCI_LINT_INSTALL_SCRIPT="https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh"
GOLANGCI_LINT_INSTALL_DIR="$(go env GOPATH)/bin"
GOLANGCI_LINT_INSTALL_FILE="$(mktemp --directory)/install_golangci-lint.sh"

curl -sSfL "$GOLANGCI_LINT_INSTALL_SCRIPT" -o "$GOLANGCI_LINT_INSTALL_FILE"
sh "$GOLANGCI_LINT_INSTALL_FILE" -b "$GOLANGCI_LINT_INSTALL_DIR"
