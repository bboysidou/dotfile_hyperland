# Lock screen — reliability model

The locker is `modules/lock/Lock.qml` (surface) over `services/Lock.qml` (state
machine), authenticating through PAM with the `hyprlock` PAM config. There is no
idle daemon and none is wanted: the screen locks on `SUPER + CTRL + X`, on the
`quickshell:lock` global shortcut, or on `qs ipc call lock lock`.

Because a lock screen is the one surface that cannot be dismissed, every failure
mode here ends in "user cannot get back into their session". The rules below all
exist to make that impossible.

## The state machine owns its own recovery

No blocking state may be cleared by a view. The earlier permanent-lockout bug
(three failures set a `coolingDown` flag that only a successful password could
clear, and input was blocked while it was set) was one instance; the shake
animation calling `Lock.recover()` was another, because a surface destroyed
mid-animation left `recovering` true and the keyboard dead forever.

Every blocking flag therefore has a service-side timer that clears it:

| Flag | Set by | Cleared by |
| --- | --- | --- |
| `recovering` | a failed attempt | the shake animation, or `recoverTimeout` (2s) as backstop |
| `busy` | `pam.start()` | PAM completing, or `pamTimeout` (20s) aborting it |
| `coolingDown` | `penalise()` | wall-clock — it is derived, not stored |

`coolingDown` is derived from `cooldownUntil`, an absolute timestamp, rather than
a counter that ticks down. A stored deadline cannot get stuck, survives a shell
restart (so the lockout cannot be skipped by killing the shell), and needs no
timer to be correct — the timer only refreshes `now` for the countdown display.

`pam.start()` returning false is reported as `pamUnavailable` instead of leaving
a field that silently does nothing on Enter.

## Failures decay

`faillockWindow` (10 min) mirrors faillock's `unlock_time`. Without it the
counter only ever reset on a successful login, so after three lifetime typos
every third typo triggered a lockout for the life of the state file.

## State file

`~/.local/state/quickshell/lock.json`:

```json
{"failures":0,"lastFailure":0,"cooldownUntil":0,"locked":false}
```

`parse()` accepts a bare integer as well — that is the legacy `lock_failures`
format, kept so an old file cannot brick the locker. Any unparseable content
falls back to zeroed state rather than throwing.

## Crash recovery

A session-lock client that dies without unlocking leaves the compositor showing
its own dead-lock screen, with no input surface: TTY-only recovery. Two things
prevent that:

1. `misc:allow_session_lock_restore = true` in `hypr/hyprland.lua` — permits a
   new lock client to take over the locked session.
2. `~/.config/systemd/user/quickshell.service` with `Restart=always`, started
   from `hypr/config/autostart.lua`. `locked` is persisted, so the restarted
   shell re-locks and re-attaches instead of leaving the session stranded.

`SUPER + SHIFT + B` restarts the unit rather than respawning `qs` by hand;
respawning by hand now races the supervisor.

`hyprlock` remains installed and bound to `SUPER + SHIFT + CTRL + X` as an
independent second locker.

### Escape hatch

From a TTY, if the shell ever re-locks into a state you cannot authenticate
against:

```sh
echo '{"failures":0,"lastFailure":0,"cooldownUntil":0,"locked":false}' > ~/.local/state/quickshell/lock.json
systemctl --user restart quickshell.service
```

## Keyboard focus

Focus is forced on lock, on recovery ending, on surface visibility, and by a
500 ms poll while the lock is up and unfocused — a monitor hotplug creates a new
surface and can leave keystrokes going nowhere. Clicking anywhere also restores
it. When the local surface has no focus the field shows `focusWarning`, so a
dead keyboard is visible rather than mysterious.

`Lock.focusHolders` is a diagnostic counter for `qs ipc call lock state`; it can
drift by one across a hotplug. The per-surface `Password.focused` is the value
the warning binds to, and it is always locally correct.

## Tests

`lock_test.qml` drives the state machine headlessly — parsing, cooldown maths and
cap, input gating, the failure window, and the recovery backstop. It writes state,
so always redirect it away from the real file:

```sh
XDG_STATE_HOME=$(mktemp -d) qs -p lock_test.qml
```

`probe.qml` is the load gate (`qs -p probe.qml`) and covers every lock property
and component instantiation.

Neither covers the compositor handoff. That one is manual:

```sh
qs ipc call lock lock          # screen locks
pkill -9 -x qs                 # systemd restarts within ~1s
```

The lock screen must come back on its own and accept the password. Keep a TTY
(`CTRL + ALT + F2`) available the first time.
