pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.core.helpers
import qs.modules.barlayout
import qs.services

RevealCard {
    id: root

    readonly property var config: Appearance.barLayout
    readonly property var zoneBoxes: [leftZone, centreZone, rightZone]

    property string dragging: ""
    property bool lifted: false
    property point grab: Qt.point(0, 0)
    property point origin: Qt.point(0, 0)
    property Item target: null
    property string before: ""

    function begin(chip: Item, x: real, y: real): void {
        root.dragging = chip.entry;
        root.lifted = false;
        root.grab = Qt.point(x, y);
        root.origin = chip.mapToItem(root, x, y);
    }

    function track(chip: Item, x: real, y: real): void {
        if (root.dragging === "")
            return;
        const point = chip.mapToItem(root, x, y);
        if (!root.lifted && Math.hypot(point.x - root.origin.x, point.y - root.origin.y) < root.config.dragThreshold)
            return;
        root.lifted = true;
        ghost.x = point.x - root.grab.x;
        ghost.y = point.y - root.grab.y;
        root.locate(point);
    }

    function locate(point: point): void {
        const boxes = root.zoneBoxes.concat([tray]);
        root.target = boxes.find(box => {
            const local = box.mapFromItem(root, point.x, point.y);
            return box.contains(local);
        }) ?? null;
        if (root.target === tray && BarLayoutState.locked(root.dragging))
            root.target = null;
        if (root.target === null || root.target === tray) {
            root.before = "";
            return;
        }
        const before = root.target.beforeAt(root.target.mapFromItem(root, point.x, point.y));
        const last = root.target.entries[root.target.entries.length - 1];
        root.before = before === "" && last === BarEntry.media && root.dragging !== BarEntry.media ? BarEntry.media : before;
    }

    function finish(): void {
        if (root.lifted && root.target === tray)
            BarLayoutState.stash(root.dragging);
        else if (root.lifted && root.target !== null)
            BarLayoutState.place(root.dragging, root.target.zone, root.before);
        root.dragging = "";
        root.lifted = false;
        root.target = null;
        root.before = "";
    }

    outlineColour: Colours.tabBar
    implicitWidth: Math.min(root.config.maxWidth, (parent?.width ?? root.config.maxWidth) - root.config.sideMargin * 2)
    implicitHeight: layout.implicitHeight + root.config.padding * 2

    color: Colours.bar
    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: Appearance.border.rounding
    bottomRightRadius: Appearance.border.rounding
    scaleFrom: root.config.scaleFrom
    transformOrigin: Item.Top

    visible: root.revealed || root.opacity > 0
    focus: root.revealed

    onRevealedChanged: {
        if (root.revealed)
            root.forceActiveFocus();
    }

    Keys.onPressed: event => {
        const shift = event.modifiers & Qt.ShiftModifier;
        const delta = Nav.horizontal(event);

        if (event.key === Qt.Key_Escape)
            BarLayoutState.hide();
        else if (delta !== 0 && shift)
            BarLayoutState.shift(delta);
        else if (delta !== 0)
            BarLayoutState.step(delta);
        else if (event.key === Qt.Key_Space)
            BarLayoutState.toggleHidden(BarLayoutState.selected);
        else if (event.key === Qt.Key_Delete)
            BarLayoutState.toggleOff(BarLayoutState.selected);
        else
            return;

        event.accepted = true;
    }

    Fillet {
        anchors.right: parent.left
        anchors.top: parent.top

        origin: Corner.bottomLeft
    }

    Fillet {
        anchors.left: parent.right
        anchors.top: parent.top

        origin: Corner.bottomRight
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: root.config.padding

        spacing: root.config.sectionSpacing

        RowLayout {
            Layout.fillWidth: true

            spacing: root.config.zoneSpacing

            StyledText {
                Layout.fillWidth: true

                text: root.config.labelTitle
                color: Colours.textBright
                font.pixelSize: Appearance.font.size.large
                font.bold: true
            }

            SegmentBar {
                visible: BarLayoutState.screens.length > 1
                width: root.config.screenSegmentWidth * BarLayoutState.screens.length
                implicitWidth: width

                accent: Colours.tabBar
                options: BarLayoutState.screens.map(name => ({
                            key: name,
                            label: name
                        }))
                current: BarLayoutState.screen

                onSelected: key => BarLayoutState.screen = key
            }

            PillButton {
                glyph: Icons.undo
                label: root.config.labelReset

                onTriggered: Prefs.resetBarLayout()
            }

            PillButton {
                glyph: Icons.check
                label: root.config.labelDone
                accent: true
                tint: Colours.tabBar

                onTriggered: BarLayoutState.hide()
            }
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: root.config.zoneSpacing

            ZoneBox {
                id: leftZone

                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.alignment: Qt.AlignTop

                zone: BarZone.left
                title: BarZone.options[0].label
                entries: BarLayoutState.zoneEntries(BarZone.left)
                dragging: root.lifted ? root.dragging : ""
                targeted: root.target === leftZone
                before: root.before

                onChipPressed: (chip, x, y) => root.begin(chip, x, y)
                onChipMoved: (chip, x, y) => root.track(chip, x, y)
                onChipReleased: root.finish()
            }

            ZoneBox {
                id: centreZone

                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.alignment: Qt.AlignTop

                zone: BarZone.centre
                title: BarZone.options[1].label
                entries: BarLayoutState.zoneEntries(BarZone.centre)
                dragging: root.lifted ? root.dragging : ""
                targeted: root.target === centreZone
                before: root.before

                onChipPressed: (chip, x, y) => root.begin(chip, x, y)
                onChipMoved: (chip, x, y) => root.track(chip, x, y)
                onChipReleased: root.finish()
            }

            ZoneBox {
                id: rightZone

                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.alignment: Qt.AlignTop

                zone: BarZone.right
                title: BarZone.options[2].label
                entries: BarLayoutState.zoneEntries(BarZone.right)
                dragging: root.lifted ? root.dragging : ""
                targeted: root.target === rightZone
                before: root.before

                onChipPressed: (chip, x, y) => root.begin(chip, x, y)
                onChipMoved: (chip, x, y) => root.track(chip, x, y)
                onChipReleased: root.finish()
            }
        }

        ZoneBox {
            id: tray

            Layout.fillWidth: true

            minHeight: root.config.trayMinHeight
            title: root.config.labelHidden.arg(BarLayoutState.screen)
            entries: BarLayoutState.hidden
            dragging: root.lifted ? root.dragging : ""
            targeted: root.target === tray

            onChipPressed: (chip, x, y) => root.begin(chip, x, y)
            onChipMoved: (chip, x, y) => root.track(chip, x, y)
            onChipReleased: root.finish()
        }

        StyledText {
            Layout.fillWidth: true

            text: root.config.labelHint
            color: Colours.textMuted
            font.pixelSize: root.config.chipTextSize
            wrapMode: Text.WordWrap
        }
    }

    LayoutChip {
        id: ghost

        entry: root.dragging
        ghost: true
        visible: root.lifted
        z: 10
    }
}
