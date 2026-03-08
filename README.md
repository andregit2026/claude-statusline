# Claude Code Status Line

A custom status line for [Claude Code](https://claude.ai/code) that shows:

```
Claude Sonnet 4.6 (200k)  |  context: 21% used / 79% left  |  DQX | main
^^^ cyan                      ^^^ yellow                       ^blue^ ^green^
```

- **Model + context window size** — size read dynamically from the Claude Code payload
- **Context usage** — % used and % remaining
- **Project folder** — name of the current working directory (blue)
- **Git branch** — current branch if inside a git repo (green), omitted otherwise

## Requirements

- Windows with PowerShell 5.1+
- [Claude Code](https://claude.ai/code) installed
- `git` on PATH (for branch display)

## Install

```powershell
.\install.ps1
```

This will:
1. Copy `statusline-command.ps1` to `~/.claude/`
2. Add (or update) the `statusLine` entry in `~/.claude/settings.json`

Restart Claude Code after installing.

## Uninstall

```powershell
.\uninstall.ps1
```

Removes the script from `~/.claude/` and the `statusLine` entry from `settings.json`.

## How it works

Claude Code calls the status line command on each turn, passing a JSON payload via stdin.
The script reads `workspace.current_dir`, `model.display_name`, and `context_window.*` from
the payload and formats them with ANSI colour codes.
