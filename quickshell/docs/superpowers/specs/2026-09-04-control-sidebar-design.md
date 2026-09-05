# Full-height control sidebar with notification history

Date: 2026-09-04
Status: approved, ready for implementation
Scope: `modules/controlcenter/`, `services/`, `modules/bar/`, `core/`

## Summary

Turn the control centre from a top-right dropdown with three accordion sections
into a full-height right-edge panel with two stacked regions:

- **Top** — a tab strip (sound / network / bluetooth) over a single visible pane.
- **Bottom** — a persistent notification history grouped into collapsible app cards.

Bar pills open the panel directly on their matching tab. A new network pill and a
new notifications pill join the bar. Notification history survives shell restarts
on disk, ages out, and is genuinely erased from disk by "clear all".

## Decisions

| Question | Decision |
|---|---|
| Notification scope | Full history centre, not a live mirror |
| Persistence | Disk-backed JSON with a max age and a max entry count |
| Geometry | Overlay inside `BorderWindow.inner`, bar to bottom border; no exclusive zone, nothing reflows |
| Vertical split | Top pane sizes to content, capped at a ratio of panel height; notifications take the remainder |
| Toasts | Kept, suppressed while the panel is open |
| Card model | Every app is a collapsible card, including single-notification apps; cards start expanded |
| Bar additions | Network pill and notifications pill; no do-not-disturb |
| Clear all | Writes through to disk immediately, not debounced |
| Module strategy | Evolve `modules/controlcenter/` in place; no rename |

### Why evolve rather than rename to `modules/sidebar/`

`ControlState.section` already means "which tab", so the state model needs no
change. A rename would touch `ControlState`, `ControlSection`, both bar pills,
`shell.qml`, `BorderWindow.qml`, the `controlcenter` IPC target string, and
`~/.config/hypr/config/keymaps.lua:19,24` — which bind
`quickshell:controlcenter-wifi` and `quickshell:controlcenter-audio` as an
external contract. The rename buys a better folder name for six call sites of
churn and a window-manager config edit. Rejected.

## Platform constraints

These are properties of Quickshell and the freedesktop notification spec, not
implementation shortcuts. They shape the design and must not be "fixed".

1. **A notification's actions die with it.** `NotificationAction` objects belong
   to the live `Notification`. Once it expires or the app closes it, the object is
   gone. A stored entry therefore keeps text, icon, urgency and timestamp, but
   loses its action buttons. Rows render buttons only while `entry.notification`
   is non-null.
2. **Dismissing a dead entry is local.** For a live entry, dismissal calls
   `notification.dismiss()`. For a stored one, it only removes it from our list —
   there is nothing left to tell the originating app.
3. **`keepOnReload: true`** on `NotificationServer` preserves *currently active*
   notifications across a config reload. It does nothing for expired ones. That
   gap is exactly what the store exists to fill.
4. **Icon paths go stale.** Favicons live in `~/.cache` and can be swept. Entries
   persist `appName` and `desktopEntry` alongside the resolved image so a row can
   re-resolve through `DesktopEntries` instead of rendering a broken image.

## Architecture

### File layout

```
services/
  NotifEntry.qml          NEW  one history entry, a dumb data object
  NotifHistory.qml        NEW  the store: persistence, grouping, expiry, unread
  Notifs.qml              MOD  track() calls remember(); forget() calls detach()

modules/controlcenter/
  ControlPanel.qml        REWRITE  full-height, tab strip + capped pane + list
  ControlState.qml        MOD  + togglePanel()
  ControlCenter.qml       MOD  + controlcenter-bluetooth and controlcenter-toggle shortcuts
  panes/
    Pane.qml              NEW  Flickable base; each pane scrolls itself so the Row can slide
    PaneHeader.qml        NEW  from Section.qml: header row + optional control slot, no collapse
    AudioPane.qml         NEW  from AudioSection
    NetworkPane.qml       NEW  from NetworkSection
    BluetoothPane.qml     NEW  from BluetoothSection
  notifications/
    NotifList.qml         NEW  header (count, clear all) + flickable of cards + empty state
    NotifCard.qml         NEW  one app group, collapsible
    NotifRow.qml          NEW  one notification inside a card
  components/
    Section.qml           DELETE  after PaneHeader and NotifCard absorb its two halves
    AudioSection.qml      DELETE  superseded by AudioPane
    BluetoothSection.qml  DELETE  superseded by BluetoothPane
    NetworkSection.qml    DELETE  superseded by NetworkPane
    AudioDevice.qml       keep
    StreamEntry.qml       keep
    BluetoothEntry.qml    keep
    NetworkEntry.qml      keep
    PasswordPrompt.qml    keep

modules/bar/components/
  NetworkPill.qml         NEW
  NotifPill.qml           NEW

modules/notifications/
  Notifications.qml       MOD  suppress toasts while the panel is open

modules/dashboard/
  components/TabStrip.qml DELETE  moved to core
  DashboardPanel.qml      MOD  passes its own tabs list
  media/EmptyState.qml    DELETE  moved to core
  media/MediaPane.qml     MOD  passes its own glyph/title/subtitle

core/
  components/TabStrip.qml NEW  generalised from the dashboard's
  components/EmptyState.qml NEW  generalised from the dashboard's
  enums/BarEntry.qml      MOD  + network, notifications
  enums/ControlSection.qml MOD  + values list
  config/Appearance.qml   MOD  + TabConfig, control and notif tokens
  helpers/Fmt.qml         MOD  + relativeTime()

services/Net.qml          MOD  + glyph, shared by the pane header and the bar pill

probe.qml                 NEW  non-instantiating load gate
```

### Two generalisations, deliberately in scope

The reuse rule in the engineering conventions is *found close → extend or
generalise in place, never fork a copy*. Two existing components are 90% right
for their second consumer:

- **`TabStrip`** hardcodes `DashSection` and `Appearance.dash.*` tokens. It moves
  to `core/components/`, takes `tabs` as a required property (a list of
  `{section, icon, label}`), and reads shared tokens from a new `Appearance.tab`
  group split out of `DashConfig`. `DashboardPanel` supplies its own list.
- **`EmptyState`** hardcodes the media glyph and `Appearance.dash.*` sizes. It
  moves to `core/components/` with `glyph`, `title` and `subtitle` properties.

Both are small, both keep the dashboard working unchanged behaviourally, and both
are required regression targets.

### `Section.qml` splits in two

`Section.qml` currently does two unrelated jobs: it renders a header row with an
optional control slot, and it implements collapse via a clipping wrapper with a
height `Behavior`. The redesign needs each half in a different place:

- The **header** becomes `panes/PaneHeader.qml` — same glyph, title and `control`
  Component slot, minus the chevron and the click-to-expand. This is what keeps
  the wifi and bluetooth toggles alive once the accordion is gone.
- The **collapse mechanism** becomes the body of `NotifCard.qml`.

`Section.qml` is deleted once both halves have moved.

## Data model

### `NotifEntry`

A `QtObject` with no server coupling.

| Property | Type | Persisted | Notes |
|---|---|---|---|
| `key` | string | yes | stable id; `${time}-${counter}` |
| `appName` | string | yes | grouping key |
| `desktopEntry` | string | yes | icon re-resolution fallback |
| `summary` | string | yes | |
| `body` | string | yes | |
| `image` | string | yes | resolved source at capture time |
| `urgency` | int | yes | `NotificationUrgency` value |
| `time` | double | yes | `Date.now()` ms |
| `read` | bool | yes | |
| `notification` | Notification | **no** | null once the live object is gone |

### Persisted payload

`${Paths.state}/${Appearance.state.dir}/notifications.json`

```json
{ "version": 1, "entries": [ { "key": "...", "appName": "...", "...": "..." } ] }
```

`version` is checked on load; a mismatch is treated as an empty store rather than
a parse attempt. Unparseable JSON warns once and starts empty, matching the
existing behaviour in `Apps.qml:76-88`.

### `NotifHistory`

Singleton. The only thing that touches the file.

```
property list<NotifEntry> entries        newest first
readonly property var groups             computed, see below
readonly property int unread             entries.filter(e => !e.read).length

function remember(notification)          called from Notifs.track()
function detach(notification)            null out entry.notification when the live object dies
function dismiss(entry)                  live -> notification.dismiss(); always drop locally, save now
function clearApp(appName)               drop the group, save now
function clear()                         drop everything, save NOW (not debounced)
function markAllRead()                   called when the panel opens
function sweep()                         drop entries older than maxAge, then trim to maxEntries
function save()                          schedule a debounced write
function flush()                         write immediately
function adopt(payload)                  parse, version-check, sweep, populate
```

`groups` buckets `entries` by `appName`, each group ordered newest-first, groups
ordered by their newest member's `time`. Shape:
`[{ appName, desktopEntry, image, entries, latest, count }]`. This drives the card
`Repeater` directly, so no grouping logic lives in the view.

`sweep()` runs on load, after every `remember()`, and on a daily `Timer`.

**A `loaded` flag guards the writer.** Quickshell constructs singletons lazily, so
if the store's first construction were ever triggered by an arriving notification,
`remember()` would prepend to an empty list and the debounce could flush *before*
`FileView` delivers the file — erasing the history it was about to read. `flush()`
therefore refuses to write until `loaded` is true (set by `onLoaded` or
`onLoadFailed`) and re-arms the debounce instead; `adopt()` concatenates restored
entries onto whatever already arrived rather than replacing them; and `clear()`
sets `loaded` itself, because an explicit clear must reach disk regardless.

Persistence uses `FileView { atomicWrites: true }` — the same idiom as
`Apps.qml:97-105`, not a new one. Writes are debounced through a `Timer` so a
notification storm cannot thrash the disk. **`clear()` and `clearApp()` bypass the
debounce and flush synchronously**, because a clear that has not reached disk yet
is a clear that a reload will undo.

`clear()` writes `{"version":1,"entries":[]}` rather than deleting the file. An
empty payload keeps a single load path honest; a missing file would need its own
branch in `adopt`. The data is gone from disk either way, which is the
requirement.

### Unread semantics

_Amended 2026-09-04, after the first build._ An entry arrives
`read: root.viewing`, where `viewing` is true while the panel is open. Opening the
panel additionally calls `markAllRead()`. The bell badge therefore means "arrived
while you were not looking" — an arrival landing in a list you are already
watching is never badged.

`viewing` is a property on the store that the panel *drives*, not one the store
computes: `NotifHistory` is a service and `ControlState` is a module, so the store
must not import it. `ControlPanel` carries
`Binding { target: NotifHistory; property: "viewing"; value: ControlState.opened }`,
the same shape as its `Net.scanning` binding. `ControlPanel` is instantiated once
per screen, so every instance writes this binding — harmless, because the
expression is screen-independent and all instances therefore agree.

## Panel

### Geometry

`ControlPanel` stays in `BorderWindow.inner`, anchored `top + right + bottom`.
`implicitHeight` and `Appearance.control.maxHeightRatio` are removed;
`implicitWidth` stays `Appearance.control.width`.

The panel touches the bar above, the border to its right, and the border below, so
only its left edge is exposed. All four corner radii become `0` and both left
corners become concave fillets:

```
Fillet  anchors.right: parent.left  anchors.top: parent.top       origin: Corner.bottomLeft
Fillet  anchors.right: parent.left  anchors.bottom: parent.bottom origin: Corner.topLeft
```

The second replaces the old bottom fillet, which existed only because the dropdown
floated. Fillet geometry is easy to get subtly wrong; verify on screen, not on
paper.

`scaleFrom` and `transformOrigin: Item.TopRight` are unchanged — it still reads as
growing out of the bar's right end. The existing `Region { item: control.revealed ? control : null }`
mask in `BorderWindow.qml` needs no change.

### Vertical composition

```
TabStrip                      fixed height
pane viewport                 height = min(activePane.implicitHeight,
                                           root.height * Appearance.control.topPaneMaxRatio)
                              Behavior on height -> Anim { type: AnimType.emphasizedSmall }
                              flicks internally once capped
NotifList                     fills the remainder; its own first row is the
                              divider header, "NOTIFICATIONS · n" ... "clear all"
```

Two independent scroll regions, never nested.

The viewport reuses `DashboardPanel`'s mechanism verbatim: a `ClippingRectangle`
containing a `Row` whose `x` animates to `-(activePane.x)`, populated by a
`DelegateChooser` over `ControlSection.values`. Each pane is given
`width: viewport.width` and `height: viewport.height`. Horizontal slide and
vertical scroll cannot share one `Flickable`, so each pane *is* a `Flickable` —
that is what `panes/Pane.qml` provides, reporting its content height as
`implicitHeight` for the cap calculation. This yields the same horizontal slide between
sound/net/bt that the dashboard already has between dash/perf/media.

### Panes

Each pane is its former `*Section.qml` body with the `Section` root replaced by a
`ColumnLayout` whose first child is a `PaneHeader`. Behaviour carried over
verbatim:

- `NetworkPane` keeps `activate`, `submit`, `dismiss`, the `pendingNetwork`
  `Connections` block, the wired-device row, the `PasswordPrompt`, and the
  `closeRequested` signal wired to `ControlState.hide()`.
- **`Net.scanning` retargets.** It was `Net.scanning = root.expanded`. It becomes
  `Net.scanning = ControlState.opened && ControlState.section === ControlSection.network`,
  so scanning still only runs while the network pane is actually visible. Getting
  this wrong leaves a wifi scan running forever, so it is a specific test.
- `BluetoothPane` and `NetworkPane` keep their `Toggle` in `PaneHeader.control`.
- `AudioPane` has no control; it keeps its `GroupLabel` inline component and all
  three repeaters.

### Keyboard

| Key | Action |
|---|---|
| `←` / `→` | previous / next tab, wrapping via `Num.wrap(index, delta, count)` |
| `↑` / `↓`, `Ctrl+N` / `Ctrl+P` | walk the focus chain inside the panel (existing, kept) |
| `Esc` | close (existing, kept) |

New global shortcuts in `ControlCenter.qml`, matching the existing two:

- `controlcenter-toggle` — opens on the last used tab via `ControlState.togglePanel()`
- `controlcenter-bluetooth` — the third section finally gets parity

Both need a corresponding `hl.bind` line in `~/.config/hypr/config/keymaps.lua`
next to the existing `Super+W` and `Super+V` bindings.

The `IpcHandler` in `ControlCenter.qml` is unchanged; its `open`/`close`/`toggle`/
`status` functions keep working against the same `ControlState` API.

## Notification list

**`NotifList`** — header row (`NOTIFICATIONS · n` left, `clear all` right) over a
`Flickable` column of `NotifCard`, with a `core/components/EmptyState` shown when
`NotifHistory.entries.length === 0`.

**`NotifCard`** — one app group.

- Header: app icon, app name, count badge, newest relative time, chevron, and an
  `×` that fades in on hover for `clearApp()`.
- Body: a `Repeater` of `NotifRow` inside the clipping wrapper and height
  `Behavior` inherited from `Section.qml`.
- `expanded` defaults `true`. Clicking the header toggles it.

**`NotifRow`** — summary, body clamped to two lines, relative time from
`Fmt.relativeTime()`.

- Critical entries get a left edge in `Colours.urgencyCritical` (the token already
  exists; `Toast.qml:15` uses the same one).
- Unread rows sit slightly brighter until `markAllRead()`.
- Action buttons reuse `modules/notifications/components/NotifAction.qml`,
  rendered **only while `entry.notification` is non-null**.
- Clicking the row invokes the default action when one exists.
- Hover reveals an `×` calling `NotifHistory.dismiss(entry)`.

### Toast suppression

`Notifications.qml` binds `shown: Notifs.stack.length > 0 && !ControlState.opened`,
importing `qs.modules.controlcenter`. Module-to-module import is already the
established pattern — `VolumePill.qml:6` and `BluetoothPill.qml:5` both do it. A
`suppressed` flag on the `Notifs` service was rejected because it would make a
service depend on a module, inverting the layering.

Timers still run while suppressed; entries land in history regardless.

## Bar

**`NetworkPill`** — `visible: Net.available`. Glyph resolution mirrors
`NetworkSection.qml:21-29` (`Glyphs.wifi(Net.signalPercent(...))`, `Icons.ethernet`,
`Icons.wifiDisabled`, `Icons.wifiOff`); that expression moves onto the service as
`Net.glyph` so the pill and the pane share one source. It cannot live in
`core/helpers/Glyphs.qml` — that file does not import `qs.services` and must not,
since a helper depending on a service inverts the layering.
`onClicked: ControlState.toggle(ControlSection.network)`.

**`NotifPill`** — `Icons.notifNormal`, with an unread count shown when
`NotifHistory.unread > 0`. `onClicked: ControlState.togglePanel()`.

`BarEntry` gains `network` and `notifications`; `BarSlot` gains two
`DelegateChoice` entries. Final ordering:

```
entriesRight: [volume, network, mouseBattery, bluetooth, tray, notifications, cpu, memory]
```

Sound, network and bluetooth therefore read left to right in the same order as the
tabs they open.

## New configuration

All values are named constants in `core/config/Appearance.qml`; none are inline.

`TabConfig` (new group, split out of `DashConfig`): `height`, `spacing`,
`paddingH`, `iconSpacing`, `rounding`, `iconSize`, `indicatorHeight`,
`indicatorRounding`.

`ControlConfig` additions: `topPaneMaxRatio` (0.5), `dividerHeight`,
`dividerSpacing`, `labelNotifications`, `labelClearAll`. Removal:
`maxHeightRatio`.

`NotifConfig` additions: `historyDir`, `historyFile`, `historyVersion`,
`historyMaxEntries` (200), `historyMaxAgeDays`, `historySaveDebounce` (1000),
`historySweepInterval`, card and row sizing tokens, `emptyTitle`,
`emptySubtitle`.

`Fmt.relativeTime(ms)` returns `now` / `Nm` / `Nh` / `Nd` using the existing
`Units.msPerMinute` and `Units.msPerDay` constants.

## Verification

There is no test framework in this config and QML does not lend itself to one.
The gate is the one established by the previous refactor: `qmllint` is useless
here, so correctness is proven by a **non-instantiating `probe.qml` loaded with
`qs -p`**. That file is not currently in the tree and must be rebuilt, referencing
every new type.

Manual matrix — every item is stateful, so each is checked explicitly:

1. Each of the three pills opens the panel on its own tab. `Super+W`, `Super+V`
   and the new toggle and bluetooth shortcuts do the same.
2. `←` and `→` wrap through all three tabs. The pane height animates and caps on a
   long wifi list; the notification list keeps the remainder.
3. A notification arriving while the panel is **closed** raises a toast *and*
   lands in the list. Arriving while **open** raises no toast and lands in the
   list only.
4. **`clear all`, then `cat` the JSON file and confirm `entries` is empty**, then
   reload the shell and confirm nothing returns. This is an explicit disk check,
   not a visual one.
5. A hand-doctored file with a stale timestamp and an over-cap entry count loses
   both on load.
6. `Net.scanning` is false when the panel is closed and when another tab is
   active; true only on the visible network pane.
7. Actions render on a live entry and are absent on a stored one after expiry.
8. Regression: dashboard tabs still work after `TabStrip` moves; the media pane
   still works after `EmptyState` moves.

## Out of scope

- Do-not-disturb (offered, declined).
- Renaming the module to `sidebar`.
- Inline reply, notification filtering rules, per-app mute.
- Exclusive-zone docking.
