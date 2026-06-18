# Rework CLI

Terminal client for Rework v3 (Cowork). Single self-contained binary — **no runtime needed**.

## Install

**Linux / macOS**
```bash
curl -fsSL https://github.com/rework-com/rework-cli/releases/latest/download/install.sh | bash
```

**Windows (PowerShell)**
```powershell
irm https://github.com/rework-com/rework-cli/releases/latest/download/install.ps1 | iex
```

Or grab a binary from the [latest release](https://github.com/rework-com/rework-cli/releases/latest):
`rework-linux-x64`, `rework-darwin-arm64`, `rework-windows-x64.exe` → put on your PATH.

## Usage

```bash
rework auth login                 # sign in with your Rework account
rework me
rework cowork workspace list
rework cowork project list [workspaceId]
rework cowork project overview <projectId>
rework cowork board list <projectId>
rework cowork board page <boardId>
rework cowork task list <boardId>
rework cowork task create <boardId> <name...>
# global:  --json   raw JSON output
```

Sign in with your Rework account via OAuth 2.0. Sign out any time with `rework auth logout`.
