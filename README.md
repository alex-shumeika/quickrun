# QuickTerminalCommands

A tiny CLI for saving and running your own shell commands by handle.

## Installation

### XCode
Build in Xcode or via `xcodebuild`, then put the binary on your PATH.

### Homebrew
Add a tap
```
brew tap alex-shumeika/homebrew-tap
```

Then install from homebrew
```
brew install quickrun
```

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
quickrun add --handle deploy "make deploy"
quickrun list
quickrun run deploy
quickrun remove deploy
```

## Data storage

Commands are stored as JSON in:

```
~/.config/quickrun/commands.json
```

In Debug builds, the file name is:

```
~/.config/quickrun/commands.debug.json
```

If a file is found in the legacy location (`~/.quick_terminal_commands/`), it is migrated automatically the first time the new location is used.

## Build from source

```
xcodebuild -scheme QuickTerminalCommands -configuration Release
```

The binary will be in `DerivedData/.../Build/Products/Release/QuickTerminalCommands`.

## Notes

- `run` uses `/bin/zsh -lc` so aliases and shell expansions work.
- Confirmation uses an interactive arrow-key UI when run in a TTY.
