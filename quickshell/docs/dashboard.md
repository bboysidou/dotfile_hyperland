# Dashboard — the top-centre drawer

Ported from `caelestia-dots/shell` `modules/dashboard/` on 2026-09-04. Caelestia
anchors it at `horizontalCenter` + `top` of its fullscreen window
(`modules/drawers/Panels.qml`); here it attaches to `BorderWindow.inner` using the
recipe in `caelestia-deferred.md § Sticking things to the border`.

Three tabs: **Dash**, **Performance**, **Media**. Weather was not taken — it needs
a weather service that does not exist here. GPU was not taken — caelestia reads it
through its C++ `Caelestia.Services` plugin.

**Requires `cava`** for the media visualiser. Without it the bars sit at their
minimum; everything else works.

---

## Opening it

Two independent paths, kept separate on purpose:

| Path | Sets | Keyboard grab | Arrows |
| --- | --- | --- | --- |
| Hover the bar's centre clock | `DashState.barHover` | no | no |
| `SUPER + D` / `qs ipc call dashboard toggle` | `DashState.pinned` | yes | yes |

`opened = pinned \|\| lingering`, and **only `pinned` feeds `BorderState.panelOpen`.**
That split is not cosmetic. `BorderWindow` raises itself to `WlrLayer.Overlay` with
`WlrKeyboardFocus.OnDemand` whenever `panelOpen` is true, so if hover fed it, moving
the cursor across the clock would steal keyboard focus from the focused window.
Hover shows the panel; only the keybind gives it focus and the ←/→ tab keys.

**The hover target is the clock, not the screen edge.** Caelestia's bar is vertical,
so its top edge is free. This bar owns the top edge, so an edge trigger would fire
every time the cursor reached for the tray. The clock is the top-centre, and the
panel opens flush beneath it with no dead zone to cross.

**Two hover sources, one state.** The bar pill and the panel each report hover
(`barHover`, `panelHover`); `hovering` is their OR. Writing both to one property
makes them fight — the pill sets false on exit at the same moment the panel sets
true. A `hoverCloseDelay` timer keeps the panel up while the cursor crosses the
bar's padding on the way down.

**Hover is global, the panel is per-monitor.** `DashState` is a singleton, so
hovering the clock on monitor B opens the dashboard on whichever monitor is focused
(`revealed: root.focused && DashState.opened`). This matches the launcher and
control centre; it is the existing model, not a dashboard quirk.

## Layout

Caelestia's `Dash.qml` is a 6-column `GridLayout` whose column spans have to
resolve against each other (`weatherWidth` spans 0-1, `userWidth` spans 2-4,
calendar spans 1-3). Reproducing that arithmetic with different card widths makes
the widths implicit and fragile, so the pane is nested `RowLayout`/`ColumnLayout`
instead — same visual grouping, explicit widths.

The panel's `implicitWidth`/`implicitHeight` follow the current pane and animate,
so it resizes into each tab. The window mask uses `Region { item: ... }`, which
tracks that geometry live — the trap the deferred doc warns about.

## Services this needed

### `Time` — world clock

**`Intl` is not defined in Quickshell's QML engine**, and `Date.toLocaleTimeString`
silently ignores its `timeZone` option (measured 2026-09-04: it returned local time
for `America/New_York`). So timezone conversion cannot be done in JS here.

One `Process` runs `for z in "$@"; do TZ="$z" date +%z; done` on a 30-minute timer
and caches the `±HHMM` offsets; displayed times derive from the existing
`SystemClock` in QML. Offsets only move at DST boundaries, so the card ticks every
minute with no subprocess per tick, and zoneinfo keeps it DST-correct. Zones are
`Appearance.dash.clockZones`; the shell command takes them as argv, never
interpolated into the string.

### `SysInfo` — temperature, storage, network

- **hwmon numbering is not stable across boots.** `k10temp` was `hwmon2` when this
  was written, but that is probe order. A one-shot `Process` resolves the path by
  reading the `name` files, then a `FileView` polls the resolved `temp1_input`.
- **Storage must dedupe by device.** `/`, `/tmp`, `/home` and `/var` are btrfs
  subvolumes of one filesystem and `df` reports identical size and used bytes for
  each — listing mounts renders four identical bars. Entries are keyed on `source`,
  keeping the shortest target.
- Network rates diff `/proc/net/dev` over elapsed time, skipping `lo`, `veth*`,
  `docker*` and `br-*`.
- `detailed` gates the fast polling and is bound to `revealed`, so the drawer costs
  nothing while shut.

**One reader, one cadence.** `SysInfo` is a singleton, so `cpuPercent` and `memPercent`
are a *single* `/proc` read shared by the bar pills and the dashboard — they can never
disagree, and nothing is polled twice. The two timers are mutually exclusive
(`running: !detailed` / `running: detailed`): the base timer polls stat+meminfo every
10s for the bar, and while the drawer is open it stops and the 2s timer takes over
stat, meminfo, netdev and temp. Before this the fast timer only refreshed
netdev and temp, so the network sparklines moved every 2s while the CPU and memory
gauges sat frozen for 10.

**Gate on the current tab, not just on being open.** All three panes stay instantiated
and `visible` inside the pager (they are only scrolled out and clipped), so the Media
vinyl kept spinning while you were on Performance. Each pane takes an `active` flag set
from the tab, and the singleton work is gated the same way: `SysInfo.detailed` only on
the Performance tab, `Cava.active` only on Media or Dash (the Dash media card has a
visualiser too), and both only while `DashState.opened`.

**Those singleton bindings must live in `Dashboard.qml`, not `DashboardPanel.qml`.**
The panel is instantiated *per monitor*, so two of them were writing the same singleton
property and fighting — the symptom was cava staying alive after the drawer closed.
`Dashboard.qml` is a single `Scope`, so the decision is made once.

**A closed panel must actually stop.** `DashboardPanel` sets
`visible: revealed || opacity > 0`; without it the panel is merely transparent, so
`Marquee`'s scroll timers keep firing and the vinyl keeps spinning behind a hidden
surface. The vinyl additionally guards `running: Players.playing && root.visible`,
since an animation does not care about opacity. Measured: ~1% CPU closed, ~5% open.

### `Cava` — media visualiser

Caelestia links `libcava` (`cavacore`) directly from C++
(`plugin/src/Caelestia/Services/cavaprovider.cpp`), which a pure-QML config cannot
do. The CLI produces the same bar values: one `Process` runs `cava` with a
generated config in `raw`/`ascii` output mode and a `SplitParser` reads one frame
per line.

Their tuning is reproduced exactly — `cava_init(bars, rate, 1, 1, 0.85, 50, 10000)`
becomes `noise_reduction = 0.85`, `lower_cutoff_freq = 50`,
`higher_cutoff_freq = 10000` — and their **monstercat filter** (bidirectional
`max(value, carry / 1.5)`) is reimplemented in QML, since it lives in their C++ and
not in cava itself.

**cava's autosens ramps over ~2s** (measured peaks `0 → 1 → 7 → 45 → 54`). The
process is therefore bound to `revealed`, not to the current tab — gating it per
tab made the bars restart from silence on every tab switch. Config zones are passed
through a config file the same `Process` writes before exec, so nothing is
interpolated into a shell string.

### `Players`

Gained `trackAlbum`, `artUrl`, `canSeek`, `canGoNext`/`canGoPrevious`, `progress`,
`list`, `label()`, `select()` and `seek()`. The media tab, the dash media card and
the player selector all needed these; none existed.

## Shared primitives changed

- **`GaugeArc`** (new) — a half-ring with a fixed end gap: track across the full span,
  progress overlaid from the start.
- **`Ring`** — `radiusRatio`/`thicknessRatio` were `readonly` and hardcoded to the
  bar's values; `capStyle`, `startAngle` and `span` did not exist. All are now
  properties defaulting to the previous behaviour, so the bar is untouched while the
  performance gauges get a large, thin, round-capped arc.
- **`Marquee`** — two fixes, both visible in the media tab:
  1. `maxLength` was hardcoded to `Appearance.marquee.maxLength` (20), tuned for the
     bar. In a 444px slot a 30-character title still scrolled, and read as garbage
     because the window started mid-word. It is now a property.
  2. The window was sized with `advanceWidth("0")`, which under-reports the real
     advance (~13.8 vs ~14.7 measured at 23px). With `renderType: NativeRendering`
     each glyph advance rounds up to a whole pixel, so the window is now computed
     from the actual string's average advance, ceiled.
- **`Sparkline`** (new, `core/components/`) — `PathPolyline` line plus a filled
  area, auto-scaling to `max(maximum, peak)`.

## Layout as built

**Performance** is three round-capped gauges (Memory, CPU as the larger hero,
Storage), each with a centred value and label plus a secondary stat to its right,
then a 1px accent rule, then the network strip — download over upload, no card
background.

Each gauge is **two independent half-rings** (`core/components/GaugeArc.qml`) split by
a fixed diagonal divider running bottom-right to top-left (compass 135 and 315, i.e. Qt
`startAngle` 45 and 225):

- **top-right half** — the secondary value as a percentage of 100
- **bottom-left half** — the primary value over its own maximum (temp/100 for CPU,
  used/total for memory and storage)

All three gauges are the **same component** (`core/components/Gauge.qml`); only the data
and `size` differ — the middle one is `gaugeSizeMain`, the outer two `gaugeSizeSide`.

`size` is the single scale knob: stroke, gap, all three font sizes, the centre spacing
and the text allowance are bindings on it (ratios in `Appearance.gauge`), so one number
rescales the whole design. Each derived value is still an overridable property.

The secondary (usage) arc is drawn in `Colours.shade(colour, secondaryShade)` so it sits
a shade darker than the primary arc, with its track derived from that darker colour.

The Dash tab's resource rings use the **same `Gauge`** at `resourceGaugeSize`, with a
glyph in the centre instead of text (`icon`, hidden when empty) and the percentage in the
opening. Those rings carry a single metric each, so `value` and `secondaryValue` are both
set to it and the two halves fill together. `secondarySize` is overridden there — at size
84 the derived value lands near 7px, which is too small to read; every derived property is
overridable for exactly this case.

The primary value and label are centred. The **top-right arc is trimmed at its bottom
end** (`GaugeArc.trimEnd`, `gaugeTextGap` = 58 degrees) and the secondary value and its
word sit at the angular centre of that opening, on the ring radius — the text is *in*
the bottom split, not floating above an arc. Trimming the usage arc keeps the usage text
with the value it represents.

The visualiser draws 44 bars; giving each a `Behavior on height` meant 44 animations
running at cava's framerate. They are plain bindings now — cava already smooths its
output (noise reduction plus the monstercat filter), so the animation was paying for
smoothing twice.

**Profiled cost of the media tab** (measured from `/proc/<pid>/stat` deltas, shell-wide):

| | CPU |
| --- | --- |
| drawer closed | 0.5% |
| Performance tab | ~5.5% |
| Media tab, visualiser off | 1.8% |
| Media tab, cava at 60fps | 19.2% |
| Media tab, cava at 30fps | 15.9% |

So the visualiser *is* the cost, and it scales with cava's framerate — hence
`visualiserFramerate: 30`. Bar geometry barely matters: square, non-antialiased bars saved
only 1.7%, so the rounded ones were kept. The vinyl rotation is ~2.4%.

**Two traps when profiling this.** Changing `visualiserFramerate` does *not* restart a
running cava, so the first 60-vs-30 comparison measured the same 60fps process twice and
showed no difference; close and reopen the drawer to restart it. And `visualiserBars` must
match what cava emits — `Cava.apply` rejects any frame whose field count differs, so a
changed bar count with a stale cava silently freezes the bars at zero rather than erroring.

`GaugeArc` therefore takes both `trimStart` and `trimEnd`; which end you shorten decides
where the text lands, and only `trimEnd` puts the opening at the bottom split.

Because the text sits *on* the ring, half of it falls outside the ring's own box. The
gauge item is widened by `gaugeTextAllowance` on each side with the ring centred inside,
which is what stops the outermost gauge's text being clipped by the pane edge. Pulling
the text inward instead (`gaugeTextRadiusRatio` < 1) crowds the centre label, since the
opening sits at the same height as it.

**The split must not move with the value.** caelestia's `CircularProgress` (an M3
progress indicator, ported and then dropped here) puts a *computed* gap between the
progress and the remaining track, so the visible break slides as the value changes.
`GaugeArc` instead draws the track across the whole half and overlays the progress on
top, so the only breaks are the two fixed ones. The gap is still derived from geometry
(`(gapSpacing + strokeWidth) / arcRadius`) so it looks constant at any ring size — fixed
with respect to the *value*, not to the stroke.

Getting here took four wrong guesses from screenshots — a plain progress ring, a
full-circle track, caelestia's M3 `CircularProgress`, and a diagonal 135/315 split.
Pixel measurement settled the geometry each time but never the *rule*. The lesson is
to measure the render as well as the reference: measuring my own output is what showed
the split was at 135/315 when the target was 90/270.

If the M3 behaviour is ever wanted back, note that `clampedVal` must **not** be
`readonly` — it carries the `Behavior`, and making it readonly fails to load with
"Invalid property assignment".

**Media** is the spinning vinyl on the left and a centred details column: title,
album, artist, transport (shuffle / prev / play / next / loop), seek with times, and
the source chip. The dash tab's media card uses the same `Vinyl` at a smaller
`coverSize`/`magnitude`.

## Gotchas found while building

**`ClippingRectangle` reparents its children.** It declares
`default property alias data: contentItem.data`, so anything written inside it
becomes a child of an inner `contentItem`, not of the rectangle. Two consequences,
both hit here:

- `parent.radius` inside it is `undefined` — reference the rectangle by `id`.
- **An `Elevation` written inside it gets clipped away.** `CoverPanel` is therefore
  an `Item` holding the shadow and the `ClippingRectangle` as siblings, not a
  `ClippingRectangle` with the shadow inside.

**A forward-referenced size binding inside a `Repeater` delegate segfaults the
shell.** `Layout.preferredWidth: content.implicitWidth + N`, where `content` is a
child declared further down, evaluates to `undefined` while the delegate is being
built. `undefined + N` is NaN, the NaN reaches a `Text`, and
`QTextLine::setLineWidth(NaN)` crashes inside `QQuickRepeater::componentComplete`.
Quickshell's crash handler restarts the shell, so the symptom is a shell that
appears to keep running under a stable supervisor PID while
`coredumpctl` fills with SIGSEGVs — check `coredumpctl` and the crash report's
`Launching config:` line to tell a shell crash from a throwaway `qs -p` crash.
Every such binding is now written `(child.implicitWidth || 0) + N`.

**Never use a live-computed array as a `Repeater` model.** `NetworkCard`,
`ResourcesCard` and the world clock originally built their model arrays from service
properties, so every poll produced a new array and the `Repeater` destroyed and
recreated every delegate — twice a second for the network card. Models are now
static (or the config list) and the live values are read inside the delegate.
`CalendarCard` was the last holdout and became a real risk once month navigation
made its array rebuild on every click; its model is now the constant cell count
and the delegate reads `root.cells[index]`.

**A delegate must not declare a property named `data`.** It is `Item`'s default
property and read-only from QML, so `readonly property var data: ...` fails the
whole config load with `Invalid property assignment: "data" is a read-only
property`. `CalendarCard`'s per-cell lookup is named `cellData`.

**A `Text` in a layout must not size the layout when it marquees.** The title's
`implicitWidth` grows with its content and would push the pane wider than its fixed
`mediaTabWidth`. `Layout.preferredWidth: 0` plus `Layout.fillWidth` makes the layout
hand it the leftover space; `budget: width` then reflects reality instead of a
guessed constant, and `clip: true` guarantees it can never paint past the card.

## Not taken

- **Weather tab and `SmallWeather`** — needs a new `services/Weather.qml`. The world
  clock card occupies the slot `SmallWeather` holds in caelestia's grid.
- **GPU hero card** — caelestia reads GPU usage through its plugin. `amdgpu` is
  present in hwmon here (`edge` temp) and exposes `gpu_busy_percent` in sysfs, so a
  pure-QML version is possible; it was simply out of scope.
- ~~`CoverVisualiser`~~ — **taken.** The earlier note that this needed the C++ plugin
  was wrong: `modules/dashboard/media/CoverVisualiser.qml` is pure QML (a `Shape` of
  N radial `ShapePath` lines). Only its *data source* was plugin-bound, and `cava`'s
  CLI replaces that. Rebuilt here as `Visualiser.qml` using rotated `Rectangle`s
  rather than `Shape`/`Variants`, which composites on the GPU.
- **Lyrics (`LyricList`, `LyricsInfo`, `LyricsAndSelector`)** — needs its lyrics
  fetcher.
- **`BackgroundShapes` via `M3Shapes`** — was replaced by a `MultiEffect` blur of the
  cover art, then removed entirely on request; the media tab is flat.
- **Battery tank** — laptop-gated; renders nothing on this desktop.

## Testing note

The load gate must instantiate components **declaratively under a real, sized
parent**. A gate built on `createObject(null)` hits the same NaN-width crash as
above for its own reason — an unparented item gives `Layout.fillWidth` a NaN width
— so it dies instead of reporting. `createObject` also never evaluates bindings
inside a `Behavior`, which is how a missing `qs.core.enums` import in
`Visualiser.qml` passed the gate and only surfaced in the live log.

The gate proves components *load*. It does not prove they are *stable*: the
forward-reference crash above only appeared under real use. Verify with
`coredumpctl` and by cycling the tabs while checking the daemon's PID is
unchanged.

## IPC

```
qs ipc call dashboard open <dash|performance|media>
qs ipc call dashboard close
qs ipc call dashboard toggle ""
qs ipc call dashboard next
qs ipc call dashboard previous
qs ipc call dashboard status
```
