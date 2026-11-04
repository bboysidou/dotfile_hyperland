import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core.config
import qs.core.constants
import qs.core.enums
import qs.core.helpers
import qs.modules.screenshot

PanelWindow {
    id: root

    required property var modelData

    readonly property bool primary: Monitors.focused === root.modelData.name
    readonly property var windows: ScreenshotState.listed ? ScreenshotState.windowsFor(root.modelData) : []
    readonly property real scale: frame.hasContent ? ScreenshotState.pixelSize(frame, root.modelData).width / root.width : 1
    readonly property bool ready: ScreenshotState.opened && frame.hasContent && ScreenshotState.listed
    readonly property bool interactive: root.live()
    readonly property bool picking: ScreenshotState.mode === ScreenshotMode.monitor
    readonly property var whole: Geom.rect(0, 0, root.width, root.height)
    readonly property Region passThrough: Region {}
    readonly property var focusRect: root.picking ? (root.inside ? root.whole : null) : (root.region ?? root.hovered)

    property bool pressed: false
    property bool dragging: false
    property real startX: 0
    property real startY: 0
    property real pointerX: 0
    property real pointerY: 0
    property var region: null
    property var hovered: null
    property bool inside: false

    function live(): bool {
        return root.ready && ScreenshotState.mode !== ScreenshotMode.all;
    }

    function reset(): void {
        root.pressed = false;
        root.dragging = false;
        root.region = null;
        root.hovered = null;
        root.inside = false;
    }

    function captureRegion(r, label: string): void {
        const bounded = Geom.clamp(r, root.width, root.height);
        if (bounded.width < 1 || bounded.height < 1 || !root.live())
            return;

        ScreenshotState.capture(frame, root.modelData, bounded, label);
    }

    function captureWindow(w): void {
        root.captureRegion(w, Appearance.screenshot.windowLabel);
    }

    function captureMonitor(): void {
        root.captureRegion(root.whole, Appearance.screenshot.monitorLabel);
    }

    function restore(): void {
        const last = ScreenshotState.lastRegion;
        if (last && last.screen === root.modelData.name)
            root.captureRegion(last.rect, Appearance.screenshot.regionLabel);
    }

    function track(x: real, y: real): void {
        root.pointerX = x;
        root.pointerY = y;
        root.inside = true;
        if (root.picking)
            return;

        if (root.pressed && !root.dragging)
            root.dragging = Math.hypot(x - root.startX, y - root.startY) > Appearance.screenshot.dragThreshold;

        if (root.dragging)
            root.region = Geom.clamp(Geom.span(root.startX, root.startY, x, y, ScreenshotShape.ratios[ScreenshotState.shape]), root.width, root.height);
        else
            root.hovered = Geom.topAt(root.windows, x, y);
    }

    function seed(): void {
        const cursor = ScreenshotState.cursor;
        if (!cursor || !root.live() || root.pressed)
            return;

        const x = cursor.x - root.modelData.x;
        const y = cursor.y - root.modelData.y;
        if (x >= 0 && y >= 0 && x < root.width && y < root.height)
            root.track(x, y);
    }

    function release(): void {
        const region = root.region;
        const dragged = root.dragging;
        const target = root.hovered;
        root.pressed = false;
        root.dragging = false;
        root.region = null;
        if (root.picking)
            root.captureMonitor();
        else if (dragged && region)
            root.captureRegion(region, Appearance.screenshot.regionLabel);
        else if (target)
            root.captureWindow(target);
        else
            root.captureMonitor();
    }

    function readout(): string {
        const size = root.focusRect;
        if (root.picking)
            return `${root.modelData.name}  ${Math.round(root.width * root.scale)}${Appearance.screenshot.sizeSeparator}${Math.round(root.height * root.scale)}`;

        const shape = (ScreenshotState.shape === ScreenshotShape.free ? "" : `  ${ScreenshotShape.labels[ScreenshotState.shape]}`) + (ScreenshotState.annotate ? `  ${Appearance.screenshot.annotateTag}` : "");
        if (root.dragging && size)
            return `${Math.round(size.width * root.scale)}${Appearance.screenshot.sizeSeparator}${Math.round(size.height * root.scale)}${shape}`;

        return `${Math.round(root.pointerX * root.scale)}${Appearance.screenshot.coordSeparator}${Math.round(root.pointerY * root.scale)}${shape}`;
    }

    screen: root.modelData
    visible: ScreenshotState.opened
    color: "transparent"
    mask: root.interactive ? null : root.passThrough

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: Ids.screenshotNamespace
    WlrLayershell.keyboardFocus: root.interactive && root.primary ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    onVisibleChanged: root.reset()

    onReadyChanged: {
        if (!root.ready)
            return;

        if (ScreenshotState.mode === ScreenshotMode.all) {
            ScreenshotState.contribute(frame, root.modelData);
            return;
        }

        if (!root.primary)
            return;

        ScreenshotState.settle();
        keys.forceActiveFocus();
        root.seed();
    }

    Connections {
        target: ScreenshotState

        function onCursorChanged(): void {
            root.seed();
        }
    }

    onPrimaryChanged: {
        if (root.interactive && root.primary)
            keys.forceActiveFocus();
    }

    ScreencopyView {
        id: frame

        anchors.fill: parent

        captureSource: ScreenshotState.opened ? root.modelData : null
        live: false
        paintCursor: false
        opacity: root.ready ? 1 : 0
    }

    ScreenshotDim {
        anchors.fill: parent

        visible: root.interactive
        hole: root.region
    }

    Rectangle {
        visible: root.interactive && root.focusRect !== null
        x: root.focusRect?.x ?? 0
        y: root.focusRect?.y ?? 0
        width: root.focusRect?.width ?? 0
        height: root.focusRect?.height ?? 0

        color: "transparent"
        radius: root.dragging || root.picking ? 0 : Appearance.screenshot.windowRounding
        border.width: root.dragging ? Appearance.screenshot.borderWidth : Appearance.screenshot.windowBorderWidth
        border.color: Colours.accent
    }

    ScreenshotReadout {
        visible: root.interactive && root.inside
        pointerX: root.pointerX
        pointerY: root.pointerY
        text: root.readout()
    }

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.CrossCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPositionChanged: mouse => root.track(mouse.x, mouse.y)
        onExited: root.inside = false

        onPressed: mouse => {
            if (mouse.button === Qt.RightButton) {
                ScreenshotState.close();
                return;
            }
            root.pressed = true;
            root.startX = mouse.x;
            root.startY = mouse.y;
        }

        onReleased: mouse => {
            if (mouse.button === Qt.LeftButton && root.pressed)
                root.release();
        }
    }

    ScreenshotKeys {
        id: keys

        windows: root.windows
        hovered: root.hovered
        dragging: root.dragging

        onCancelled: {
            if (root.dragging)
                root.reset();
            else
                ScreenshotState.close();
        }
        onAccepted: root.hovered ? root.captureWindow(root.hovered) : root.captureMonitor()
        onSelectAll: root.captureMonitor()
        onRestored: root.restore()
        onAnnotateToggled: ScreenshotState.annotate = !ScreenshotState.annotate
        onShapeStepped: delta => ScreenshotState.cycleShape(delta)
        onMoved: target => root.hovered = target
    }
}
