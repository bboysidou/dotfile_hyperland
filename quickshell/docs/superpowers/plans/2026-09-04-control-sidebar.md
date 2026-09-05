# Control Sidebar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the control-centre dropdown with a full-height right-edge panel holding a sound/network/bluetooth tab strip above a disk-backed notification history.

**Architecture:** `modules/controlcenter/` evolves in place — `ControlState.section` already means "which tab", so no state model changes. The three accordion sections become panes behind a tab strip reused from the dashboard; the accordion's collapse mechanism is repurposed for notification app cards. A new `NotifHistory` singleton owns a JSON file on disk, fed by the existing `Notifs.track()`.

**Tech Stack:** Quickshell (QML/Qt6), Hyprland, `FileView` with `atomicWrites` for persistence, Nerd Font glyphs.

**Spec:** `docs/superpowers/specs/2026-09-04-control-sidebar-design.md`

## Global Constraints

- **No comments in QML.** Naming carries intent. Tool directives only.
- **No magic numbers or strings.** Every size, duration, cap, label and path is a named constant in `core/config/Appearance.qml`.
- **Files stay under ~300 lines**, functions under ~50.
- **One component per file.** No inline sub-components except QML `component` declarations already used for repeated local shapes (`AudioSection.qml:12` sets the precedent).
- **Filenames are PascalCase** (QML type requirement), properties and functions camelCase.
- **Reuse before building.** Grep `core/components/` and `core/helpers/` first.
- **Layering:** `core/helpers/` must not import `qs.services`. Services may import `qs.core.*`. Modules may import anything.
- **This is not a git repository.** `git rev-parse` fails. Tasks end at a verification gate, not a commit. Do not run `git` commands.
- **There is no test framework.** The load gate is `probe.qml` under `qs -p` (Task 8), plus the per-task live checks below. `qmllint` is useless on this config — do not use it as evidence.
- Working directory for every command: `/home/sidouxp3/.config/quickshell`

### Reload / verify loop used by every task

```bash
cd /home/sidouxp3/.config/quickshell
qs -p . 2>&1 | tail -40          # load-only check, no instantiation (after Task 8: qs -p probe.qml)
```

To exercise the running shell:

```bash
qs ipc call controlcenter status
qs ipc call controlcenter open network
qs ipc call controlcenter close
```

To read the shell's log for `ReferenceError` / `Unable to assign`:

```bash
journalctl --user -u quickshell --since "1 min ago" 2>/dev/null || qs log | tail -60
```

---

### Task 1: Configuration tokens, enums and helpers

Pure additive groundwork. Nothing renders differently after this task; it exists so no later task needs an inline literal.

**Files:**
- Modify: `core/config/Appearance.qml` (`ControlConfig` at :464, `NotifConfig` at :391, `DashConfig` tab tokens at :222-229)
- Modify: `core/constants/Units.qml`
- Modify: `core/enums/ControlSection.qml`
- Modify: `core/enums/BarEntry.qml`
- Modify: `core/helpers/Fmt.qml`
- Modify: `services/Net.qml`

**Interfaces:**
- Consumes: nothing.
- Produces: `Appearance.tab.*`, `Appearance.control.topPaneMaxRatio`, `Appearance.notif.history*`, `ControlSection.values`, `BarEntry.network`, `BarEntry.notifications`, `Fmt.relativeTime(timestamp: real): string`, `Net.glyph: string`, `Units.minutesPerHour`, `Units.hoursPerDay`.

- [ ] **Step 1: Add the missing time units**

In `core/constants/Units.qml`, inside the `Singleton`:

```qml
    readonly property int minutesPerHour: 60
    readonly property int hoursPerDay: 24
```

- [ ] **Step 2: Extract the shared tab tokens into a new `TabConfig`**

In `core/config/Appearance.qml`, delete lines 222-229 from `DashConfig` (`tabHeight`, `tabSpacing`, `tabPaddingH`, `tabIconSpacing`, `tabRounding`, `tabIconSize`, `tabIndicatorHeight`, `tabIndicatorRounding`) and add a new component beside the others:

```qml
    component TabConfig: QtObject {
        readonly property int height: 34
        readonly property int spacing: 4
        readonly property int paddingH: 16
        readonly property int iconSpacing: 8
        readonly property int rounding: 12
        readonly property int iconSize: 15
        readonly property int indicatorHeight: 3
        readonly property int indicatorRounding: 2
    }
```

Then register it next to the other instances (near line 644):

```qml
    readonly property TabConfig tab: TabConfig {}
```

- [ ] **Step 3: Add the control-panel tokens and drop the dead one**

In `ControlConfig` (line 464): delete `maxHeightRatio` (line 467), then add:

```qml
        readonly property real topPaneMaxRatio: 0.5
        readonly property int tabStripMargin: 10
        readonly property int paneSpacing: 8
```

- [ ] **Step 4: Add the notification-history tokens**

In `NotifConfig` (line 391), append:

```qml
        readonly property string historyFile: "notifications.json"
        readonly property int historyVersion: 1
        readonly property int historyMaxEntries: 200
        readonly property int historyMaxAgeDays: 7
        readonly property int historySaveDebounce: 1000
        readonly property int historySweepInterval: 3600000
        readonly property int cardRounding: 12
        readonly property int cardSpacing: 6
        readonly property int cardHeaderHeight: 34
        readonly property int cardPaddingH: 10
        readonly property int cardIconSize: 18
        readonly property int rowSpacing: 4
        readonly property int rowPaddingV: 6
        readonly property int rowPaddingH: 10
        readonly property int rowRounding: 10
        readonly property int bodyMaxLines: 2
        readonly property int listSpacing: 6
        readonly property int headerHeight: 28
        readonly property int badgePaddingH: 6
        readonly property int badgeRounding: 999
        readonly property string relativeNow: "now"
        readonly property string labelNotifications: "Notifications"
        readonly property string labelClearAll: "Clear all"
        readonly property string emptyTitle: "All caught up"
        readonly property string emptySubtitle: "Nothing waiting for you"
```

- [ ] **Step 5: Add the section values list**

Replace `core/enums/ControlSection.qml` entirely:

```qml
pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string network: "network"
    readonly property string bluetooth: "bluetooth"
    readonly property string audio: "audio"

    readonly property var values: [root.audio, root.network, root.bluetooth]
}
```

Order matters — it is the left-to-right tab order and must match the bar pill order set in Task 7.

- [ ] **Step 6: Add the two new bar entries**

In `core/enums/BarEntry.qml`, add beside the existing entries:

```qml
    readonly property string network: "network"
    readonly property string notifications: "notifications"
```

- [ ] **Step 7: Add `Fmt.relativeTime`**

In `core/helpers/Fmt.qml`, add to the `Singleton`. It needs `qs.core.config` for `Appearance.notif.relativeNow` — add that import if the file lacks it:

```qml
    function relativeTime(timestamp: real): string {
        const delta = Date.now() - timestamp;

        if (delta < Units.msPerMinute)
            return Appearance.notif.relativeNow;

        const minutes = Math.floor(delta / Units.msPerMinute);
        if (minutes < Units.minutesPerHour)
            return `${minutes}m`;

        const hours = Math.floor(minutes / Units.minutesPerHour);
        if (hours < Units.hoursPerDay)
            return `${hours}h`;

        return `${Math.floor(delta / Units.msPerDay)}d`;
    }
```

- [ ] **Step 8: Move the network glyph expression onto the service**

`NetworkSection.qml:21-29` computes this inline; the bar pill in Task 7 needs the identical expression. `core/helpers/Glyphs.qml` cannot host it — it does not import `qs.services` and must not, per the layering constraint. `services/Net.qml` already imports `qs.core.config` and `qs.core.helpers`, so it goes there.

In `services/Net.qml`, beside the other readonly properties:

```qml
    readonly property string glyph: {
        if (root.activeNetwork)
            return Glyphs.wifi(root.signalPercent(root.activeNetwork));
        if (root.wiredDevice?.connected)
            return Icons.ethernet;
        if (!root.wifiEnabled)
            return Icons.wifiDisabled;
        return Icons.wifiOff;
    }
```

- [ ] **Step 9: Verify nothing broke**

```bash
cd /home/sidouxp3/.config/quickshell
grep -rn "Appearance.dash.tab" --include="*.qml" .
```

Expected: exactly one file still references the removed tokens — `modules/dashboard/components/TabStrip.qml`. That is fixed in Task 2. Then:

```bash
qs -p . 2>&1 | tail -40
```

Expected: errors *only* from `TabStrip.qml` about the removed `Appearance.dash.tab*` properties. Any other error is a Task 1 defect — fix before proceeding.

---

### Task 2: Promote `TabStrip` and `EmptyState` into `core/components/`

Both are 90% right for a second consumer. The reuse rule is *generalise in place, never fork a copy*. This task leaves the dashboard behaviourally identical and unblocks the sidebar's tab strip.

**Files:**
- Create: `core/components/TabStrip.qml`
- Create: `core/components/EmptyState.qml`
- Delete: `modules/dashboard/components/TabStrip.qml`
- Delete: `modules/dashboard/media/EmptyState.qml`
- Modify: `modules/dashboard/DashboardPanel.qml:77-87`
- Modify: `modules/dashboard/media/MediaPane.qml`

**Interfaces:**
- Consumes: `Appearance.tab.*` (Task 1).
- Produces: `TabStrip { tabs: var; current: string; signal selected(string) }` and `EmptyState { glyph: string; title: string; subtitle: string }`, both importable from `qs.core.components`.

- [ ] **Step 1: Create the generalised tab strip**

`core/components/TabStrip.qml` — the dashboard's version with `tabs` lifted to a required property and `Appearance.dash.tab*` swapped for `Appearance.tab.*`:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.config
import qs.core.enums

RowLayout {
    id: root

    required property var tabs

    property string current: ""

    signal selected(string section)

    spacing: Appearance.tab.spacing

    Repeater {
        model: root.tabs

        StyledRect {
            id: tab

            required property var modelData

            readonly property bool active: root.current === tab.modelData.section

            Layout.preferredWidth: (content.implicitWidth || 0) + Appearance.tab.paddingH * 2
            Layout.preferredHeight: Appearance.tab.height

            color: tab.active ? Colours.hover : "transparent"
            radius: Appearance.tab.rounding

            StateLayer {
                radius: parent.radius

                onClicked: root.selected(tab.modelData.section)
            }

            RowLayout {
                id: content

                anchors.centerIn: parent

                spacing: Appearance.tab.iconSpacing

                Icon {
                    text: tab.modelData.icon
                    color: tab.active ? Colours.accent : Colours.textMuted
                    font.pixelSize: Appearance.tab.iconSize
                }

                StyledText {
                    text: tab.modelData.label
                    color: tab.active ? Colours.textBright : Colours.textMuted
                    font.weight: tab.active ? Appearance.font.weightActive : Appearance.font.weightNormal
                }
            }

            StyledRect {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                width: tab.active ? (content.implicitWidth || 0) : 0
                height: Appearance.tab.indicatorHeight
                radius: Appearance.tab.indicatorRounding
                color: Colours.accent

                Behavior on width {
                    Anim {
                        type: AnimType.emphasizedSmall
                    }
                }
            }
        }
    }
}
```

Note the dropped `import qs.core.components` — inside `core/components/` its siblings resolve without it.

- [ ] **Step 2: Delete the dashboard's copy**

```bash
rm modules/dashboard/components/TabStrip.qml
```

- [ ] **Step 3: Give the dashboard its tab list**

In `modules/dashboard/DashboardPanel.qml`, add `import qs.core.components` if absent (it is already there at line 6), and replace the `TabStrip` block at lines 77-87 with:

```qml
    TabStrip {
        id: tabs

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Appearance.dash.padding

        current: DashState.tab
        tabs: [
            {
                section: DashSection.dash,
                icon: Icons.dashTab,
                label: Appearance.dash.labelDash
            },
            {
                section: DashSection.performance,
                icon: Icons.perfTab,
                label: Appearance.dash.labelPerformance
            },
            {
                section: DashSection.media,
                icon: Icons.mediaTab,
                label: Appearance.dash.labelMedia
            }
        ]

        onSelected: section => DashState.tab = section
    }
```

- [ ] **Step 4: Create the generalised empty state**

`core/components/EmptyState.qml`:

```qml
import QtQuick
import QtQuick.Layouts
import qs.core.config

ColumnLayout {
    id: root

    required property string glyph
    required property string title
    required property string subtitle

    property int glyphSize: Appearance.dash.emptyIconSize
    property int titleSize: Appearance.dash.detailArtistSize
    property int subtitleSize: Appearance.dash.cardLabelSize

    spacing: Appearance.dash.emptySpacing

    Icon {
        Layout.alignment: Qt.AlignHCenter

        text: root.glyph
        color: Colours.accent
        font.pixelSize: root.glyphSize
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Appearance.dash.cardSpacing

        text: root.title
        color: Colours.textBright
        font.pixelSize: root.titleSize
        font.weight: Appearance.font.weightActive
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter

        text: root.subtitle
        color: Colours.textMuted
        font.pixelSize: root.subtitleSize
    }
}
```

- [ ] **Step 5: Delete the dashboard's copy and update its caller**

```bash
rm modules/dashboard/media/EmptyState.qml
grep -n "EmptyState" modules/dashboard/media/MediaPane.qml
```

At the `EmptyState {}` usage in `MediaPane.qml`, supply the three properties it previously hardcoded, and ensure `import qs.core.components` is present:

```qml
                EmptyState {
                    glyph: Icons.mediaTab
                    title: Appearance.dash.emptyTitle
                    subtitle: Appearance.dash.emptySubtitle
                }
```

Preserve any `anchors` or `Layout` attached properties already on that usage — copy them across unchanged.

- [ ] **Step 6: Verify — load gate plus dashboard regression**

```bash
qs -p . 2>&1 | tail -40
```

Expected: no errors.

Then with the shell running:

```bash
qs ipc call dashboard open
```

Check by eye: all three dashboard tabs render, the active-tab underline animates when switching, and the media tab's empty state still appears with no player running. A missing underline means `Appearance.tab.indicator*` did not get wired in Step 1.

---

### Task 3: The notification store

No UI. This task is complete when entries persist to disk and survive a shell restart, provable with `cat`.

**Files:**
- Create: `services/NotifEntry.qml`
- Create: `services/NotifHistory.qml`

**Interfaces:**
- Consumes: `Appearance.notif.history*` (Task 1), `Paths.state`, `Appearance.state.dir`.
- Produces: `NotifHistory.entries`, `.groups`, `.unread`, `.remember(notification)`, `.detach(notification)`, `.dismiss(entry)`, `.clearApp(appName)`, `.clear()`, `.markAllRead()`.

- [ ] **Step 1: Create the entry object**

`services/NotifEntry.qml` — a dumb data holder. It carries no logic so that persistence, grouping and expiry all live in one place.

```qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: root

    property string key
    property string appName
    property string desktopEntry
    property string summary
    property string body
    property string image
    property int urgency: NotificationUrgency.Normal
    property double time
    property bool read

    property Notification notification

    readonly property bool live: root.notification !== null
    readonly property bool critical: root.urgency === NotificationUrgency.Critical

    readonly property var actions: root.live && !root.notification.closed ? root.notification.actions : []
    readonly property var buttons: root.actions.filter(action => action.identifier !== "default")
    readonly property NotificationAction defaultAction: root.actions.find(action => action.identifier === "default") ?? null

    function serialise(): var {
        return {
            key: root.key,
            appName: root.appName,
            desktopEntry: root.desktopEntry,
            summary: root.summary,
            body: root.body,
            image: root.image,
            urgency: root.urgency,
            time: root.time,
            read: root.read
        };
    }
}
```

- [ ] **Step 2: Create the store**

`services/NotifHistory.qml`. Persistence copies the idiom already proven at `services/Apps.qml:97-105` — `FileView` with `atomicWrites`, `setText(JSON.stringify(...))` on write, `onLoaded: adopt(text())` on read.

```qml
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core.config
import qs.core.helpers

Singleton {
    id: root

    readonly property string stateDir: `${Paths.state}/${Appearance.state.dir}`
    readonly property string statePath: `${root.stateDir}/${Appearance.notif.historyFile}`

    property list<NotifEntry> entries: []
    property int counter: 0

    readonly property int unread: root.toArray().filter(entry => !entry.read).length

    readonly property var groups: {
        const buckets = new Map();

        for (const entry of root.toArray()) {
            const existing = buckets.get(entry.appName);

            if (existing)
                existing.entries.push(entry);
            else
                buckets.set(entry.appName, {
                    appName: entry.appName,
                    desktopEntry: entry.desktopEntry,
                    image: entry.image,
                    latest: entry.time,
                    entries: [entry]
                });
        }

        return Array.from(buckets.values()).sort((first, second) => second.latest - first.latest);
    }

    function toArray(): var {
        const out = [];

        for (let i = 0; i < root.entries.length; i++)
            out.push(root.entries[i]);

        return out;
    }

    function remember(notification): void {
        root.counter += 1;

        const entry = component.createObject(root, {
            key: `${Date.now()}-${root.counter}`,
            appName: notification.appName || Appearance.notif.labelNotifications,
            desktopEntry: notification.desktopEntry ?? "",
            summary: notification.summary ?? "",
            body: notification.body ?? "",
            image: root.resolve(notification),
            urgency: notification.urgency,
            time: Date.now(),
            read: false,
            notification
        });

        root.entries = [entry].concat(root.toArray());
        root.sweep();
        root.save();
    }

    function resolve(notification): string {
        if (notification.image)
            return notification.image;

        if (notification.appIcon)
            return Fmt.icon(notification.appIcon);

        const lookup = notification.desktopEntry || notification.appName;
        const entry = lookup ? DesktopEntries.heuristicLookup(lookup) : null;
        return entry?.icon ? Fmt.icon(entry.icon) : "";
    }

    function detach(notification): void {
        for (const entry of root.toArray())
            if (entry.notification === notification)
                entry.notification = null;
    }

    function dismiss(entry: NotifEntry): void {
        entry.notification?.dismiss();
        root.drop(list => list.filter(candidate => candidate !== entry));
    }

    function clearApp(appName: string): void {
        root.drop(list => list.filter(entry => entry.appName !== appName));
    }

    function clear(): void {
        root.drop(() => []);
    }

    function drop(transform): void {
        const kept = transform(root.toArray());

        for (const entry of root.toArray())
            if (!kept.includes(entry))
                entry.destroy();

        root.entries = kept;
        root.flush();
    }

    function markAllRead(): void {
        let changed = false;

        for (const entry of root.toArray())
            if (!entry.read) {
                entry.read = true;
                changed = true;
            }

        if (changed)
            root.save();
    }

    function sweep(): void {
        const oldest = Date.now() - Appearance.notif.historyMaxAgeDays * Units.msPerDay;
        const fresh = root.toArray().filter(entry => entry.time >= oldest);
        const capped = fresh.slice(0, Appearance.notif.historyMaxEntries);

        if (capped.length === root.entries.length)
            return;

        for (const entry of root.toArray())
            if (!capped.includes(entry))
                entry.destroy();

        root.entries = capped;
    }

    function save(): void {
        debounce.restart();
    }

    function flush(): void {
        debounce.stop();
        store.setText(JSON.stringify({
            version: Appearance.notif.historyVersion,
            entries: root.toArray().map(entry => entry.serialise())
        }));
    }

    function adopt(payload: string): void {
        let parsed;

        try {
            parsed = JSON.parse(payload);
        } catch (e) {
            console.warn("NotifHistory: store is not valid JSON, starting empty");
            return;
        }

        if (!parsed || parsed.version !== Appearance.notif.historyVersion || !Array.isArray(parsed.entries))
            return;

        root.entries = parsed.entries.map(raw => component.createObject(root, raw));
        root.sweep();
    }

    readonly property Component component: Component {
        NotifEntry {}
    }

    readonly property Timer debounce: Timer {
        interval: Appearance.notif.historySaveDebounce

        onTriggered: root.flush()
    }

    readonly property Timer sweeper: Timer {
        interval: Appearance.notif.historySweepInterval
        running: true
        repeat: true

        onTriggered: root.sweep()
    }

    readonly property Process ensureDir: Process {
        running: true

        command: ["mkdir", "-p", root.stateDir]
    }

    readonly property FileView store: FileView {
        path: root.statePath
        atomicWrites: true
        printErrors: false

        onLoaded: root.adopt(text())
    }
}
```

Three things to be deliberate about, because they are the whole point of the task:

1. `clear()`, `clearApp()` and `dismiss()` all route through `drop()`, which calls **`flush()`, not `save()`** — a clear that has not reached disk is a clear a reload undoes.
2. `flush()` writes `{"version":1,"entries":[]}` rather than deleting the file, so `adopt()` keeps a single code path.
3. `adopt()` restores entries with `notification` unset, so `entry.live` is false and Task 6 will correctly hide their action buttons.

`Units` and `Fmt` come from `qs.core.helpers`; `DesktopEntries` from `Quickshell`. If `Units` is under `qs.core.constants` in this tree, add that import too — check with `grep -rn "import qs.core.constants" services/`.

- [ ] **Step 3: Verify the file loads**

```bash
qs -p . 2>&1 | tail -40
```

Expected: no errors. `NotifHistory` is not referenced by anything yet, so a singleton that fails to construct will surface here rather than at runtime.

- [ ] **Step 4: Verify persistence by hand**

Restart the shell, then:

```bash
qs ipc call controlcenter status
cat ~/.local/state/quickshell/notifications.json 2>/dev/null || echo "not written yet"
```

Expected: "not written yet" — nothing calls `remember()` until Task 4. That is the correct result for this task; the file appearing now would mean something is writing that should not be.

---

### Task 4: Feed the store and suppress toasts

**Files:**
- Modify: `services/Notifs.qml:21-41` (`track`), `:47-51` (`forget`)
- Modify: `modules/notifications/Notifications.qml:19`

**Interfaces:**
- Consumes: `NotifHistory.remember`, `.detach` (Task 3); `ControlState.opened`.
- Produces: a populated `notifications.json`.

- [ ] **Step 1: Record every tracked notification**

In `services/Notifs.qml`, inside `track()`, after the existing duplicate check returns and immediately before `const wrapper = component.createObject(...)`:

```qml
        NotifHistory.remember(notification);
```

Placing it after the `existing` early-return matters: a notification the server re-sends to update an existing popup must not create a second history entry.

- [ ] **Step 2: Cut the live reference when the popup dies**

In `services/Notifs.qml`, inside `forget()`, before `wrapper.destroy()`:

```qml
        NotifHistory.detach(wrapper.notification);
```

After this the history entry survives with `notification` null — text and icon intact, action buttons gone. That is the intended platform-limited behaviour, not a bug.

- [ ] **Step 3: Suppress toasts while the panel is open**

In `modules/notifications/Notifications.qml`, add the import:

```qml
import qs.modules.controlcenter
```

and change line 19:

```qml
        shown: Notifs.stack.length > 0 && !ControlState.opened
```

Module-to-module import is the established pattern here — `modules/bar/components/VolumePill.qml:6` and `BluetoothPill.qml:5` both import `qs.modules.controlcenter`. A `suppressed` flag on the `Notifs` service was considered and rejected: it would make a service depend on a module, inverting the layering.

- [ ] **Step 4: Verify the store fills**

Reload the shell, then:

```bash
notify-send "Task 4 check" "first entry"
sleep 2
cat ~/.local/state/quickshell/notifications.json | python3 -m json.tool
```

Expected: `version: 1` and one entry with `summary: "Task 4 check"`, `read: false`, a `time` near now.

- [ ] **Step 5: Verify it survives a restart**

Restart the shell, then:

```bash
cat ~/.local/state/quickshell/notifications.json | python3 -m json.tool
```

Expected: the same entry still present. Then send a second notification and confirm the array grows to two rather than resetting to one — a reset means `adopt()` is running after the first `remember()` and the load ordering needs fixing.

- [ ] **Step 6: Verify suppression**

```bash
qs ipc call controlcenter open audio
notify-send "Suppressed" "should not appear as a toast"
```

Expected: no toast appears. Then:

```bash
qs ipc call controlcenter close
notify-send "Visible" "should appear as a toast"
```

Expected: a toast appears. Both notifications are in the JSON file either way.

---

### Task 5: Panes and the full-height panel

The largest task, and it must land in one piece: converting the sections to panes without rewriting the panel would leave nothing on screen.

**Files:**
- Create: `modules/controlcenter/panes/Pane.qml`
- Create: `modules/controlcenter/panes/PaneHeader.qml`
- Create: `modules/controlcenter/panes/AudioPane.qml`
- Create: `modules/controlcenter/panes/NetworkPane.qml`
- Create: `modules/controlcenter/panes/BluetoothPane.qml`
- Rewrite: `modules/controlcenter/ControlPanel.qml`
- Modify: `modules/controlcenter/ControlState.qml`
- Modify: `modules/border/BorderWindow.qml:110-117`
- Delete: `modules/controlcenter/components/Section.qml`, `AudioSection.qml`, `BluetoothSection.qml`, `NetworkSection.qml`

**Interfaces:**
- Consumes: `TabStrip` (Task 2), `ControlSection.values`, `Appearance.control.topPaneMaxRatio`, `Net.glyph` (Task 1), `NotifHistory.markAllRead` (Task 3).
- Produces: `ControlState.togglePanel()`; `NetworkPane.dismiss()`; panes exposing `implicitHeight` for the cap calculation.

- [ ] **Step 1: Create the pane base**

A pane must scroll vertically while the `Row` above it slides horizontally, so each pane is its own `Flickable`. `implicitHeight` reports the content height so the panel can compute the cap.

`modules/controlcenter/panes/Pane.qml`:

```qml
import QtQuick
import QtQuick.Layouts
import qs.core.config

Flickable {
    id: root

    default property alias content: layout.data

    implicitHeight: layout.implicitHeight

    contentHeight: layout.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: layout

        width: root.width

        spacing: Appearance.control.paneSpacing
    }
}
```

- [ ] **Step 2: Create the pane header**

This is `Section.qml`'s header half — glyph, title, optional control slot — with the chevron and click-to-expand removed. It is what keeps the wifi and bluetooth toggles alive now that the accordion is gone.

`modules/controlcenter/panes/PaneHeader.qml`:

```qml
import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config

StyledRect {
    id: root

    property string glyph
    property string title
    property Component control: null

    Layout.fillWidth: true
    Layout.preferredHeight: Appearance.control.sectionHeaderHeight

    color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Appearance.control.rowPaddingH
        anchors.rightMargin: Appearance.control.rowPaddingH

        spacing: Appearance.control.sectionHeaderSpacing

        Icon {
            text: root.glyph
            font.pixelSize: Appearance.control.sectionIconSize
            color: Colours.textBright
        }

        StyledText {
            Layout.fillWidth: true

            text: root.title
            color: Colours.textBright
            elide: Text.ElideRight
        }

        Loader {
            active: root.control !== null
            sourceComponent: root.control
        }
    }
}
```

- [ ] **Step 3: Create the audio pane**

Body copied verbatim from `AudioSection.qml:12-81`; only the root type and the header change.

`modules/controlcenter/panes/AudioPane.qml`:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.controlcenter.components
import qs.services

Pane {
    id: root

    component GroupLabel: StyledText {
        Layout.fillWidth: true
        Layout.leftMargin: Appearance.control.rowPaddingH
        Layout.topMargin: Appearance.control.sectionContentSpacing

        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }

    PaneHeader {
        glyph: Audio.muted ? Icons.volumeMuted : Icons.speaker
        title: Appearance.control.labelAudio
    }

    GroupLabel {
        text: Appearance.control.labelOutput
    }

    Repeater {
        model: Audio.sinks

        AudioDevice {
            required property var modelData

            Layout.fillWidth: true

            node: modelData
            selected: modelData === Audio.sink
            glyph: Icons.speaker
            mutedGlyph: Icons.volumeMuted

            onActivated: Audio.setSink(modelData)
        }
    }

    GroupLabel {
        text: Appearance.control.labelInput
    }

    Repeater {
        model: Audio.sources

        AudioDevice {
            required property var modelData

            Layout.fillWidth: true

            node: modelData
            selected: modelData === Audio.source
            glyph: Icons.microphone
            mutedGlyph: Icons.microphoneMuted

            onActivated: Audio.setSource(modelData)
        }
    }

    GroupLabel {
        visible: Audio.streams.length > 0
        text: Appearance.control.labelStreams
    }

    Repeater {
        model: Audio.streams

        StreamEntry {
            required property var modelData

            Layout.fillWidth: true

            node: modelData
        }
    }
}
```

- [ ] **Step 4: Create the bluetooth pane**

`modules/controlcenter/panes/BluetoothPane.qml` — body from `BluetoothSection.qml:13-65`:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.modules.controlcenter.components
import qs.services

Pane {
    id: root

    function activate(device): void {
        if (!device)
            return;

        if (device.connected)
            Bt.disconnectDevice(device);
        else
            Bt.connectDevice(device);
    }

    PaneHeader {
        glyph: Glyphs.bluetooth(Bt.enabled, Bt.connected)
        title: Appearance.control.labelBluetooth

        control: Component {
            Toggle {
                checked: Bt.enabled
                enabled: Bt.available

                onToggled: value => Bt.setEnabled(value)
            }
        }
    }

    Repeater {
        model: Bt.devices

        BluetoothEntry {
            required property var modelData

            Layout.fillWidth: true

            device: modelData

            onActivated: root.activate(modelData)
            onForgotten: Bt.forgetDevice(modelData)
        }
    }

    StyledText {
        Layout.fillWidth: true
        Layout.leftMargin: Appearance.control.rowPaddingH

        visible: Bt.devices.length === 0
        text: {
            const control = Appearance.control;
            if (!Bt.available)
                return control.emptyNoBluetooth;
            if (!Bt.enabled)
                return control.emptyBluetoothDisabled;
            return control.emptyNoDevices;
        }
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }
}
```

- [ ] **Step 5: Create the network pane**

`modules/controlcenter/panes/NetworkPane.qml` — body from `NetworkSection.qml`, with two changes called out below:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.modules.controlcenter.components
import qs.services

Pane {
    id: root

    property var pendingNetwork: null
    property var promptNetwork: null
    property string error: ""

    signal closeRequested

    function dismiss(): void {
        const wasPrompting = root.promptNetwork !== null;
        root.promptNetwork = null;
        root.error = "";
        prompt.reset();

        if (wasPrompting)
            root.forceActiveFocus();
    }

    function activate(network): void {
        if (!network)
            return;

        if (network.connected) {
            Net.disconnectFrom(network);
            return;
        }

        if (Net.enterprise(network)) {
            Quickshell.execDetached(Commands.networkEditor);
            root.closeRequested();
            return;
        }

        if (network.known || !Net.secured(network)) {
            root.pendingNetwork = network;
            root.error = "";
            Net.connectTo(network);
            return;
        }

        root.promptNetwork = network;
        root.error = "";
        prompt.reset();
        prompt.focusInput();
    }

    function submit(psk: string): void {
        const network = root.promptNetwork;
        if (!network)
            return;

        root.pendingNetwork = network;
        root.error = "";
        Net.connectToWithPsk(network, psk);
        root.dismiss();
    }

    PaneHeader {
        glyph: Net.glyph
        title: Appearance.control.labelNetwork

        control: Component {
            Toggle {
                checked: Net.wifiEnabled
                enabled: Net.wifiHardwareEnabled

                onToggled: value => Net.setWifiEnabled(value)
            }
        }
    }

    Connections {
        target: root.pendingNetwork

        function onConnectionFailed(reason: int): void {
            root.error = Net.failureText(reason);
            root.promptNetwork = root.pendingNetwork;
            root.pendingNetwork = null;
            prompt.reset();
            prompt.focusInput();
        }
    }

    StyledRect {
        Layout.fillWidth: true

        visible: Net.wiredDevice !== null
        color: "transparent"

        implicitHeight: Appearance.control.rowHeight

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Appearance.control.rowPaddingH
            anchors.rightMargin: Appearance.control.rowPaddingH

            spacing: Appearance.control.rowSpacing

            Icon {
                text: Net.wiredDevice?.connected ? Icons.ethernet : Icons.ethernetOff
                color: Net.wiredDevice?.connected ? Colours.highlight : Colours.textMuted
                font.pixelSize: Appearance.control.iconSize
            }

            StyledText {
                Layout.fillWidth: true

                text: Net.wiredDevice?.name ?? ""
                color: Colours.text
                elide: Text.ElideRight
            }

            StyledText {
                visible: Net.wiredDevice?.connected ?? false

                text: Appearance.control.labelConnected
                color: Colours.textMuted
                font.pixelSize: Appearance.font.size.small
            }
        }
    }

    Repeater {
        model: Net.networks

        NetworkEntry {
            required property var modelData

            Layout.fillWidth: true

            network: modelData

            onActivated: root.activate(modelData)
        }
    }

    StyledText {
        Layout.fillWidth: true
        Layout.leftMargin: Appearance.control.rowPaddingH

        visible: Net.networks.length === 0
        text: {
            const control = Appearance.control;
            if (!Net.wifiDevice)
                return control.emptyNoWifiDevice;
            if (!Net.wifiEnabled)
                return control.emptyWifiDisabled;
            return control.emptyScanning;
        }
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
    }

    PasswordPrompt {
        id: prompt

        Layout.fillWidth: true
        Layout.topMargin: Appearance.control.sectionContentSpacing

        visible: root.promptNetwork !== null
        networkName: root.promptNetwork?.name ?? ""
        error: root.error

        onSubmitted: psk => root.submit(psk)
        onCancelled: root.dismiss()
    }
}
```

Two deliberate changes from the original:

- `stateGlyph` is gone — the header reads `Net.glyph` from Task 1, so the pill and the pane share one expression.
- `onExpandedChanged: Net.scanning = root.expanded` is gone. `Net.scanning` is retargeted in Step 7. **Do not leave it unbound** — an unbound `Net.scanning` either never scans or scans forever.

- [ ] **Step 6: Add `togglePanel` to the state singleton**

In `modules/controlcenter/ControlState.qml`, add:

```qml
    function togglePanel(): void {
        root.opened = !root.opened;
    }
```

This is what the bell pill and the new global shortcut use: open on whatever tab was last active, rather than forcing one.

- [ ] **Step 7: Rewrite the panel**

Replace `modules/controlcenter/ControlPanel.qml` entirely:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQml.Models
import QtQuick.Window
import Quickshell.Widgets
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.controlcenter.notifications
import qs.modules.controlcenter.panes
import qs.services

RevealCard {
    id: root

    readonly property int index: ControlSection.values.indexOf(ControlState.section)
    readonly property Item pane: root.index >= 0 && repeater.count > root.index ? repeater.itemAt(root.index) : null
    readonly property real paneHeight: Math.min(root.pane?.implicitHeight ?? 0, root.height * Appearance.control.topPaneMaxRatio)

    function step(delta: int): void {
        const values = ControlSection.values;
        ControlState.section = values[Num.wrap(root.index, delta, values.length)];
    }

    function focusStep(forward: bool): void {
        const current = root.Window.activeFocusItem ?? root;
        const next = current.nextItemInFocusChain(forward);
        if (next)
            next.forceActiveFocus();
    }

    implicitWidth: Appearance.control.width

    color: Colours.bar
    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: 0
    bottomRightRadius: 0
    scaleFrom: Appearance.control.scaleFrom
    transformOrigin: Item.TopRight

    visible: root.revealed || root.opacity > 0
    focus: true

    onRevealedChanged: {
        if (root.revealed) {
            NotifHistory.markAllRead();
            root.forceActiveFocus();
        } else {
            network.dismiss();
        }
    }

    Keys.onEscapePressed: ControlState.hide()
    Keys.onLeftPressed: root.step(-1)
    Keys.onRightPressed: root.step(1)
    Keys.onDownPressed: root.focusStep(true)
    Keys.onUpPressed: root.focusStep(false)
    Keys.onPressed: event => {
        if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_N) {
            root.focusStep(true);
            event.accepted = true;
        } else if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_P) {
            root.focusStep(false);
            event.accepted = true;
        }
    }

    Fillet {
        anchors.right: parent.left
        anchors.top: parent.top

        origin: Corner.bottomLeft
    }

    Fillet {
        anchors.right: parent.left
        anchors.bottom: parent.bottom

        origin: Corner.topLeft
    }

    TabStrip {
        id: tabs

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Appearance.control.tabStripMargin

        current: ControlState.section
        tabs: [
            {
                section: ControlSection.audio,
                icon: Icons.speaker,
                label: Appearance.control.labelAudio
            },
            {
                section: ControlSection.network,
                icon: Net.glyph,
                label: Appearance.control.labelNetwork
            },
            {
                section: ControlSection.bluetooth,
                icon: Icons.bluetooth,
                label: Appearance.control.labelBluetooth
            }
        ]

        onSelected: section => ControlState.section = section
    }

    ClippingRectangle {
        id: viewport

        anchors.top: tabs.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Appearance.control.padding
        anchors.leftMargin: Appearance.control.padding
        anchors.rightMargin: Appearance.control.padding

        height: root.paneHeight
        color: "transparent"

        Behavior on height {
            Anim {
                type: AnimType.emphasizedSmall
            }
        }

        Row {
            id: row

            x: -(root.pane?.x ?? 0)

            Behavior on x {
                Anim {
                    type: AnimType.emphasized
                }
            }

            Repeater {
                id: repeater

                model: ControlSection.values

                DelegateChooser {
                    role: "modelData"

                    DelegateChoice {
                        roleValue: ControlSection.audio

                        delegate: AudioPane {
                            width: viewport.width
                            height: viewport.height
                        }
                    }
                    DelegateChoice {
                        roleValue: ControlSection.network

                        delegate: NetworkPane {
                            id: network

                            width: viewport.width
                            height: viewport.height

                            onCloseRequested: ControlState.hide()
                        }
                    }
                    DelegateChoice {
                        roleValue: ControlSection.bluetooth

                        delegate: BluetoothPane {
                            width: viewport.width
                            height: viewport.height
                        }
                    }
                }
            }
        }
    }

    NotifList {
        anchors.top: viewport.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Appearance.control.padding
    }

    Binding {
        target: Net
        property: "scanning"
        value: ControlState.opened && ControlState.section === ControlSection.network
    }
}
```

The trailing `Binding` is the retargeted `Net.scanning` from Step 5 — scanning runs only while the network pane is actually visible.

`network.dismiss()` in `onRevealedChanged` resolves to the `id: network` inside the `DelegateChoice`. If QML rejects that id reference from outside the delegate, replace the call with a null-guarded lookup on the repeater item:

```qml
            const pane = repeater.itemAt(ControlSection.values.indexOf(ControlSection.network));
            pane?.dismiss();
```

- [ ] **Step 8: Anchor the panel full height**

In `modules/border/BorderWindow.qml`, replace the `ControlPanel` block at lines 110-117:

```qml
        ControlPanel {
            id: control

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            revealed: root.focused && ControlState.opened
        }
```

The `mask` `Region` at line 46-48 needs no change.

- [ ] **Step 9: Delete the superseded sections**

```bash
rm modules/controlcenter/components/Section.qml \
   modules/controlcenter/components/AudioSection.qml \
   modules/controlcenter/components/BluetoothSection.qml \
   modules/controlcenter/components/NetworkSection.qml
grep -rn "Section {" --include="*.qml" modules/
```

Expected: no remaining references to the deleted `Section` type.

- [ ] **Step 10: Verify**

```bash
qs -p . 2>&1 | tail -40
```

Expected: errors only about `NotifList`, which does not exist until Task 6. To unblock this task's visual check, temporarily comment the `NotifList` block out — then restore it before starting Task 6.

With the shell running, check by eye:

1. Each pill and `Super+W` / `Super+V` opens the panel; it spans bar to bottom border on the right edge.
2. Both left corners are concave fillets flowing into the border, with no rounded stub or gap. **Fillet geometry is easy to get subtly wrong — trust the screen, not the reasoning.** If the bottom corner looks inverted, the `origin` on the second `Fillet` is wrong.
3. `←` and `→` wrap through audio → network → bluetooth and back.
4. The pane height animates between tabs and stops growing at half the panel; a long wifi list scrolls inside the pane.
5. The wifi and bluetooth toggles are present in their pane headers and still work.
6. Connecting to a secured network still shows the password prompt, and closing the panel clears it.

Then confirm the scanning binding:

```bash
qs ipc call controlcenter close
```

Wifi should stop scanning (no repeated network-list churn in the log).

---

### Task 6: The notification list UI

**Files:**
- Create: `modules/controlcenter/notifications/NotifList.qml`
- Create: `modules/controlcenter/notifications/NotifCard.qml`
- Create: `modules/controlcenter/notifications/NotifRow.qml`
- Modify: `modules/controlcenter/ControlPanel.qml` (restore the `NotifList` block if commented out in Task 5)

**Interfaces:**
- Consumes: `NotifHistory.groups`, `.entries`, `.unread`, `.clear()`, `.clearApp()`, `.dismiss()` (Task 3); `EmptyState` (Task 2); `Fmt.relativeTime` (Task 1); `NotifAction` from `qs.modules.notifications.components`.
- Produces: nothing downstream.

- [ ] **Step 1: Create the row**

`modules/controlcenter/notifications/NotifRow.qml`. Action buttons render only while the entry is live — `entry.live` is false for anything restored from disk or expired.

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.helpers
import qs.modules.notifications.components
import qs.services

StyledRect {
    id: root

    required property NotifEntry entry

    Layout.fillWidth: true
    Layout.preferredHeight: layout.implicitHeight + Appearance.notif.rowPaddingV * 2

    color: pointer.containsMouse ? Colours.hover : "transparent"
    radius: Appearance.notif.rowRounding

    StyledRect {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        visible: root.entry.critical
        width: Appearance.notif.edgeWidth
        radius: 0
        color: Colours.urgencyCritical
    }

    StateLayer {
        id: pointer

        radius: parent.radius
        disabled: !root.entry.defaultAction

        onClicked: {
            if (root.entry.defaultAction)
                root.entry.notification.actions.find(action => action.identifier === "default")?.invoke();
        }
    }

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Appearance.notif.rowPaddingH
        anchors.rightMargin: Appearance.notif.rowPaddingH

        spacing: Appearance.notif.rowSpacing

        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.notif.rowSpacing

            StyledText {
                Layout.fillWidth: true

                text: root.entry.summary
                color: root.entry.read ? Colours.text : Colours.textBright
                font.weight: Appearance.font.weightActive
                elide: Text.ElideRight
            }

            StyledText {
                text: Fmt.relativeTime(root.entry.time)
                color: Colours.textMuted
                font.pixelSize: Appearance.font.size.small
            }

            Icon {
                visible: pointer.containsMouse

                text: Icons.close
                color: Colours.textMuted

                StateLayer {
                    radius: parent.height

                    onClicked: NotifHistory.dismiss(root.entry)
                }
            }
        }

        StyledText {
            Layout.fillWidth: true

            visible: root.entry.body.length > 0
            text: root.entry.body
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
            wrapMode: Text.WordWrap
            maximumLineCount: Appearance.notif.bodyMaxLines
            elide: Text.ElideRight
        }

        RowLayout {
            visible: root.entry.buttons.length > 0

            spacing: Appearance.notif.actionSpacing

            Repeater {
                model: root.entry.buttons

                NotifAction {
                    required property var modelData

                    popup: null
                    action: modelData

                    onClicked: modelData.invoke()
                }
            }
        }
    }
}
```

`NotifAction` requires a `popup: Notif` property and calls `popup.invoke(action)`. Since history entries are not `Notif` wrappers, this usage passes `popup: null` and overrides `onClicked` to invoke the action directly. If QML rejects `popup: null` against a `required property Notif`, change `NotifAction.qml:10` from `required property Notif popup` to `property Notif popup` — the toast usage supplies it either way.

`Icons.close` must exist; if `grep -n "close" core/config/Icons.qml` finds nothing, add `readonly property string close: "󰅖"`.

- [ ] **Step 2: Create the app card**

`modules/controlcenter/notifications/NotifCard.qml`. The collapse mechanism — clipping wrapper plus a height `Behavior` — is lifted from the deleted `Section.qml:81-107`.

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.services

StyledRect {
    id: root

    required property var group

    property bool expanded: true

    implicitHeight: header.height + wrapper.height

    color: Colours.pill
    radius: Appearance.notif.cardRounding

    StyledRect {
        id: header

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: Appearance.notif.cardHeaderHeight
        radius: parent.radius
        color: "transparent"

        StateLayer {
            radius: parent.radius

            onClicked: root.expanded = !root.expanded
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Appearance.notif.cardPaddingH
            anchors.rightMargin: Appearance.notif.cardPaddingH

            spacing: Appearance.notif.cardSpacing

            IconImage {
                Layout.preferredWidth: Appearance.notif.cardIconSize
                Layout.preferredHeight: Appearance.notif.cardIconSize

                visible: root.group.image.length > 0
                source: root.group.image
            }

            StyledText {
                text: root.group.appName
                color: Colours.textBright
                font.weight: Appearance.font.weightActive
                elide: Text.ElideRight
            }

            StyledRect {
                Layout.preferredWidth: count.implicitWidth + Appearance.notif.badgePaddingH * 2
                Layout.preferredHeight: count.implicitHeight

                radius: Appearance.notif.badgeRounding
                color: Colours.trough

                StyledText {
                    id: count

                    anchors.centerIn: parent

                    text: root.group.entries.length
                    color: Colours.textMuted
                    font.pixelSize: Appearance.font.size.small
                }
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                text: Fmt.relativeTime(root.group.latest)
                color: Colours.textMuted
                font.pixelSize: Appearance.font.size.small
            }

            Icon {
                visible: clearPointer.containsMouse || headerHover.hovered

                text: Icons.close
                color: Colours.textMuted

                StateLayer {
                    id: clearPointer

                    radius: parent.height

                    onClicked: NotifHistory.clearApp(root.group.appName)
                }
            }

            Icon {
                text: root.expanded ? Icons.sectionExpanded : Icons.sectionCollapsed
                color: Colours.textMuted
            }
        }

        HoverHandler {
            id: headerHover
        }
    }

    Item {
        id: wrapper

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom

        clip: true
        height: root.expanded ? body.implicitHeight + Appearance.notif.cardSpacing : 0

        Behavior on height {
            Anim {
                type: AnimType.standardSmall
            }
        }

        ColumnLayout {
            id: body

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            visible: wrapper.height > 0
            spacing: Appearance.notif.rowSpacing

            Repeater {
                model: root.group.entries

                NotifRow {
                    required property var modelData

                    entry: modelData
                }
            }
        }
    }
}
```

`IconImage` comes from `Quickshell.Widgets` — add `import Quickshell.Widgets` if the type does not resolve.

- [ ] **Step 3: Create the list**

`modules/controlcenter/notifications/NotifList.qml`:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.services

Item {
    id: root

    RowLayout {
        id: header

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: Appearance.notif.headerHeight
        spacing: Appearance.notif.cardSpacing

        StyledText {
            text: Appearance.notif.labelNotifications
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
        }

        StyledText {
            text: NotifHistory.entries.length
            color: Colours.textMuted
            font.pixelSize: Appearance.font.size.small
        }

        Item {
            Layout.fillWidth: true
        }

        StyledText {
            visible: NotifHistory.entries.length > 0

            text: Appearance.notif.labelClearAll
            color: clearPointer.containsMouse ? Colours.textBright : Colours.textMuted
            font.pixelSize: Appearance.font.size.small

            StateLayer {
                id: clearPointer

                radius: parent.height

                onClicked: NotifHistory.clear()
            }
        }
    }

    EmptyState {
        anchors.centerIn: parent

        visible: NotifHistory.entries.length === 0
        glyph: Icons.notifNormal
        title: Appearance.notif.emptyTitle
        subtitle: Appearance.notif.emptySubtitle
    }

    Flickable {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: Appearance.notif.listSpacing

        visible: NotifHistory.entries.length > 0
        contentHeight: cards.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: cards

            width: parent.width

            spacing: Appearance.notif.listSpacing

            Repeater {
                model: NotifHistory.groups

                NotifCard {
                    required property var modelData

                    Layout.fillWidth: true

                    group: modelData
                }
            }
        }
    }
}
```

- [ ] **Step 4: Restore the `NotifList` block in the panel**

If Step 10 of Task 5 commented it out, uncomment it now.

- [ ] **Step 5: Verify**

```bash
qs -p . 2>&1 | tail -40
```

Expected: no errors.

With the shell running:

```bash
notify-send "First" "body text one"
notify-send "Second" "body text two"
notify-send -a "Other App" "Third" "from a different app"
qs ipc call controlcenter open audio
```

Check by eye:

1. Two cards — one grouped with a count of 2, one with a count of 1. Both start expanded.
2. Clicking a card header collapses it with an animated height, chevron flips.
3. Hovering a card header reveals an `×` that clears just that app.
4. Hovering a row reveals an `×` that drops just that row.
5. Relative times read `now`, then `1m` after a minute.
6. `notify-send -u critical "Urgent" "check the red edge"` shows a red left edge on that row.
7. Clearing everything shows the empty state.

- [ ] **Step 6: Verify the disk purge — the explicit requirement**

```bash
notify-send "Before clear" "should be on disk"
sleep 2
cat ~/.local/state/quickshell/notifications.json | python3 -m json.tool | head -20
```

Expected: the entry is present.

Now click **clear all** in the panel, then immediately:

```bash
cat ~/.local/state/quickshell/notifications.json
```

Expected, with **no waiting for a debounce**: `{"version":1,"entries":[]}`.

Then restart the shell and re-open the panel. Expected: still empty. If entries return, `clear()` is routing through `save()` instead of `flush()`.

- [ ] **Step 7: Verify the expiry sweep**

Stop the shell, then hand-doctor the file with one stale entry:

```bash
python3 - <<'PY'
import json, time, pathlib
p = pathlib.Path.home() / ".local/state/quickshell/notifications.json"
stale = int(time.time() * 1000) - 30 * 86400000
fresh = int(time.time() * 1000)
entry = lambda k, t: {"key": k, "appName": "Test", "desktopEntry": "", "summary": k,
                      "body": "", "image": "", "urgency": 1, "time": t, "read": True}
p.write_text(json.dumps({"version": 1, "entries": [entry("stale", stale), entry("fresh", fresh)]}))
PY
```

Start the shell, open the panel. Expected: only "fresh" is listed, and the file no longer contains "stale" after the next write.

---

### Task 7: Bar pills and keybinds

**Files:**
- Create: `modules/bar/components/NetworkPill.qml`
- Create: `modules/bar/components/NotifPill.qml`
- Modify: `modules/bar/BarSlot.qml`
- Modify: `core/config/Appearance.qml:191` (`entriesRight`)
- Modify: `modules/controlcenter/ControlCenter.qml`
- Modify: `~/.config/hypr/config/keymaps.lua`

**Interfaces:**
- Consumes: `BarEntry.network`, `.notifications` (Task 1); `Net.glyph` (Task 1); `NotifHistory.unread` (Task 3); `ControlState.togglePanel` (Task 5).
- Produces: nothing downstream.

- [ ] **Step 1: Create the network pill**

`modules/bar/components/NetworkPill.qml`, modelled on `BluetoothPill.qml`:

```qml
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.controlcenter
import qs.services

Pill {
    id: root

    Layout.rightMargin: Appearance.bar.pillMarginRight

    visible: Net.available
    interactive: true

    onClicked: ControlState.toggle(ControlSection.network)

    Icon {
        text: Net.glyph
    }
}
```

- [ ] **Step 2: Create the notifications pill**

`modules/bar/components/NotifPill.qml`:

```qml
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.controlcenter
import qs.services

Pill {
    id: root

    Layout.rightMargin: Appearance.bar.pillMarginRight

    interactive: true

    onClicked: ControlState.togglePanel()

    Icon {
        text: Icons.notifNormal
    }

    StyledText {
        visible: NotifHistory.unread > 0

        text: NotifHistory.unread
    }
}
```

- [ ] **Step 3: Register both delegates**

In `modules/bar/BarSlot.qml`, add two `DelegateChoice` blocks inside the existing `DelegateChooser`:

```qml
            DelegateChoice {
                roleValue: BarEntry.network

                delegate: NetworkPill {}
            }
            DelegateChoice {
                roleValue: BarEntry.notifications

                delegate: NotifPill {}
            }
```

- [ ] **Step 4: Place them on the bar**

In `core/config/Appearance.qml`, replace line 191:

```qml
        readonly property var entriesRight: [BarEntry.volume, BarEntry.network, BarEntry.mouseBattery, BarEntry.bluetooth, BarEntry.tray, BarEntry.notifications, BarEntry.cpu, BarEntry.memory]
```

Sound, network and bluetooth now read left to right in the same order as `ControlSection.values` from Task 1.

- [ ] **Step 5: Add the two new global shortcuts**

In `modules/controlcenter/ControlCenter.qml`, beside the existing two:

```qml
    GlobalShortcut {
        appid: Ids.appid
        name: "controlcenter-bluetooth"

        onPressed: ControlState.toggle(ControlSection.bluetooth)
    }

    GlobalShortcut {
        appid: Ids.appid
        name: "controlcenter-toggle"

        onPressed: ControlState.togglePanel()
    }
```

The `IpcHandler` block is unchanged.

- [ ] **Step 6: Bind them in Hyprland**

In `~/.config/hypr/config/keymaps.lua`, beside the existing bindings at lines 19 and 24:

```lua
hl.bind(mainMod .. " + B",        hl.dsp.global("quickshell:controlcenter-bluetooth"))
hl.bind(mainMod .. " + N",        hl.dsp.global("quickshell:controlcenter-toggle"))
```

Check first that `Super+B` and `Super+N` are free:

```bash
grep -n '" + B"\|" + N"' ~/.config/hypr/config/keymaps.lua
```

If either is taken, pick a free combination rather than clobbering an existing bind.

- [ ] **Step 7: Verify**

```bash
qs -p . 2>&1 | tail -40
```

Expected: no errors.

With the shell running, check by eye:

1. A network pill sits between the volume pill and the mouse-battery pill, showing wifi strength; its glyph changes when wifi is toggled off.
2. A bell pill sits after the tray. Sending a notification while the panel is closed increments its count; opening the panel clears the count.
3. Clicking sound / network / bluetooth pills each opens the panel on the matching tab.
4. Clicking the bell opens the panel on whatever tab was last used.
5. `Super+W`, `Super+V`, and the two new binds all work.

---

### Task 8: The load gate and full verification sweep

**Files:**
- Create: `probe.qml`

**Interfaces:**
- Consumes: every type created in Tasks 1-7.
- Produces: the reusable load gate.

- [ ] **Step 1: Write the non-instantiating probe**

`probe.qml` references every type without constructing the shell, so a missing import or a renamed property fails at load rather than at runtime. `qmllint` does not catch these; this does.

```qml
import Quickshell
import qs.core.components
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers
import qs.modules.bar.components
import qs.modules.controlcenter
import qs.modules.controlcenter.components
import qs.modules.controlcenter.notifications
import qs.modules.controlcenter.panes
import qs.modules.notifications.components
import qs.services

ShellRoot {
    readonly property var probes: [
        Appearance.tab.height,
        Appearance.control.topPaneMaxRatio,
        Appearance.notif.historyMaxEntries,
        Appearance.notif.historySaveDebounce,
        ControlSection.values,
        BarEntry.network,
        BarEntry.notifications,
        Units.minutesPerHour,
        Units.hoursPerDay,
        Fmt.relativeTime(Date.now()),
        Net.glyph,
        NotifHistory.unread,
        NotifHistory.groups,
        ControlState.opened
    ]

    readonly property Component components: Component {
        Item {
            TabStrip {
                tabs: []
            }
            EmptyState {
                glyph: ""
                title: ""
                subtitle: ""
            }
            NetworkPill {}
            NotifPill {}
            AudioPane {}
            NetworkPane {}
            BluetoothPane {}
            PaneHeader {}
            NotifList {}
        }
    }
}
```

`NotifCard` and `NotifRow` are omitted deliberately — both take a `required property`, so referencing them here would fail on the missing value rather than on a real defect. They are covered by the live checks in Task 6.

- [ ] **Step 2: Run the gate**

```bash
cd /home/sidouxp3/.config/quickshell
qs -p probe.qml 2>&1 | tail -40
```

Expected: clean, or the one known false positive documented from the previous refactor. Any `ReferenceError`, `Unable to assign`, or `is not a type` is a real defect — trace it to its task and fix there.

- [ ] **Step 3: Run the full manual matrix**

Every item is stateful, so each is checked explicitly rather than assumed from the ones above it.

1. Each of the three pills opens the panel on its own tab. `Super+W`, `Super+V`, and both new shortcuts do the same.
2. `←` and `→` wrap through all three tabs. Pane height animates and caps on a long wifi list; the notification list keeps the remainder.
3. Notification arriving with the panel **closed** → toast *and* list entry. Arriving with it **open** → list entry only, no toast.
4. **`clear all` → `cat` the JSON and confirm `entries` is empty immediately**, then restart and confirm nothing returns.
5. The doctored stale/over-cap file loses both on load.
6. `Net.scanning` is false with the panel closed and on other tabs; true only on the visible network pane.
7. Action buttons render on a live entry; after it expires the row keeps its text and loses its buttons.
8. Regression: dashboard tabs still work after the `TabStrip` move; the media pane's empty state still works after the `EmptyState` move.
9. Regression: launcher, OSD, lock screen and polkit surfaces all still open — they share `BorderWindow`'s focus grab.

- [ ] **Step 4: Check the log is clean**

```bash
qs log | grep -iE "error|warning|unable|undefined" | tail -30
```

Expected: nothing new attributable to this work. `Configuration Loaded` alone is the clean result.

---

## Self-review notes

**Spec coverage:** every section of the spec maps to a task — file layout (all tasks), the two generalisations (Task 2), `Section.qml` splitting in two (Task 5 Steps 2 and 9, Task 6 Step 2), data model and persistence (Task 3), panel geometry and keyboard (Task 5), notification list (Task 6), toast suppression (Task 4), bar (Task 7), verification (Task 8).

**Two refinements the plan makes to the spec**, both for layering and both amended back into the spec:
- `Glyphs.network()` became `Net.glyph` — `core/helpers/` must not import `qs.services`.
- `panes/Pane.qml` was added — horizontal tab slide and vertical scroll cannot share one Flickable.

**Known risks flagged inline rather than hidden:**
- Fillet geometry (Task 5 Step 10) — verify on screen, not on paper.
- `NotifAction.popup` may need relaxing from `required` (Task 6 Step 1).
- The `id: network` reference from outside a `DelegateChoice` (Task 5 Step 7) has a documented fallback.
- `Icons.close` may not exist (Task 6 Step 1) — a value is supplied if it does not.

---

## As-built notes (2026-09-04)

All eight tasks executed inline in one pass. Every deviation from the plan, and why.

### Flagged risks, resolved

- **`Icons.close` did not exist.** Added as `"󰅖"` in Task 1 rather than
  Task 6, so both the card header and the row could use it.
- **`NotifAction.popup` needed relaxing**, as predicted. Resolved better than the
  plan proposed: instead of overriding `onClicked` at the call site — where QML
  handler precedence between a base component and its usage is murky — `popup`
  was relaxed to non-required and the handler null-guarded once inside the
  component: `root.popup ? root.popup.invoke(root.action) : root.action.invoke()`.
  One behaviour definition, no call-site override.
- **The `id: network` reference from outside a `DelegateChoice`** was not
  attempted; the documented `repeater.itemAt()` fallback was used directly as
  `ControlPanel.dismissPrompt()`.
- **Fillet geometry** renders without artefacts. Both left corners read as flush
  against the border on a dark palette; worth a second look under a light theme.

### Unplanned changes, and their justification

- **`NotifHistory.loaded` guard.** Probing revealed Quickshell constructs
  singletons lazily. Today the bar's `NotifPill` instantiates the store at
  startup so the file always loads before any notification — but that is luck,
  not design. If construction were ever first triggered by an arriving
  notification, `remember()` would prepend to an empty list and the 1s debounce
  could flush before `FileView` delivered the file, erasing all history. `flush()`
  now refuses to write until `loaded`, `adopt()` concatenates rather than
  replaces, and `clear()` sets `loaded` itself. Amended into the spec.
- **`StreamEntry.qml:25` and `AudioDevice.qml:23` null guards.** Both read
  `root.node.audio?.muted` — guarding `audio` but not `node`. Latent
  pre-existing bug, surfaced because `AudioPane` instantiates its repeaters
  eagerly where the old collapsed accordion did not. Produced a live
  `TypeError: Cannot read property 'audio' of null`. Changed to `root.node?.audio?.muted`.
- **Keybinds differ from the plan.** `Super+B` is already the browser
  (`keymaps.lua:33`), so the plan's suggestion was unusable. Bound
  `Super+N` → `controlcenter-toggle` and `ALT+B` → `controlcenter-bluetooth`,
  both verified free, the latter matching the existing `ALT+W` quickshell-global
  convention.
- **`probe.qml` includes `ControlPanel`**, which the plan omitted — it has no
  required properties, so it belongs in the gate. `NotifCard` and `NotifRow`
  remain excluded as planned.

### Verification actually performed

| Check | Result |
|---|---|
| `qs -p probe.qml` load gate | `Configuration Loaded`, clean |
| Restore on start | 3 seeded entries restored, 2 groups |
| Expiry sweep | 30-day entry dropped on load, 1-hour kept |
| **`clear()` purges disk** | file became `{"version":1,"entries":[]}` immediately, no debounce wait |
| Persistence across restart | 6 entries survived `qs kill` + relaunch |
| `markAllRead` on open | unread 3 → 0, persisted |
| Toast with panel **closed** | toast shown, bell badge → 1 |
| Toast with panel **open** | no toast, entry still filed |
| Tab switching | audio / network / bluetooth via IPC and tab strip |
| Bar order | volume → network → mouse → bluetooth → tray → bell → cpu → memory |
| Critical urgency | red left edge renders on the row |
| Grouping | `notify-send (5)` and `Thunderbird (1)` as separate cards |
| Pane cap | audio pane stops at ~50% of panel height, list takes remainder |
| Dashboard regression | all three tabs work after the `TabStrip` move |
| Log sweep after exercising every surface | empty |

### Not verified

- **The `EmptyState` empty-list rendering** was never seen on screen — a media
  player was running throughout, and the notification list was never emptied
  while visible. Its property assignments are compile-checked by the probe (QML
  validates property names inside a `Component` at load), so a typo would have
  failed the gate, but the visual has not been eyeballed.
- **Hover-only affordances** — the per-app `×` and per-row `×` — require a real
  pointer and were not exercised. Their handlers are wired to
  `NotifHistory.clearApp()` and `.dismiss()`, both of which were verified
  directly against the store.
- **Action buttons on a live entry** were not seen; `notify-send` sends no
  actions. The live/stored distinction is enforced by `entry.live`.

### Follow-up: unread badge fixed

The wart left in the first pass — a notification arriving **while the panel is
open** still counting as unread — was fixed on request the same day.

`NotifHistory` gained `property bool viewing`, and `remember()` now sets
`read: root.viewing` instead of `read: false`. The flag is *driven by the panel*,
not computed by the store: a service must not import a module, so `ControlPanel`
carries `Binding { target: NotifHistory; property: "viewing"; value: ControlState.opened }`
alongside its existing `Net.scanning` binding. `ControlPanel` exists once per
screen and every instance writes the binding, which is harmless because the
expression is screen-independent and all instances agree.

Verified: panel closed + arrival → unread 1; panel open + arrival → entry
persisted with `read: true`, unread stays 0, bell shows no badge; closed again +
arrival → unread 1. Probe clean, log clean. Spec amended to match.

---

## Follow-up: empty state and hover affordances tested (2026-09-05)

The two items listed above as "not verified" were tested on request. **Both found
bugs.**

### Empty state — passes

Stopped the shell, wrote `{"version":1,"entries":[]}`, restarted, opened the
panel. Renders the accent bell glyph, "All caught up", "Nothing waiting for you",
centred in the notification region, with the header reading `Notifications 0` and
**"Clear all" correctly hidden** when the list is empty. No changes needed.

### Hover affordances — two bugs found and fixed

Driving a synthetic pointer needed `hyprctl dispatch 'hl.dsp.cursor.move({ x = N, y = N })'`
— this Hyprland runs a Lua config layer, so bare `dispatch movecursor X Y` is
parsed as Lua and fails. No click synthesiser exists on this machine
(`ydotool`/`wtype`/`dotool` all absent), so **clicks were never synthesised**; only
hover was driven.

**Bug 1 — the per-row dismiss `×` was unreachable.** `NotifRow`'s `StateLayer`
carried `disabled: !root.entry.defaultAction`. `StateLayer` maps that to
`enabled: !disabled` on its `MouseArea`, and a disabled `MouseArea` receives no
hover events at all — so `pointer.containsMouse` could never become true, the row
never highlighted, and the `×` never appeared. Because most notifications carry no
default action, **per-row dismissal was unreachable in practice**. Fixed by
decoupling hover from clickability: the `StateLayer` is no longer disabled, and
honesty about clickability moved to the cursor instead —
`cursorShape: root.entry.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor`.
The row's own `color:` binding was dropped so the `StateLayer` provides the single
hover highlight rather than two stacked ones.

**Bug 2 — `qt.svg.draw: The requested buffer size is too big, ignoring`.** The card
header's `IconImage` sat directly in a `RowLayout` with only
`Layout.preferredWidth/Height`, so it could assume the SVG's own implicit size
before layout ran. `NotifIcon.qml:21` already solves this by wrapping `IconImage`
in a fixed-size `Item` with `anchors.fill`. Adopted that shape, which also made
room for a bell-glyph fallback so apps with no resolvable icon no longer render a
blank gap.

### Method note, for whoever repeats this

Synthetic cursor warps are **unreliable** for hover testing here: they
intermittently fail to generate the pointer enter/motion a Wayland client needs,
so a screenshot can show the cursor sitting on a control that never received
hover. Two false conclusions were nearly drawn from this before a control
experiment on a known-good component exposed it. The reliable protocol is:
park the pointer, record the log line count, warp, then confirm a **new**
`containsMouse` event appeared before trusting the screenshot. Warping to the
other monitor also closes the panel, since `revealed` depends on
`Monitors.focused`.

Both affordances were confirmed on screen under that protocol: the per-app `×`
appears with the header hover-highlighted, and after the Bug 1 fix the per-row `×`
appears with the row highlighted and a correctly plain arrow cursor.

### Still not verified

**The clicks themselves.** No click synthesiser is available, so neither `×` has
been observed actually firing. Their handlers call `NotifHistory.clearApp()` and
`NotifHistory.dismiss()`, both of which were exercised directly against the store
and confirmed to purge disk. Worth one manual click each to close the loop.

### Follow-up: hover oscillation on the clear buttons (2026-09-05)

Reported after manual clicking confirmed both `×` buttons fire correctly: moving
onto either `×` made it flicker on and off, with the timestamp shifting back and
forth alongside it.

**Cause.** Each `×` carried its own nested `StateLayer`. Moving onto it made that
child `MouseArea` take the hover, so the parent's `containsMouse` went false — and
the parent's `containsMouse` was exactly what drove `visible`. The `×` hid, the
child stopped being hovered, the parent regained hover, the `×` reappeared, and
the cycle repeated. Because `visible: false` removes an item from a `RowLayout`,
every cycle also reflowed the row, which is why the timestamp moved with it.

**Fix, in both `NotifCard` and `NotifRow`:**

1. The `×` moved into a fixed-size `Item` of `Appearance.notif.clearIconSize`, so
   its slot is reserved whether or not it is showing and the layout never reflows.
2. `visible` became `opacity`, driven by *either* pointer:
   `opacity: headerPointer.containsMouse || clearPointer.containsMouse ? 1 : 0`
   (and the `pointer` / `dismissPointer` pair in the row). Hovering the `×` itself
   now keeps it lit instead of hiding it, which breaks the cycle.
3. An `Anim { type: AnimType.defaultEffects }` `Behavior` on `opacity` so it fades
   rather than snaps. This required adding `import qs.core.enums` to `NotifRow`,
   which had not needed `AnimType` before.

Verified against a real pointer (synthetic warps remained unreliable): the row
highlights with its `×` lit and stable, while the card header above shows its
reserved slot sitting empty — no shift between the two states. Probe clean.

### Follow-up: two more bugs found by real use (2026-09-05)

**Bug 3 — `TypeError: Cannot read property 'X' of null` in `NotifRow`.** Surfaced
by actually clicking the `×` buttons. `NotifHistory.drop()` called
`entry.destroy()` *before* reassigning `root.entries`, so for one frame the
`Repeater` delegates still bound to a destroyed object and every property read in
`NotifRow` threw. Fixed by inverting the order and deferring destruction:
`drop()` now assigns `root.entries = kept`, flushes, then hands the removed
entries to a new `reap()` which destroys them inside `Qt.callLater`, after the
views have released them. `sweep()` was given the same treatment. Verified:
`dismiss()` and `clearApp()` both run with a clean log.

**Bug 4 — the launcher stayed focused while invisible.** Reported as "the
launcher is invisible, not closed — I can open apps without it being visible".
`LauncherPanel.qml:38` focuses its input when revealed but never releases focus
when un-revealed, and unlike `DashboardPanel.qml:32` and `ControlPanel.qml:49` it
carried **no `visible:` binding** — so at `opacity: 0` it remained in the focus
chain holding active focus. The `BorderWindow` only takes keyboard focus while
`BorderState.panelOpen` is true, so keystrokes then reached the hidden launcher
and Enter launched whatever it had matched.

This is a pre-existing latent bug, not one this work introduced — but this work is
what made it reachable. `BorderState.panelOpen` includes `ControlState.opened`,
and the control centre changed from a small dropdown you dismissed immediately
into a full-height sidebar you leave open, so the window now holds keyboard focus
most of the time.

Fixed by giving `LauncherPanel` the same binding its two sibling panels already
had: `visible: root.revealed || root.opacity > 0`. An invisible item cannot hold
active focus, so this closes the input path structurally rather than by adding a
focus-release call that a future edit could drop. All three panels are now
consistent.

---

## Follow-up: toast and pane restyle (2026-09-05)

Requested: toasts should blend into the chrome at the top right, cap at three, and
be visually separated; then the same treatment for the sidebar's pane sections.

`Appearance.notif.maxVisible` was **already 3**, so that half needed no work.

**Toast stack.** `Notifications.qml` became a single `StyledRect` painted
`Colours.bar`, holding the toasts in a `ColumnLayout`. Each `Toast` is a
`Colours.pill` card — the same dimmed black as the bar pills — spaced by
`Appearance.notif.stackSpacing`, so the container's black shows between cards and
does the separating on its own.

The stack attaches directly to the bar. `FocusedPanel` uses
`ExclusionMode.Normal`, so it is already positioned below the bar's exclusion zone
and inside the right border — the old `marginTop`/`marginSide` were being added on
top of that and had to be **removed**, not adjusted, to sit flush. Both tokens are
gone, along with `gap`.

Curvature matches the sidebar: `bottomLeftRadius` plus two concave `Fillet`s, one
joining the bar to the stack's left edge and one carrying the stack's bottom into
the right border. The panel window is grown by `Appearance.border.fillet` in both
axes, since the fillets draw outside the stack's own bounds and would otherwise
fall outside the window.

`Toast` also gained a height collapse — `implicitHeight` goes to 0 when not
entered or when closing, with a `standardSmall` `Behavior`. Without it an exiting
toast held its full height and left a hole in the middle of a merged stack.

**Pane sections.** `ListRow` — the shared base of `AudioDevice`, `StreamEntry`,
`NetworkEntry` and `BluetoothEntry` — changed its resting colour from
`"transparent"` to `Colours.pill`, so every row in every pane is now a card on the
panel's black, spaced by the existing `Appearance.control.paneSpacing`. One
edit covers all four row types.

### A discarded approach, recorded so it is not retried

The first attempt drew a literal 1px `Colours.accent` rule between rows: a
`separated` flag on `ListRow`, a `PaneGroup` wrapper painting one merged
pill-coloured block, and an equivalent separator inside `Toast`. It worked, but
the maintainer's call was that spacing plus the card colour reads cleaner than an
explicit line. All of it was reverted — `PaneGroup.qml` deleted, the `separated`
property removed, `Appearance.control.separatorHeight`/`groupRounding` removed.
(`Appearance.dash.separatorHeight` at line 333 is pre-existing and unrelated —
do not remove it.)

Watch for one hazard from that revert: a naive `rowRounding: 10` string edit hits
**both** `NotifConfig` and `ControlConfig`, which is what produced a
`Duplicate property name` failure mid-way. Anchor edits to more of the surrounding
block.

### Follow-up: one visual language everywhere (2026-09-05)

Extended the toast/pane restyle to the notification list and the dashboard's
performance and media panes, on the instruction to keep it consistent.

**The rule, now applied uniformly:** a black `Colours.bar` surface holds
`Colours.pill` cards separated by spacing. No borders, no rules, no dividers.

- **Notification list.** `NotifCard` went transparent so the group is just a
  header plus its rows, and `NotifRow` took `Colours.pill`. The notification —
  not the app group — is now the card, which matches the panes, where the row is
  the card.
- **`PerfPane`.** Gauges and `NetworkCard` each moved into a `Card`. This also
  removed the pane's **1px `Colours.accent` rule** (`separatorHeight` /
  `separatorMargin`) — the same device dropped from the toasts, so removing it
  here was the consistent call rather than a separate decision.
- **`MediaPane`.** The player row moved onto a `Card`; the empty state stays bare
  on the black.
- `Appearance.dash.separatorHeight` and `separatorMargin` had no remaining users
  and were deleted. (An earlier note in this document called `dash.separatorHeight`
  "pre-existing, do not remove" — that was true only while `PerfPane` still drew
  the rule. It is now genuinely dead.)

**One trap worth recording.** `Card` is a `StyledRect`, which takes **no implicit
size from its children**. Wrapping `PerfPane`'s gauge row in one collapsed the
whole pane to a thin vertical strip, because `DashboardPanel` sizes the viewport
from `pane.implicitWidth` and the `ColumnLayout` had nothing left to measure. Any
`Card` used as a layout wrapper needs an explicit
`implicitWidth`/`implicitHeight` derived from its content, as both cards in
`PerfPane` now have.

---

## Follow-up: OSD moved, blended and merged (2026-09-05)

The OSD already covered all three kinds (`OsdKind`: volume, microphone,
brightness); the work was placement, form and grouping.

**Placement and form.** Moved from bottom-centre to the right edge, vertically
centred, and blended into the chrome like the sidebar and toasts: a `Colours.bar`
container flush inside the right border with `topLeftRadius`/`bottomLeftRadius`
and two concave `Fillet`s joining it to the border above and below. The panel
switched from `ExclusionMode.Ignore` to `Normal` with `exclusiveZone: 0` so it
lands inside the border automatically, and its height is grown by
`Appearance.border.fillet * 2` to leave room for the fillets. The card's border
was dropped — nothing else in this design language has one.

**All three at once.** Any trigger now shows every meter, with the one that fired
at full opacity and the others at `inactiveOpacity`. The brightness row is
`visible: Brightness.available`, so it simply does not appear on a machine with no
backlight. Each meter is a `Colours.pill` card in a `RowLayout` — vertical bars
side by side, value on top, bar filling upward, glyph at the base — extracted into
`modules/osd/components/OsdMeter.qml`.

`Meter` gained an opt-in `vertical` property for this. `MediaCard`'s horizontal
use is unaffected because the property defaults to false.

Layout was settled by iteration, and the end state is: **vertical bars, stacked
one above the other**, in a single blended card. Two intermediate forms were
rejected on sight — vertical bars side by side, and horizontal rows stacked. Do
not reintroduce either.

Final geometry (`OsdConfig`): `columnWidth: 38`, `columnHeight: 250`,
`meterThickness: 16`, `meterRounding: 8`, `padding: 8`, `cardRounding: 12`,
`inactiveOpacity: 0.45`. Three stacked columns come to ~782px, which fits a 1080p
screen with margin; two (no backlight) come to ~524px. If `columnHeight` is
raised much further, check it still fits before the fillets are added, since the
window is `columnHeight * n + fillet * 2`.

One sizing trap: the meter's height is what is left after the value label, glyph,
two `spacing` gaps and two `paddingV`. Dropping `columnHeight` to 150 during the
stacking experiment left only ~48px of bar, which rendered as a blob rather than a
bar. Keep `columnHeight` generous whenever the bar is vertical.

**Mic volume is now a trigger.** `services/Osd.qml` fired only on
`onMutedChanged` for the source, so changing mic volume showed nothing at all.
Added `onVolumeChanged`. Watch for noise: some applications auto-adjust source
gain, which would pop the OSD unprompted — if that happens, this is the line to
remove.

### Bug worth remembering

Emphasis silently did nothing at first because the opacity `Behavior` used
`CAnim`, which is a **`ColorAnimation`** (`core/components/CAnim.qml`). Animating
a real-valued property with it fails quietly — no warning in the log, the value
just never moves. Use `Anim { type: ... }` for anything that is not a colour.

### Untestable here

`/sys/class/backlight/` is empty on this desktop, so the brightness row cannot be
exercised. Its code path is unchanged from the working original and it is gated on
`Brightness.available`; verify it on the laptop.

### OSD docks to the sidebar (2026-09-05)

When the control sidebar is open the OSD shifts left to sit flush against it
instead of hiding behind it:

```qml
margins.right: ControlState.opened ? Appearance.control.width : 0
```

This works because the OSD panel uses `ExclusionMode.Normal`, so margin 0 already
means "flush inside the right border" — the offset is exactly the sidebar's own
width, with nothing else to compensate for. The rounding and fillets need no
change: the sidebar's left edge is also `Colours.bar`, so the same concave joins
read correctly against either surface.

`ControlState.opened` is global while the sidebar renders only on the focused
monitor, but the OSD is a `FocusedPanel` and shows only on that same monitor, so
no per-screen check is needed. `modules/osd/` now imports `qs.modules.controlcenter`,
the same module-to-module direction the bar pills already use.

---

## Follow-up: bar right-side order and tray legibility (2026-09-05)

### `entriesRight` reordered

From `[volume, network, mouseBattery, bluetooth, tray, notifications, cpu, memory]`
to `[tray, cpu, memory, mouseBattery, network, bluetooth, notifications, volume]`.

Three reasons, in order of how much they matter day to day:

1. **`tray` is the only variable-width entry.** The slot is a right-anchored
   `RowLayout`, so growth pushes leftward: everything *left* of the tray moves when
   an app adds or removes an icon, everything *right* of it is stable. Tray was
   5th of 8, so four pills drifted. Moving it to the far left makes the other
   seven positionally fixed.
2. **`cpu` and `memory` are the only two entries with neither `interactive` nor
   `onClicked`** — pure readouts, and they were occupying the screen corner, the
   most accessible pointer target there is. They moved inboard next to the clock.
3. **`volume` is the only `scrollable` entry** and is the most frequently
   adjusted, so it took the corner: you can throw the pointer into the corner and
   scroll without aiming. `mouseBattery` also no longer splits the two radio pills.

### Tray became legible and gave feedback

The tray was already wired for clicks (`activate`, `secondaryActivate`, menu on
right-click) but had no hover state and no labels, so it read as inert and its
icons were unidentifiable.

- `core/components/Tooltip.qml` (new): a `Colours.pill` card with a fade, matching
  the card language used everywhere else.
- `modules/bar/components/TrayItem.qml` (new): one tray entry — a `trayHitSize`
  hit target with a `Colours.hover` background, the icon centred inside it, the
  click handlers moved over from `Tray.qml`, and a `Tooltip` anchored below the
  bar. `Tray.qml` is now just the `Pill` plus a `Repeater`.
- Label resolves `tooltipTitle || title || id || trayUnknownLabel`. The fallback
  chain matters: over D-Bus, Antigravity reports an **empty `Title`** and the id
  `Antigravity_status_icon_1`. Quickshell's `tooltipTitle` happens to give a clean
  "Antigravity", but the chain is what stops an app with no title rendering a
  nameless tooltip.

**Diagnosing tray contents from outside the shell:** a second Quickshell instance
sees an empty tray, because only one process can own the StatusNotifierHost bus
name. Query D-Bus directly instead:

```
busctl --user call org.kde.StatusNotifierWatcher /StatusNotifierWatcher \
  org.freedesktop.DBus.Properties Get ss \
  org.kde.StatusNotifierWatcher RegisteredStatusNotifierItems
busctl --user introspect <service> <path>   # then read .Id / .Title / .Status
```

Two QML traps hit while writing this, both invisible to the probe because it does
not instantiate delegates: a `Repeater` delegate must **not** redeclare and assign
`modelData` when the delegate type already declares it `required` (the Repeater
injects it), and `Repeater` itself needs `import QtQuick` — dropping that import
took the whole shell down with "Repeater is not a type".

### Tray menus were blocked by a missing pragma (2026-09-05)

Right-clicking a tray icon did nothing. The handler was correct all along; the
failure was in `shell.qml`:

```
ERROR: Cannot display PlatformMenuEntry as quickshell was not started in QApplication mode.
ERROR: To use platform menus, add `//@ pragma UseQApplication` to the top of your root QML file and restart quickshell.
```

`//@ pragma UseQApplication` added to `shell.qml`. **A pragma is not picked up by
a config reload** — it needs a full `qs kill` and relaunch, which is why this can
look like it "still doesn't work" after an ordinary reload.

Pre-existing, not introduced by the tray rework: `display()` has been failing this
way for as long as the pragma has been absent.

**How it was diagnosed**, since a click cannot be synthesised on this machine: a
temporary `IpcHandler` was added that listed `SystemTray.items` (confirming all
three report `hasMenu=true` with valid `QsMenuHandle`s) and called `display()` on
demand. The error surfaced immediately in `qs log`. The handler was removed
afterwards. Note that two `BarContent` instances exist (one per screen), so a
debug `IpcHandler` placed there logs a duplicate-target warning — harmless, but
put diagnostic IPC in a `Scope` that is instantiated once if it matters.

`display()` driven over IPC still shows no menu, because a native popup opened
without a pointer grab is dismissed immediately. Menus can only be verified by an
actual right-click.

`TrayItem` bindings were also null-guarded (`root.modelData?.…`). The delegate can
outlive its model entry when an app removes its tray icon, which threw
`TypeError: Cannot read property 'icon' of null` — the same class of bug as the
earlier `NotifRow` one.

A smoke test after enabling QApplication mode (sidebar tabs, dashboard tabs,
toast, OSD) shows no regressions and a clean log.

### Performance card titles (2026-09-05)

Both `PerfPane` cards gained a heading via the existing
`modules/dashboard/components/CardLabel.qml` (icon + muted label), matching how
`WorldClockCard` already titles itself — no new component:

- top card: `Icons.perfTab` + `labelHardware` ("Hardware")
- bottom card: `Net.glyph` + the existing `labelNetwork` ("Network"), so the icon
  tracks the live connection state

Each card's content moved into a `ColumnLayout` with the label first, and the
card's `implicitWidth`/`implicitHeight` now derive from that layout — `Card` is a
`StyledRect` and takes no implicit size from its children (see the earlier trap
note).

`DashConfig` already had a `labelNetwork`; adding a second one produced
`Duplicate property name` at load. Only `labelHardware` was needed. This is the
second time a blind label/token insert has collided inside `Appearance.qml` —
grep the target component block before adding a token.

### Gauge and pill spacing tightened (2026-09-05)

**Dashboard performance gauges.** `Appearance.dash.gaugeSpacing` was already only
4px, so it was not what created the gap — `Gauge.implicitWidth` is
`size + allowance * 2` where `allowance = size * Appearance.gauge.allowanceRatio`.
At 0.21 that is 27px per side gauge and 34px for the main one, so neighbouring
gauges sat ~61px apart from allowance alone. Reduced `allowanceRatio` to 0.13 and
`gaugeSpacing` to 0.

The allowance is **not** dead padding: the secondary readout ("47% / Usage") is
positioned outside the ring at an angle and lives in it. 0.13 still clears that
text on all three gauges — verified on screen — but it cannot go to zero without
clipping. If the gauges ever grow a longer secondary string, this is the value to
revisit.

**Bar cpu/memory pills.** The gap between the percentage and the ring is
`Appearance.bar.ringMarginLeft` *plus* the `Pill`'s own RowLayout spacing
(`Appearance.spacing.small`, 7). Cutting `ringMarginLeft` from 7 to 2 takes the
gap from 14px to 9px. Dropping it to 0 would floor it at 7px; below that requires
overriding the pill's `spacing`, which would also close up the glyph-to-text gap.

## Follow-up: notifications on the Dash tab (2026-09-05)

Deferred item 1 shipped. The media column of `DashPane` became a `ColumnLayout`
holding `MediaCard` (implicit height) above a new `NotificationsCard`
(`Layout.fillHeight`), so the column absorbs the slack instead of the media card
stretching.

- `modules/dashboard/dash/NotificationsCard.qml` — a `Card` with a `CardLabel`
  (`Icons.notifNormal` + `labelNotifications`), the newest
  `Appearance.dash.notifCount` (3) entries, and a muted `labelNoNotifications`
  line when the store is empty.
- `modules/dashboard/dash/NotificationPreview.qml` — one entry as a single row:
  summary on the left, `Fmt.relativeTime` on the right. Critical entries take
  `Colours.urgencyCritical` on the summary rather than the sidebar's left edge —
  a 2px edge needs a background rect, and the dash idiom here (as in
  `WorldClockCard`) is plain text rows inside one pill card, no nested surfaces.

**`entries.slice(0, 3)` does not work.** `NotifHistory.entries` is a
`list<NotifEntry>`, which is not a JS array — that is exactly why the service
already carries `toArray()`. The card binds `NotifHistory.toArray().slice(0, n)`,
which stays reactive because the dependency is registered through the call, the
same way `NotifHistory.groups` already does.

**Trap: `elide` does not collapse embedded newlines.** The first version showed
the body under the summary with `elide: Text.ElideRight` and no `wrapMode`, which
looks single-line — but notification bodies routinely carry `\n`, and elide only
truncates the *last* line. Three trading-signal notifications rendered ~40 lines
and stretched the panel to the full screen height. Two things came out of it:

- `Str.oneLine()` was added to `core/helpers/Str.qml` (collapse whitespace runs,
  trim) and is applied to the summary, which can carry newlines too.
- The body was dropped entirely — on review the card reads better collapsed to
  titles only, which is what shipped.

Verified: probe clean, live shell reloaded and captured with `grim` — three
title-only rows, panel back to its previous height, no new log entries (the
`image://qsimage` warnings in `qs log` come from `IconImage` in the sidebar's
`NotifCard` and predate this change).

## Follow-up: notification urgency, restrained (2026-09-05)

The second deferred item is closed, by deciding it needs less design rather than
more.

**The finding that settled it.** There is no info/warning/error taxonomy on the
wire. freedesktop gives `urgency` (3 values, always present) and `category` — a
*hint*, optional, 6 roots / 20 values, which almost no application sets.
Quickshell exposes `Notification.hints`, but `NotificationServer.extraHints` is
unset in `services/Notifs.qml`, so `category` is not even captured today. Rather
than build 20 variants for data that may never arrive, the chosen direction was
the opposite: **colour is reserved for critical, everything else is monochrome.**

- `Colours.criticalSurface` — `blend(pill, critical, criticalTint)` (0.16), with a
  new `blend()` beside `shade()`. Both the ratio and the role live in
  `Colours.qml`: `Appearance` does not reference `Colours` anywhere, and adding a
  `config → config` edge for one number was not worth it.
- `Toast` — the tinted edge pill is gone entirely; the card takes
  `criticalSurface` and the summary + fallback glyph go red, only when critical.
  Non-critical toasts are now fully neutral (`Colours.textMuted` glyph).
- `NotifRow` — the 2px critical edge is replaced by the same wash plus a red
  summary, so the sidebar and the toasts read identically.
- `NotificationPreview` — already coloured its summary by urgency; unchanged.

Swept as dead in the same pass: `Colours.urgencyLow`, `Colours.urgencyNormal`,
`Icons.notifLow`, `Appearance.notif.edgeWidth`. `Notif.low` stays — it still
selects `timeoutLow`.

If `category` is ever wanted, the capture is one line (`extraHints: ["category"]`)
plus a field on `NotifEntry`, and it should run for a week before any UI is drawn
against it.

### Escape now closes every panel (2026-09-05)

Escape was handled in three places — `ControlPanel`, `DashboardPanel`, and the
launcher's `TextField.onCancelled` — and each only fired while *that* panel held
active focus. Only one item can hold focus in the border window, so with two
panels open Escape closed the wrong one or nothing at all.

It now has one home: `Keys.onEscapePressed: BorderState.closeAll()` on
`BorderWindow`'s `inner` Item, the shared parent of all three panels. Unhandled
keys bubble up the focus chain, so it fires whichever panel is focused. The two
per-panel handlers were deleted.

The launcher needed a different route: its `TextField` *accepts* Escape
(`core/components/TextField.qml:76`) and so never propagates. Its `cancelled`
signal could not simply call `BorderState.closeAll()` either — `qs.modules.border`
already imports `qs.modules.launcher`, and importing back would make the cycle.
`LauncherPanel` therefore exposes a `dismissed` signal that `BorderWindow` wires
to `closeAll()`, keeping the dependency one-way. `TextField.cancelled` is left
alone: lock, polkit and the network prompt all use it with their own meaning.

A hover-opened (unpinned) dashboard is deliberately unaffected — the window only
takes keyboard focus while `BorderState.panelOpen`, which requires `DashState.pinned`.
