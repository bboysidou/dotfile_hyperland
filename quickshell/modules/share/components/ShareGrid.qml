pragma ComponentBehavior: Bound

import QtQuick
import qs.core.components
import qs.core.config
import qs.modules.share

Item {
    id: root

    property bool live: false
    property color accent: Colours.accent

    readonly property int cellWidth: Math.floor(root.width / Appearance.share.columns)
    readonly property int cellHeight: Appearance.share.previewHeight + Appearance.share.labelIconSize + Appearance.share.tilePadding * 2 + Appearance.share.tileSpacing + Appearance.share.cellSpacing
    readonly property int rows: Math.min(Math.ceil(ShareState.entries.length / Appearance.share.columns), Appearance.share.maxRows)

    implicitHeight: ShareState.entries.length > 0 ? root.rows * root.cellHeight : Appearance.share.emptyHeight

    GridView {
        id: grid

        anchors.fill: parent

        visible: ShareState.entries.length > 0
        clip: true
        cellWidth: root.cellWidth
        cellHeight: root.cellHeight
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: ShareState.index

        model: ShareState.entries

        onCurrentIndexChanged: grid.positionViewAtIndex(grid.currentIndex, GridView.Contain)

        delegate: ShareTile {
            required property var modelData
            required property int index

            width: root.cellWidth - Appearance.share.cellSpacing
            height: root.cellHeight - Appearance.share.cellSpacing

            entry: modelData
            selected: index === ShareState.index
            live: root.live
            accent: root.accent

            onClicked: ShareState.select(index)
            onActivated: ShareState.share()
        }
    }

    EmptyState {
        anchors.centerIn: parent

        visible: ShareState.entries.length === 0
        accent: root.accent
        glyph: Icons.shareWindow
        title: Appearance.share.emptyTitle
        subtitle: Appearance.share.emptySubtitle
    }
}
