pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root
    required property DeckController controller
    padding: 20; modal: true; focus: true
    background: Rectangle { color: "#20271f"; radius: 8; border.color: "#70816a" }
    onOpened: { linkError.text = ""; linkInput.forceActiveFocus(); }
    function submit() {
        if (controller.openYoutube(linkInput.text)) close();
        else linkError.text = "Collez un lien vers une vidéo ou une playlist YouTube.";
    }
    contentItem: ColumnLayout {
        spacing: 12
        Label { text: "Écouter YouTube"; color: "#d0c6ad"; font.pixelSize: 20 }
        TextField {
            id: linkInput; Layout.fillWidth: true
            placeholderText: "Collez le lien complet : vidéo, playlist ou Mix"
            color: "#d7dfcf"; placeholderTextColor: "#8b9582"; selectByMouse: true
            background: Rectangle { color: "#121812"; radius: 4; border.color: linkInput.activeFocus ? "#8db197" : "#54604d" }
            onAccepted: root.submit()
        }
        Label { text: "Collez directement le lien YouTube, en conservant list=…"; color: "#a2ac97" }
        Label { visible: /[?&]list=RD/.test(linkInput.text); text: "Mix YouTube : jusqu’à 50 pistes par ouverture."; color: "#a2ac97" }
        RowLayout {
            DeckButton { text: "Historique"; onClicked: tabs.currentIndex = 0 }
            DeckButton { text: "Favoris ★"; onClicked: tabs.currentIndex = 1 }
        }
        QtObject { id: tabs; property int currentIndex: 0 }
        Label {
            visible: library.count === 0
            text: tabs.currentIndex ? "Aucun favori. Utilisez ☆ pour en ajouter." : "Vos 10 derniers liens apparaîtront ici."
            color: "#a2ac97"
        }
        ListView {
            id: library
            Layout.fillWidth: true; Layout.preferredHeight: Math.min(300, contentHeight)
            clip: true; spacing: 4
            model: tabs.currentIndex ? root.controller.favorites : root.controller.youtubeHistory
            delegate: RowLayout {
                id: row
                required property var modelData
                width: ListView.view.width; height: 55
                ItemDelegate {
                    id: entry; Layout.fillWidth: true; Layout.fillHeight: true
                    Accessible.name: "Réécouter " + row.modelData.title
                    background: Rectangle { color: entry.hovered ? "#35422e" : "#192016"; radius: 4 }
                    contentItem: Column {
                        spacing: 2
                        Label { width: parent.width; text: "▶  " + row.modelData.title; elide: Text.ElideRight; color: "#d7dfcf" }
                        Label { width: parent.width; text: row.modelData.url; elide: Text.ElideRight; color: "#95a388"; font.pixelSize: 10 }
                    }
                    onClicked: { if (root.controller.openYoutube(row.modelData.url)) root.close(); }
                }
                DeckButton {
                    text: root.controller.isFavorite(row.modelData.url) ? "★" : "☆"
                    Accessible.name: root.controller.isFavorite(row.modelData.url) ? "Retirer des favoris" : "Ajouter aux favoris"
                    onClicked: root.controller.toggleFavorite(row.modelData.url, row.modelData.title)
                }
            }
            ScrollBar.vertical: ScrollBar {}
        }
        Label { id: linkError; Layout.fillWidth: true; wrapMode: Text.Wrap; color: "#e49b86" }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            DeckButton { text: "Annuler"; onClicked: root.close() }
            DeckButton { text: "Écouter"; onClicked: root.submit() }
        }
    }
}
