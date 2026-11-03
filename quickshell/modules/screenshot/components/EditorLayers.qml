pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.qmlmodels
import qs.core.enums

Repeater {
    id: root

    required property real zoom
    required property Item source
    property bool live: false

    delegate: DelegateChooser {
        role: "kind"

        DelegateChoice {
            roleValue: EditTool.arrow

            EditorArrow {
                required property var modelData

                ann: modelData
                zoom: root.zoom
            }
        }

        DelegateChoice {
            roleValue: EditTool.line

            EditorLine {
                required property var modelData

                ann: modelData
                zoom: root.zoom
            }
        }

        DelegateChoice {
            roleValue: EditTool.rect

            EditorRect {
                required property var modelData

                ann: modelData
                zoom: root.zoom
            }
        }

        DelegateChoice {
            roleValue: EditTool.ellipse

            EditorEllipse {
                required property var modelData

                ann: modelData
                zoom: root.zoom
            }
        }

        DelegateChoice {
            roleValue: EditTool.marker

            EditorMarker {
                required property var modelData

                ann: modelData
                zoom: root.zoom
            }
        }

        DelegateChoice {
            roleValue: EditTool.text

            EditorText {
                required property var modelData

                ann: modelData
                zoom: root.zoom
                live: root.live
            }
        }

        DelegateChoice {
            roleValue: EditTool.redact

            EditorRedact {
                required property var modelData

                ann: modelData
                zoom: root.zoom
                source: root.source
            }
        }

        DelegateChoice {
            roleValue: EditTool.highlight

            EditorStroke {
                required property var modelData

                ann: modelData
                zoom: root.zoom
            }
        }
    }
}
