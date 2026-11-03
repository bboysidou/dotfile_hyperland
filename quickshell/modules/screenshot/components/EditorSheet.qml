import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import qs.core.config
import qs.modules.screenshot

Item {
    id: root

    required property real zoom
    required property var view
    required property int pad
    property bool live: false

    readonly property var colours: root.pad > 0 ? Appearance.editor.backdrops[EditorState.backdrop] ?? null : null
    readonly property real rounding: root.colours ? Appearance.editor.backdropRounding * root.zoom : 0

    width: (root.view.width + root.pad * 2) * root.zoom
    height: (root.view.height + root.pad * 2) * root.zoom

    EditorBackdrop {
        anchors.fill: parent

        visible: root.colours !== null
        colours: root.colours ?? ["transparent", "transparent"]
    }

    RectangularShadow {
        anchors.fill: picture

        visible: root.colours !== null
        radius: root.rounding
        blur: Appearance.editor.shadowBlur * root.zoom
        offset.y: Appearance.editor.shadowOffset * root.zoom
        color: Qt.alpha(Colours.shadow, Appearance.editor.shadowOpacity)
    }

    ClippingRectangle {
        id: picture

        x: root.pad * root.zoom
        y: root.pad * root.zoom
        width: root.view.width * root.zoom
        height: root.view.height * root.zoom
        radius: root.rounding
        color: "transparent"

        Item {
            x: -root.view.x * root.zoom
            y: -root.view.y * root.zoom
            width: EditorState.imageWidth * root.zoom
            height: EditorState.imageHeight * root.zoom

            Image {
                id: image

                anchors.fill: parent

                source: EditorState.path ? `file://${EditorState.path}` : ""
                cache: false
                smooth: true
                mipmap: true

                onStatusChanged: {
                    if (root.live && status === Image.Ready) {
                        EditorState.imageWidth = implicitWidth;
                        EditorState.imageHeight = implicitHeight;
                    } else if (root.live && status === Image.Error) {
                        EditorState.close();
                        ScreenshotState.fail(Appearance.editor.failLoad);
                    }
                }
            }

            EditorCanvas {
                anchors.fill: parent

                zoom: root.zoom
                live: root.live
                source: image
            }
        }
    }
}
