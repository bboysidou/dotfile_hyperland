import QtQuick
import QtQuick.Layouts
import qs.core.components
import qs.core.config
import qs.core.enums
import qs.modules.launcher.components
import qs.services

RevealCard {
    id: root

    signal dismissed

    readonly property int carouselItemWidth: Appearance.launcher.wallpaperItemWidth + Appearance.launcher.wallpaperItemPadding * 2
    readonly property bool carouselMode: LauncherState.wallpaperMode || LauncherState.themeMode
    readonly property int carouselCount: LauncherState.themeMode ? Theme.query(LauncherState.search).length : Wallpaper.query(LauncherState.search).length

    readonly property int carouselItems: {
        const available = (root.parent?.width ?? 0) - Appearance.launcher.padding * 2;
        const fits = Math.floor(available / root.carouselItemWidth);
        const shown = Math.min(fits, Appearance.launcher.wallpaperMax, root.carouselCount);

        if (shown === 2)
            return 1;
        if (shown > 1 && shown % 2 === 0)
            return shown - 1;
        return Math.max(0, shown);
    }

    implicitWidth: root.carouselMode ? Math.max(Appearance.launcher.width, root.carouselItems * root.carouselItemWidth + Appearance.launcher.padding * 2) : Appearance.launcher.width
    implicitHeight: layout.implicitHeight + Appearance.launcher.padding * 2

    color: Colours.bar
    topLeftRadius: Appearance.border.rounding
    topRightRadius: Appearance.border.rounding
    bottomLeftRadius: 0
    bottomRightRadius: 0
    scaleFrom: Appearance.launcher.scaleFrom
    transformOrigin: Item.Bottom

    visible: root.revealed || root.opacity > 0

    onRevealedChanged: {
        if (root.revealed) {
            field.setText(LauncherState.search);
            field.focusInput();
        }
    }

    Connections {
        target: LauncherState

        function onSearchChanged(): void {
            if (field.text !== LauncherState.search)
                field.setText(LauncherState.search);
        }
    }

    Behavior on implicitWidth {
        Anim {
            type: AnimType.emphasizedSmall
        }
    }

    Behavior on implicitHeight {
        Anim {
            type: AnimType.emphasizedSmall
        }
    }

    Fillet {
        anchors.right: parent.left
        anchors.bottom: parent.bottom

        origin: Corner.topLeft
    }

    Fillet {
        anchors.left: parent.right
        anchors.bottom: parent.bottom

        origin: Corner.topRight
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: Appearance.launcher.padding

        spacing: Appearance.launcher.spacing

        TextField {
            id: field

            Layout.fillWidth: true

            placeholder: LauncherState.themeMode ? Appearance.launcher.themePlaceholder : LauncherState.wallpaperMode ? Appearance.launcher.wallpaperPlaceholder : Appearance.launcher.placeholder
            icon: LauncherState.themeMode ? Icons.palette : LauncherState.wallpaperMode ? Icons.wallpaper : Icons.launcherSearch
            gridNavigation: root.carouselMode

            onEdited: text => LauncherState.edit(text)
            onNavigate: delta => content.item?.step(delta)
            onNavigateColumn: delta => content.item?.step(delta)
            onAccepted: {
                if (LauncherState.themeMode)
                    LauncherState.activateTheme(content.item?.selected ?? "");
                else if (LauncherState.wallpaperMode)
                    LauncherState.activateWallpaper(content.item?.selected ?? "");
                else
                    LauncherState.activate(content.item?.current ?? null);
            }
            onCancelled: root.dismissed()
        }

        AnimLoader {
            id: content

            Layout.fillWidth: true
            Layout.preferredHeight: item?.implicitHeight ?? 0

            sourceComp: LauncherState.themeMode ? themeComp : LauncherState.wallpaperMode ? wallpaperComp : appsComp
        }
    }

    Component {
        id: appsComp

        AppList {
            search: LauncherState.search

            onActivated: entry => LauncherState.activate(entry)
        }
    }

    Component {
        id: wallpaperComp

        WallpaperStrip {
            search: LauncherState.search
            visibleItems: root.carouselItems

            onActivated: path => LauncherState.activateWallpaper(path)
        }
    }

    Component {
        id: themeComp

        ThemeStrip {
            search: LauncherState.search
            visibleItems: root.carouselItems

            onActivated: name => LauncherState.activateTheme(name)
        }
    }
}
