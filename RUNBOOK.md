# Quickrun Release Runbook

Use this checklist to publish a new `quickrun` version.

## 1) Bump version

Update the app/project version (and any source used by `quickrun --version`).

## 2) Build binary

```bash
cd "/Users/alex.shumeika/Developer/CLI Apps/QuickTerminalCommands"
make clean
make build
```

## 3) Package tarball and compute hash

Replace `X.Y.Z` with the new version.

```bash
tar -czf quickrun-X.Y.Z-macos-arm64.tar.gz -C Build/Products/Release quickrun
shasum -a 256 quickrun-X.Y.Z-macos-arm64.tar.gz
```

## 4) Create GitHub release

In `alex-shumeika/quickrun`:

1. Create release tag `X.Y.Z`
2. Upload `quickrun-X.Y.Z-macos-arm64.tar.gz`

## 5) Update Homebrew tap formula

Edit:

`/Users/alex.shumeika/Developer/homebrew-tap/Formula/quickrun.rb`

Update:

- `url` to the new release asset
- `sha256` to the new tarball hash
- `version` to `X.Y.Z`

## 6) Commit and push

Commit and push changes in both repositories:

- `quickrun`
- `homebrew-tap`

## 7) Verify install

```bash
brew update
brew reinstall quickrun
quickrun --version
```
