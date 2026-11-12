import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.modules.display.components
import qs.services

SettingsSection {
    title: "Prayer Times"
    glyph: Icons.prayersTab

    SettingRow {
        label: "Activer les horaires et les alertes"
        Toggle {
            enabled: Prefs.loaded
            checked: Prefs.prayersEnabled
            onToggled: checked => Prefs.set("prayersEnabled", checked)
        }
    }

    StyledText {
        Layout.fillWidth: true
        text: Prefs.prayersEnabled
            ? "Service actif. Le bouton de la barre se règle séparément dans Général."
            : "Service arrêté : aucun calcul ni alerte de prière. La météo reste disponible."
        color: Colours.textMuted
        font.pixelSize: Appearance.font.size.small
        wrapMode: Text.WordWrap
    }
}
