pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.dashboard.components
import qs.services

Card {
    id: root

    signal focusRequested
    signal focusReleased

    implicitHeight: (layout.implicitHeight || 0) + Appearance.dash.cardPadding * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.dash.cardPadding

        spacing: Appearance.dash.cardSpacing

        CardLabel {
            Layout.fillWidth: true

            icon: Icons.place
            label: Appearance.prayer.labelPlace
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.dash.cardSpacing

            StyledText {
                Layout.fillWidth: true

                text: Prayer.place.country ? `${Prayer.place.city}, ${Prayer.place.country}` : Prayer.place.city
                color: Colours.textBright
                font.weight: Appearance.font.weightActive
                elide: Text.ElideRight
            }

            StyledText {
                text: Prayer.source
                color: Colours.textMuted
                font.pixelSize: Appearance.dash.cardLabelSize
            }
        }

        StyledText {
            Layout.fillWidth: true

            text: Appearance.prayer.coordFormat.arg(Prayer.place.lat.toFixed(Appearance.prayer.coordPrecision)).arg(Prayer.place.lon.toFixed(Appearance.prayer.coordPrecision))
            color: Colours.textMuted
            font.pixelSize: Appearance.dash.cardLabelSize
        }

        StyledText {
            Layout.fillWidth: true

            visible: Prayer.zoneMismatch
            text: Appearance.prayer.zoneWarning.arg(Prayer.place.tz).arg(Qt.formatDateTime(Time.now, "t"))
            color: Colours.critical
            font.pixelSize: Appearance.dash.cardLabelSize
            wrapMode: Text.Wrap
        }

        StyledText {
            Layout.fillWidth: true

            visible: Geo.error.length > 0
            text: Geo.error
            color: Colours.critical
            font.pixelSize: Appearance.dash.cardLabelSize
            wrapMode: Text.Wrap
        }

        TextField {
            id: search

            Layout.fillWidth: true

            icon: Icons.launcherSearch
            placeholder: Appearance.prayer.labelSearch

            onActivated: root.focusRequested()

            onEdited: text => Geo.search(text)

            onAccepted: {
                if (Geo.results.length === 0)
                    return;

                Prayer.pin(Geo.results[0]);
                Geo.clearResults();
                search.reset();
                root.focusReleased();
            }

            onCancelled: {
                search.reset();
                Geo.clearResults();
                root.focusReleased();
            }
        }

        StyledText {
            Layout.fillWidth: true

            visible: Geo.searching
            text: Appearance.prayer.labelSearching
            color: Colours.textMuted
            font.pixelSize: Appearance.dash.cardLabelSize
        }

        Repeater {
            model: Geo.results

            PrayerSearchRow {
                id: result

                required property var modelData

                Layout.fillWidth: true

                place: result.modelData

                onPicked: {
                    Prayer.pin(result.modelData);
                    Geo.clearResults();
                    search.reset();
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: Appearance.dash.cardSpacing

            IconButton {
                icon: Icons.refresh
                disabled: Geo.detecting

                onTriggered: Geo.detect()
            }

            StyledText {
                Layout.fillWidth: true

                text: Geo.detecting ? Appearance.prayer.labelDetecting : Appearance.prayer.labelDetect
                color: Colours.textMuted
                font.pixelSize: Appearance.dash.cardLabelSize
                elide: Text.ElideRight
            }

            IconButton {
                icon: Icons.pinOff
                visible: !!Prayer.pinned

                onTriggered: Prayer.unpin()
            }
        }
    }
}
