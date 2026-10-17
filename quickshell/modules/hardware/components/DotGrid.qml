import QtQuick
import qs.core.config

Canvas {
    id: root

    property color colour: Colours.substrate
    property int pitch: Appearance.hardware.dotPitch
    property int dotSize: Appearance.hardware.dotSize

    opacity: Appearance.hardware.dotOpacity

    onColourChanged: root.requestPaint()
    onWidthChanged: root.requestPaint()
    onHeightChanged: root.requestPaint()

    onPaint: {
        const context = root.getContext("2d");
        const offset = root.pitch / 2;

        context.reset();
        context.fillStyle = root.colour;

        for (let y = offset; y < root.height; y += root.pitch) {
            for (let x = offset; x < root.width; x += root.pitch)
                context.fillRect(x, y, root.dotSize, root.dotSize);
        }
    }
}
