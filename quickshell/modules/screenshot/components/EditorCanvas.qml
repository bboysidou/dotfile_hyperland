import QtQuick
import qs.core.enums
import qs.modules.screenshot

Item {
    id: root

    required property real zoom
    required property Item source
    property bool live: false

    EditorLayers {
        model: EditorState.items
        zoom: root.zoom
        source: root.source
        live: root.live
    }

    EditorLayers {
        model: root.live && EditorState.draft && EditorState.draft.kind !== EditTool.crop ? [EditorState.draft] : []
        zoom: root.zoom
        source: root.source
    }

    EditorSelection {
        visible: root.live && EditorState.selected >= 0 && EditorState.selected < EditorState.items.length
        ann: EditorState.items[EditorState.selected] ?? null
        zoom: root.zoom
    }
}
