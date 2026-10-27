import QtQuick

QtObject {
    readonly property int width: 380
    readonly property int padding: 14
    readonly property real scaleFrom: 0.96
    readonly property int pollMinutes: 30
    readonly property int timeout: 120
    readonly property int headerHeight: 40
    readonly property int headerSpacing: 10
    readonly property int headerIconSize: 20
    readonly property int actionSize: 18
    readonly property int actionSpacing: 12
    readonly property int spinDuration: 900
    readonly property int sectionSpacing: 8
    readonly property string tabRepo: "repo"
    readonly property string tabAur: "aur"
    readonly property int sectionRounding: 12
    readonly property int sectionPaddingV: 6
    readonly property int gridHeaderHeight: 28
    readonly property int gridLetterSpacing: 1
    readonly property int versionColumnWidth: 92
    readonly property int separatorHeight: 1
    readonly property int rowHeight: 32
    readonly property int rowSpacing: 8
    readonly property int rowPaddingH: 10
    readonly property int rowRounding: 8
    readonly property string title: "Updates"
    readonly property string labelRepo: "Repository"
    readonly property string labelAur: "AUR"
    readonly property string tabLabelFormat: "%1  %2"
    readonly property string columnPackage: "Package"
    readonly property string columnCurrent: "Current"
    readonly property string columnNew: "New"
    readonly property string emptyTitle: "Up to date"
    readonly property string emptySubtitle: "No packages waiting"
    readonly property string emptyRepo: "No repository updates"
    readonly property string emptyAur: "No AUR updates"
}
