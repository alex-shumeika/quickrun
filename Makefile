# Define variables.
prefix ?= /usr/local
bindir = $(prefix)/bin
destdir ?=
builddir = Build
scheme = QuickTerminalCommands
configuration = Release
binary = quickrun

# Command building targets.
build:
	xcodebuild -scheme "$(scheme)" -configuration "$(configuration)"

install: build
	install -d "$(destdir)$(bindir)"
	install "$(builddir)/Products/$(configuration)/$(binary)" "$(destdir)$(bindir)"

uninstall:
	rm -rf "$(destdir)$(bindir)/quickrun"

clean:
	rm -rf "$(builddir)" .build-xcode

.PHONY: build install uninstall clean
