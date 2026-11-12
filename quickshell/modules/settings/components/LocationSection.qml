pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.display.components
import qs.services

SettingsSection {
    id: root
    title: "Localisation"
    glyph: Icons.place

    StyledText {
        Layout.fillWidth: true
        text: `${Location.place.city}, ${Location.place.country} · ${Location.source}`
        color: Colours.text
        wrapMode: Text.WordWrap
    }

    StyledText {
        Layout.fillWidth: true
        text: "Ville partagée par la météo et, si activés, les horaires de prière."
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
        wrapMode: Text.WordWrap
    }

    TextField {
        id: search
        Layout.fillWidth: true
        icon: Icons.launcherSearch
        placeholder: "Rechercher une ville"
        onEdited: text => Geo.search(text)
        onAccepted: {
            if (Geo.results.length > 0) {
                Location.pin(Geo.results[0]);
                Geo.clearResults();
                search.reset();
            }
        }
        onCancelled: { Geo.clearResults(); search.reset(); }
    }

    Repeater {
        model: Geo.results
        Chip {
            required property var modelData
            label: `${modelData.city}, ${modelData.country}`
            onTriggered: {
                Location.pin(modelData);
                Geo.clearResults();
                search.reset();
            }
        }
    }

    StyledText {
        Layout.fillWidth: true
        visible: Geo.searching || Geo.detecting || Geo.error.length > 0
        text: Geo.error || (Geo.searching ? "Recherche…" : "Localisation…")
        color: Colours.textMuted
        wrapMode: Text.WordWrap
    }

    SettingRow {
        label: "Localisation automatique"
        Chip {
            label: "Détecter"
            onTriggered: Geo.detect()
        }
        Chip {
            visible: !!Location.pinned
            label: "Détacher la ville"
            onTriggered: Location.unpin()
        }
    }
}
