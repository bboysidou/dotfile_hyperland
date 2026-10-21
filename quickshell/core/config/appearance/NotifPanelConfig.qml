import QtQuick

QtObject {
    readonly property int heroHeight: 96
    readonly property int heroSpacing: 16
    readonly property int heroTextSpacing: 2
    readonly property int heroControlSpacing: 10
    readonly property int heroNameSize: 16
    readonly property int heroDetailSize: 11

    readonly property int countWidth: 84
    readonly property int countSize: 46
    readonly property int countLabelSize: 11
    readonly property int countSpacing: 0
    readonly property int countRollLift: 14
    readonly property int countRollDuration: 420

    readonly property int chipPaddingH: 12
    readonly property int chipPaddingV: 5
    readonly property int chipFontSize: 11
    readonly property int chipBorderWidth: 1

    readonly property int switchTopMargin: 14
    readonly property int listTopMargin: 12
    readonly property int groupSpacing: 8
    readonly property int emptyTopMargin: 24

    readonly property int cardRounding: 12
    readonly property int cardBorderWidth: 1
    readonly property int cardHeaderHeight: 40
    readonly property int cardPaddingH: 12
    readonly property int cardPaddingV: 8
    readonly property int cardSpacing: 8
    readonly property int cardIconSize: 20
    readonly property int cardNameSize: 13
    readonly property int dotSize: 6

    readonly property int introHeaderDelay: 100
    readonly property int introContentDelay: 200
    readonly property int introHeaderDuration: 700
    readonly property int introContentDuration: 800
    readonly property real introOvershoot: 1.2
    readonly property int introHeaderLift: 20
    readonly property int introContentLift: 15

    readonly property string labelAll: "All"
    readonly property string labelUnread: "Unread"
    readonly property string labelCritical: "Critical"
    readonly property string labelTotal: "total"
    readonly property string countTemplate: "%1 total \u00b7 %2 apps"
    readonly property string labelMarkRead: "Mark all read"
    readonly property string labelClearCritical: "Clear critical"
    readonly property string emptyUnreadTitle: "Nothing new"
    readonly property string emptyUnreadSubtitle: "You have seen everything here"
    readonly property string emptyCriticalTitle: "No critical alerts"
    readonly property string emptyCriticalSubtitle: "Nothing needs attention"
}
