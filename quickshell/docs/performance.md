# Performance

Measured 2026-10-17 on the desktop (RX 580, Mesa 26.2, Qt 6.12, Quickshell 0.3.2,
two monitors). Idle RSS is sampled 20 s after a service restart; CPU over the next 30 s.

| State | Idle RSS | Threads | Idle CPU |
| --- | --- | --- | --- |
| Before (eager panels, no env) | ~512 MB | 113 | ~1.1% |
| Lazy panels, no env | ~444 MB | 112 | 1.07% |
| Lazy panels + `QSG_RENDER_LOOP=basic` | ~426–439 MB | 100–106 | 0.90% |

## Panels are created on open, destroyed after close

Every panel in `modules/border/BorderWindow.qml` is wrapped in
`core/components/PanelSlot.qml`. The slot creates the panel when `open` turns true,
binds the panel's `revealed` to `open` after creation (so the opacity/scale Behaviors
still animate in), and destroys it once the close fade reaches `opacity` 0. Without
it, all ten panels lived on both screens permanently — about 75 MB.

Rules that follow from this:

- **A new border panel goes inside a `PanelSlot`**, with `open:` carrying the condition
  that used to be `revealed:`. The mask `Region` reads `slot.item?.revealed ? slot.item : null`.
- **State that must survive a close lives in the module's `*State` singleton**, never
  as a writable property on the panel — the panel is a fresh object on every open.
  `AudioPanel`'s sub-tab moved to `ControlState.audioSection` for exactly this reason.
  Scroll positions and a collapsed notification card do reset on reopen; that is accepted.
- Creation cost is 1–13 ms per panel; `DashboardPanel` is the heaviest at 22–34 ms.
  Loading stays synchronous so the open animation starts from the first frame.

## Environment

`~/.config/systemd/user/quickshell.service.d/perf.conf` sets `QSG_RENDER_LOOP=basic`:
all windows render on the GUI thread instead of one render thread each.

Tried and rejected — do not re-add without a fresh A/B:

- `MALLOC_ARENA_MAX=2` — about 3 MB, noise.
- `AMD_DEBUG=useaco` — no gain on its own; any gain alongside `basic` sat inside the
  ±20 MB run-to-run noise, and it swaps the shader compiler for every surface.
- `QSG_RHI_BACKEND=vulkan` — the shell crash-loops (`Failed to create Vulkan instance: -9`);
  `vulkan-radeon` is not installed.

## Checked and left alone

- All 17 `clip: true` sites are load-bearing (scroll containers, collapse animations,
  liquid/fill reveals, the password-dot viewport).
- Every wallpaper-sized `Image` already sets `sourceSize` and `asynchronous`;
  `IconImage` derives `sourceSize` from its size. The two notification `IconImage`s are
  `asynchronous` because an app can send a full screenshot as the icon.
- Infinite animations are all gated on `visible` or a service flag, and pollers switch
  to their idle interval when nothing shows them.
- The `Power` and `KeybindSheet` windows cost nothing measurable while closed.
