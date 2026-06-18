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

# Cowork — full project management (run `rework help` for every command)
rework cowork project list
rework cowork board list <projectId>
rework cowork task create <boardId> <name...>
rework cowork task status <taskId> 1
rework cowork issue create <projectId> <title...>
rework cowork plan create milestone <projectId> <name...>
# …workspaces, board columns, flow, planning, resources, docs, search — see `rework help`

# Feedback — report a bug or request a feature to the Rework team
rework feedback "<your feedback>"
```

Sign in with your Rework account via OAuth 2.0. Sign out any time with `rework auth logout`.
