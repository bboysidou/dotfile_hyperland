# Caelestia — deliberately not ported

Scanned `caelestia-dots/shell` on 2026-09-04. Tiers 1–3 (motion tokens, reusable
primitives, bar entry model) landed. These four are the parts that were *not*
taken, with what each is, why it was left, and the concrete route to doing it
later.

> **Update 2026-09-04.** The dashboard drawer has since been ported — see
> `dashboard.md`. Items 1-4 below still stand.

---

## 1. Blobs — `BlobGroup` / `BlobRect` / `BlobInvertedRect` / `WavyTopRect`

**What it is.** Panels are not rectangles. Each one registers as a signed-distance
field in a shared `BlobGroup`; overlapping fields merge with a smooth-min, so a
drawer opening out of the bar reads as one liquid surface deforming, not two
rectangles meeting. `BlobInvertedRect` carves the screen border the same way.
The deform matrices in `ContentWindow.qml` (`deformScale`, `rawDeformMatrix`)
are fed back into each panel's `transform`, so the *content* squashes with the
shape.

**Why deferred.** C++ `QQuickItem` subclasses plus custom `QSGMaterial` shaders,
built by CMake against Quickshell's plugin headers. A pure-QML config cannot load
them.

**Route to doing it.**
1. Sources: `plugin/src/Caelestia/Blobs/{blobgroup,blobrect,blobinvertedrect,blobshape,blobmaterial}.{cpp,hpp}` and their `.frag`/`.vert`.
2. Needs `qt6-shadertools` — `qsb` compiles the shaders to `.qsb` at build time.
3. Write a `CMakeLists.txt` with `qt_add_qml_module(URI Caelestia.Blobs VERSION 1.0)`, install the module onto a directory in `QML_IMPORT_PATH`, then `import Caelestia.Blobs`.
4. Only meaningful **after** item 2 — blobs merge within one scene graph, so with a window per surface there is nothing to merge.

**Cheaper approximation, no C++.** Classic two-pass metaball: put the panel rects
on one `layer.enabled` item, `MultiEffect` blur it, then re-sharpen with
`maskThresholdMin`. Overlapping blurred edges fuse. Costs one fullscreen layer and
gives no deform matrices, so content will not squash — but the join reads right.

---

## 2. `Drawers` / `Regions` / `Exclusions` — the single fullscreen window

> **Partly done, 2026-09-04.** `modules/border/` now implements the window, the
> exclusions and the frame. What is still deferred is *moving the panels into it*.
> See "Sticking things to the border" at the end of this file for the recipe.


**What it is.** One layershell window per monitor covering the whole screen, with
`WlrLayershell.exclusionMode: ExclusionMode.Ignore`. Every surface is a child
`Item`. Click-through is a **region**, not a window: `Regions.qml` builds the
inner rect `Intersection.Xor` one `Subtract` region per panel, so the compositor
routes input only where a panel geometrically is. Because the big window ignores
exclusion, edge space is reserved by four separate invisible 1×1 windows
(`Exclusions.qml`).

**Why deferred.** It only earns its complexity when surfaces must share a scene
graph — for blobs, or for a panel that visually detaches from the bar. This config
is one `PanelWindow` per surface, which is simpler and has no mask to keep in sync.

**Route to doing it.**
- `modules/shell/ShellWindow.qml` — `PanelWindow` anchored to all four edges, `WlrLayershell.exclusionMode: ExclusionMode.Ignore`, `color: "transparent"`.
- `modules/shell/ShellRegions.qml` — root `Region { intersection: Intersection.Xor }`, one child `Region { intersection: Intersection.Subtract }` per panel bound to that panel's `x/y/width/height`. Assign as the window's `mask`.
- `modules/shell/ShellExclusions.qml` — `Scope` holding four 1×1 `PanelWindow`s, each `mask: Region {}` (empty region = fully click-through) and anchored to one edge with its `exclusiveZone`.
- Convert `Bar`, `ControlCenter`, `Launcher`, `Osd`, `Polkit`, `Picker`, `Notifications` from top-level `PanelWindow`s into plain `Item`s inside the shell window. `FocusedPanel`'s `visible` gate becomes a continuous `offsetScale` so panels animate rather than appear.
- Leave `Lock` alone — `WlSessionLock` must own its own surfaces.

**The trap.** The mask must track the show/hide animation frame for frame. A mask
that lags puts clicks on the wrong surface for ~300ms. Caelestia avoids this by
deriving the region geometry and the panel geometry from the *same* `offsetScale`
property rather than animating them separately.

---

## 3. `popouts/*` — the bar popout stack

**What it is.** A `StackView`-based popout host anchored to the bar edge.
`Bar.qml`'s `checkPopout(y)` hit-tests `childAt()` to decide which popout to show
and where to centre it; `ClipWrapper` handles the reveal clip and the detached
mode. Because the bar and the popout are in one coordinate space, moving the
cursor from one pill to the next *slides* the popout instead of closing and
reopening it.

**Why deferred.** Its positioning maths assumes item 2. With a window per surface
the equivalent is a popup window per pill.

**Route to doing it without the fullscreen window.**
- Add `property Component attachedPopout` to `core/components/Pill.qml`.
- `modules/bar/PopoutWindow.qml` — `PanelWindow` anchored top, `exclusiveZone: 0`, `margins.left` computed from the pill's `mapToGlobal(0, 0).x`.
- Reuse `RevealCard` for the reveal so it inherits the Tier 1 motion for free.
- Hover intent needs an open/close delay `Timer`, or the popout flickers when the cursor crosses a gap between pills.

**Worth taking on its own merit.** The *single hover router* — one `HoverHandler`
on the bar computing which entry is under the cursor — is better than N per-pill
handlers regardless of the window model, and it is the thing that makes the
slide-between-pills behaviour expressible at all.

---

## 4. `ScreenState` / `ShellState.ComponentRef`

**What it is.** `ScreenState` is a `PersistentProperties` bag of per-monitor UI
state (which drawer is open, dashboard tab and date). `ShellState.ComponentRef`
is a service-side registry that lets any file reach another monitor's live
component by slot name — `"bar"`, `"panels"`, `"rootWindow"`.

**Why deferred.** This config keeps state in per-module singletons
(`ControlState`, `services/Osd`, `services/Lock`) and shows one surface per
window, so there is no cross-screen component to look up.

**Route to doing it, if per-monitor state ever needs to diverge.**
- `core/state/ScreenState.qml` — `PersistentProperties` with `required property ShellScreen modelData`, instantiated inside the per-screen `Variants` delegate.
- `core/state/ShellState.qml` — singleton with `property var byScreen: ({})` keyed on `screen.name`.
- `PersistentProperties` needs an explicit `reloadableId` or the state is lost on every config reload.

**Not needed yet.** Nothing currently reads another screen's state, and
`Monitors.focused` already covers the "which screen is active" case.

---

## Sticking things to the border

`modules/border/` ships the container: one fullscreen layershell window per monitor
(`BorderWindow`), three 1x1 exclusion windows reserving the left/right/bottom edges
(`BorderExclusions` — the top edge is already reserved by the bar), and the frame
itself (`BorderFrame`, one `Shape` whose `ShapePath` uses `OddEvenFill`: the screen
rect with the inner rounded rect punched out of it).

### Window rounding is coupled to the frame's (2026-09-05)

Hyprland's `decoration.rounding` must equal `Appearance.border.rounding` minus
`gaps_out`, or the corners stop looking like corners. Two nested rounded rects keep
a uniform gap only when the inner radius is the outer radius minus the gap.

Today: frame rounding 20, `gaps_out = 2` (`hypr/config/general.lua`), so window
rounding is **18** (`hypr/config/decoration.lua`). At the previous 10 the window's
corner bulged ~1px *past* the frame's inner boundary — the 2px gap held along the
straight edges and vanished at all four corners, where `BorderWindow` (a `Top`
layer, drawn above windows) clipped the corner outright.

The exclusion zones set the rest: 8px (`border.thickness`) on the sides and bottom,
`bar.height` on top, with `gaps_out` applied inside that — so a window edge sits
10px from the screen edge.

Changing `border.rounding` or `gaps_out` means changing the other file too.

`BorderWindow.inner` is the attach point — an `Item` inset by the border thickness on
three sides and by thickness + bar height on top, so its bounds are exactly the usable
area inside the frame and below the bar. It has no children yet; that is what a panel
fills.

Attaching a panel is two edits in `BorderWindow.qml`:

1. Declare it inside `inner`, anchored to whichever edge it slides from:

```qml
Item {
    id: inner
    // ...
    SomePanel {
        id: somePanel
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }
}
```

2. Make that panel — and only that panel — accept input, by adding one child region
   to the window's mask:

```qml
mask: Region {
    Region {
        item: somePanel
    }
}
```

An empty `Region {}` is an empty input region, so the window is fully click-through
until a panel is listed. Child regions default to `Intersection.Combine`, so each one
adds its rect. `Region` also takes `radius` and the four per-corner radii, so a rounded
panel gets a matching rounded hit area.

**Use `WlrKeyboardFocus.OnDemand`, never `Exclusive`.** A panel in its own short-lived
window can use `Exclusive`, and the old `FocusedPanel` launcher did. On the border
window — which stays mapped for the whole session — `Exclusive` makes
`HyprlandFocusGrab` clear the instant it activates, so `onCleared` closes the panel the
same frame it opened. The symptom is a panel that never appears and an IPC `toggle` that
returns `open` every single time. Measured 2026-09-04: with `keyboardFocus: None` the
toggle alternates correctly, with `Exclusive` it does not, and `OnDemand` behaves like
`None` for the grab while still accepting keyboard input.

**Keep the mask and the animation on the same property.** If a panel slides in over
300ms while its region jumps to the final rect immediately, clicks land on the panel
before it is visible. Bind both to the same `revealed`/`offsetScale` value, the way
`BorderFrame.thickness` and `opacity` are both bound to `BorderWindow.revealed`.

**Fullscreen.** `BorderWindow.covered` checks the focused workspace's toplevels for
Hyprland fullscreen state > 1 (2 = fullscreen, 1 = maximize, which does *not* hide the
border). It drives `revealed`, so the frame animates away under a fullscreen window and
back afterwards, per monitor. Anything attached should read `revealed` too rather than
re-deriving the state.

### Attached so far

- **Control centre** — `ControlPanel`, top right, flush under the bar and against the
  right band. State was already in `ControlState`; `ControlCenter.qml` is now just the
  shortcuts and IPC.
- **Launcher** — `LauncherPanel`, bottom centre. State in `LauncherState` (singleton),
  shortcut and IPC in `Launcher.qml`, visual in the border.
- **Dashboard** — `DashboardPanel`, top centre, flush under the bar. State in
  `DashState`, shortcut and IPC in `Dashboard.qml`. Three tabs (dash, performance,
  media) in a flickable pager whose panel animates its size into each one. Opened by
  hovering the bar's centre clock *or* `SUPER + D`; only the keybind pins it and takes
  keyboard focus, because `BorderState.panelOpen` drives `WlrKeyboardFocus.OnDemand`
  and a hover-fed grab would steal focus from the focused window on every pass of the
  cursor. Full writeup in `dashboard.md`.
- **Wallpaper filmstrip** — caelestia's design, built into the launcher rather than a
  panel of its own. Typing `>wallpaper ` switches the launcher content from `AppList` to
  `WallpaperStrip`; the rest of the line filters. `modules/wallpaper/Picker.qml` keeps the
  `wallpaper-picker` shortcut and the `wallpaper` IPC target, but both now call
  `LauncherState.showWallpapers()`. The old grid (`PickerPanel`, `PickerState`, `Grid`,
  `Tile`) and its 16 `Appearance.wallpaper` keys were removed.

Both follow the pattern `ControlState` already used: a singleton owns the state so the
per-screen visual and the single-instance `GlobalShortcut`/`IpcHandler` can live in
different files. `BorderWindow` raises itself to `WlrLayer.Overlay` while any panel is
open, because Hyprland draws fullscreen windows above `WlrLayer.Top` — without it a
panel is invisible over a fullscreen window.

### The filmstrip

`WallpaperStrip` is a `PathView` over a straight horizontal `Path` with
`preferredHighlightBegin`/`End` at 0.5 and `StrictlyEnforceRange`, so the selection always
sits centred and the row slides under it. A `PathAttribute` named `z` raises the middle
item above its neighbours; `WallpaperCard` reads `PathView.isCurrentItem` / `onPath` to
scale between 1, 0.8 and 0, and carries an `Elevation` that fades in only on the current
card. `visibleItems` is forced odd (2 collapses to 1, any other even count drops by one)
so there is a true middle, and it is clamped to the number of matches so the ring never
repeats an entry.

**Preview must key off the selected path, not `currentItem`.** `WallpaperStrip` previews
the wallpaper live as the selection moves, via `Wallpaper.preview()` which sets `current`
without persisting; `Wallpaper.stopPreview()` restores from `committed`, and is called
both on the strip's destruction and from `LauncherState.hide()`. The trap: filtering the
model can change which entry sits under `currentIndex` while the index itself stays at 0,
and `onCurrentItemChanged` does not fire for that. Binding to `onSelectedChanged`
(`entries[currentIndex]`) catches both. Measured 2026-09-04: with `onCurrentItemChanged`
the preview kept showing the pre-filter wallpaper.

### Blending a panel into the border

Three things make a panel read as carved out of the border rather than floating on it:

1. **Same colour.** `Colours.bar` — the one token the bar background and `BorderFrame`
   both use, so retinting moves everything together.
2. **Square the attached corners.** A panel flush on one edge rounds only the corners
   that face open space: the launcher rounds its top two, the control centre only its
   bottom-left. Use `topLeftRadius` and friends, not `radius`.
3. **Fillet the junctions.** `core/components/Fillet.qml` is a square with one quarter
   disc removed — the concave piece that turns the 90 degree seam where a panel side meets
   a band into a smooth sweep. `origin` names the corner the disc is centred on, which is
   always **the corner pointing into the transparent region**. Both of the launcher's
   bottom junctions face outward and up (`topLeft`, `topRight`); both of the control
   centre's face down and left, so both are `bottomLeft`.

Set `transformOrigin` to the attached edge (`Item.Bottom`, `Item.TopRight`) so the reveal
scale grows out of the border instead of away from it.

**Do not build the fillet from even-odd plus `clip`.** The first version drew a square
and a full circle in one `OddEvenFill` path and relied on `clip: true` to hide the three
quarters of the circle outside the item. It leaves a 1px hairline down the edge where the
circle passes exactly through the square's corners, and only on some origins — the left
fillet was clean while the right one showed a 36px line. The current version draws the
exact region: two `PathLine`s and one `PathCubic` quarter-arc with the standard
`kappa = 0.5522847498`, no even-odd, no clip, nothing outside the bounds.

**`Rectangle` turns its border on the moment you set `border.color`.** The pen defaults to
width 1, so `RevealCard` setting only `border.color: Colours.accent` drew a 1px accent
outline on every card that never asked for one. `RevealCard` now sets `border.width: 0`
explicitly; the panels that want a border still set their own.

**Never preview from a binding that fires during construction.** `WallpaperStrip` drove
`Wallpaper.preview()` off `onSelectedChanged`, which fires while the view is still
resolving its initial index — measured six preview calls per open, two of them the wrong
wallpaper, which is the 1-2s flicker before the strip settles. Preview now fires only from
`step()`, `onMovementEnded`, and a filter change: zero calls on open, and the background
holds the current wallpaper until the user actually navigates.
