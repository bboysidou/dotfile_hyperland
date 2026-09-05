import QtQuick
import QtQuick.Shapes
import qs.core.config

Item {
    id: root

    property var values: []
    property real maximum: 1
    property color colour: Colours.accent
    property real fillOpacity: Appearance.dash.sparkFillOpacity
    property int lineWidth: 2

    implicitHeight: Appearance.dash.netSparkHeight

    readonly property var points: {
        const data = root.values;

        if (data.length < 2 || root.width <= 0 || root.height <= 0)
            return [];

        const peak = data.reduce((highest, value) => Math.max(highest, value), root.maximum);
        const stepX = root.width / (data.length - 1);

        return data.map((value, index) => Qt.point(index * stepX, root.height - (peak > 0 ? value / peak : 0) * root.height));
    }

    readonly property var area: root.points.length < 2 ? [] : root.points.concat([Qt.point(root.width, root.height), Qt.point(0, root.height)])

    Shape {
        anchors.fill: parent

        preferredRendererType: Shape.CurveRenderer
        visible: root.points.length >= 2

        ShapePath {
            strokeWidth: -1
            fillColor: Qt.alpha(root.colour, root.fillOpacity)

            PathPolyline {
                path: root.area
            }
        }

        ShapePath {
            strokeWidth: root.lineWidth
            strokeColor: root.colour
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathPolyline {
                path: root.points
            }
        }
    }
}
