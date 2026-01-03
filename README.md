# QuickTerminalCommands

A tiny CLI for saving and running your own shell commands by handle.

## Installation

Build in Xcode or via `xcodebuild`, then put the binary on your PATH.

## Usable

```
quickrun <COMMAND>
```

### Default behavior

- `quickrun` with no args lists all saved commands (same as `quickrun list`).
- `quickrun <handle>` runs that command (same as `quickrun run <handle>`).

## Commands

### list

List all saved commands with their handles.

### add

Add a new command. If command is multi-word it should be wrapped in quotes.

### run

Run a saved command by handle. You will be prompted to confirm before execution.

### remove

Remove a saved command by handle. You will be prompted to confirm before deletion.

### change-handle

Change the handle for an existing command.

## Examples

```
quickrun add "echo Hello world"
quickrun add --handle 10 "ls -la"
quickrun list
quickrun run 10
quickrun remove 10
```

## Data storage

Commands are stored as JSON in:

```
~/.quick_terminal_commands/quick_terminal_commands.json
```

In Debug builds, the file name is:

```
~/.quick_terminal_commands/quick_terminal_commands.debug.json
```

## Build from source

```
xcodebuild -scheme QuickTerminalCommands -configuration Release
```

The binary will be in `DerivedData/.../Build/Products/Release/QuickTerminalCommands`.

## Notes

- `run` uses `/bin/zsh -lc` so aliases and shell expansions work.
- Confirmation uses an interactive arrow-key UI when run in a TTY.
