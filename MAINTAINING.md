# Maintaining this tap

**This directory is the only place to edit the cask.** Clone of
`khaliji-hub/homebrew-sankore`, over SSH, outside Homebrew's control.

## Never commit inside /opt/homebrew/Library/Taps/

That directory belongs to Homebrew. `brew tap` creates it as a fresh clone with
an **HTTPS** remote, and `brew untap` **deletes it outright**. A commit authored
there cannot be pushed (no HTTPS credentials) and is destroyed by the next
untap, with no reflog to recover it because the whole object database goes with
the directory.

That happened on 13 Sep 2026: the `:big_sur` fix was committed there, failed to
push, and was lost to an untap moments later. It had to be written twice.

The tap directory is a **pure consumer**: `brew tap`, `brew untap`, `brew
install`, `brew info`. Never `git commit`.

## Releasing a new version

1. Edit `Casks/sankore.rb` here.
2. Get the real hash from the live DMG, never from memory:
   ```
   curl -sL https://dl.sankoreapp.com/Sankore-<version>.dmg -o /tmp/s.dmg
   shasum -a 256 /tmp/s.dmg
   rm /tmp/s.dmg
   ```
3. Lint and audit:
   ```
   brew style --fix Casks/sankore.rb
   brew audit --cask --new khaliji-hub/sankore/sankore
   ```
4. Commit and push from here.
5. Verify what a user actually gets, which is the step that catches what
   linting does not:
   ```
   brew untap khaliji-hub/sankore
   brew tap khaliji-hub/sankore
   brew info --cask khaliji-hub/sankore/sankore
   ```
   **Check for deprecation warnings.** `brew style` and `brew audit` both
   accepted `depends_on macos: ">= :big_sur"`, but the runtime warned on every
   tap command, before the user saw anything about Sankore. Only the real user
   flow surfaced it.

## Testing an install without risking the real app

`/Applications/Sankore.app` is the live, signed, licence-activated install.
`brew install --cask` targets that exact path and `brew uninstall --cask`
deletes it. **Always** use an isolated appdir:

```
brew install --cask --appdir=/tmp/sankore-cask-test khaliji-hub/sankore/sankore
```

Record `stat -f "%i %m" /Applications/Sankore.app` before and after and confirm
both values are unchanged. Verify the installed copy with `codesign --verify
--deep --strict`, `spctl -a -vvv -t install`, and the app's own headless probe
rather than by launching a window:

```
SANKORE_HEADLESS_PROBE=<some.pdf> /tmp/sankore-cask-test/Sankore.app/Contents/MacOS/sankore
```

Then `brew uninstall --cask` and delete `/opt/homebrew/Caskroom/sankore`, which
the uninstall leaves behind as a backup copy of the app.

## Commit identity

GitHub rejects pushes carrying the account's private email. Use the noreply
address, already set as this clone's local config:

```
Khaliji-Hub <311647405+khaliji-hub@users.noreply.github.com>
```

## The zap stanza deliberately does not remove ~/Sankore

That folder holds app state **and** the user's converted output. Trashing it
would delete their documents. Only the two dotfiles inside it are listed by
name. Everything else zapped is under `~/Library`.
