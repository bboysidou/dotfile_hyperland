import QtQuick

QtObject {
    readonly property int width: 430
    readonly property real scaleFrom: 0.96
    readonly property int commandMissing: 127
    readonly property string propertyName: "name"
    readonly property string propertyStages: "num-enroll-stages"
    readonly property int stagesFallback: 12
    readonly property int stagesPollInterval: 1000
    readonly property string resultPrefix: "Enroll result: "
    readonly property string statusPassed: "enroll-stage-passed"
    readonly property string statusCompleted: "enroll-completed"
    readonly property var failureLine: /failed|impossible/i
    readonly property var statusMessages: ({
            "enroll-retry-scan": "Scan not clear, touch the reader again",
            "enroll-swipe-too-short": "Swipe was too short, try again",
            "enroll-too-fast": "Too fast, slow down",
            "enroll-finger-not-centered": "Centre your finger on the reader",
            "enroll-remove-and-retry": "Lift your finger and touch again",
            "enroll-failed": "Enrolment failed",
            "enroll-data-full": "The reader has no room for another fingerprint",
            "enroll-duplicate": "This finger is already enrolled",
            "enroll-disconnected": "The reader was disconnected",
            "enroll-unknown-error": "The reader reported an error"
        })
    readonly property var fingerLabels: [["left-thumb", "Left thumb", "Thumb"], ["left-index-finger", "Left index", "Index"], ["left-middle-finger", "Left middle", "Middle"], ["left-ring-finger", "Left ring", "Ring"], ["left-little-finger", "Left little", "Little"], ["right-thumb", "Right thumb", "Thumb"], ["right-index-finger", "Right index", "Index"], ["right-middle-finger", "Right middle", "Middle"], ["right-ring-finger", "Right ring", "Ring"], ["right-little-finger", "Right little", "Little"]]
    readonly property string title: "Fingerprint"
    readonly property string labelReader: "Reader"
    readonly property string labelFingers: "Enrolled fingers"
    readonly property string labelSudo: "Use for sudo"
    readonly property string labelLock: "Use for lock screen"
    readonly property string labelManage: "Fingerprints"
    readonly property string labelOpen: "Manage"
    readonly property string labelAdd: "Add a finger"
    readonly property string labelLeftHand: "Left hand"
    readonly property string labelRightHand: "Right hand"
    readonly property string labelEnrolled: "Enrolled"
    readonly property string labelRemove: "Remove"
    readonly property string labelConfirm: "Sure?"
    readonly property string labelCancel: "Cancel"
    readonly property string labelRetry: "Try again"
    readonly property string labelSetup: "Setup"
    readonly property string labelOn: "On"
    readonly property string labelOff: "Off"
    readonly property string labelNoName: "Detected"
    readonly property string labelNotFound: "None found"
    readonly property string labelMissing: "fprintd not installed"
    readonly property string labelNone: "No fingers enrolled yet"
    readonly property string hintNoReader: "No fingerprint reader found. Plug one in, or run setup if fprintd is not installed."
    readonly property string promptTouch: "Touch the reader"
    readonly property string promptAgain: "Lift your finger, then touch again"
    readonly property string messageDone: "Fingerprint added"
    readonly property string messageGeneric: "Enrolment could not start"
    readonly property string messageRemoveFailed: "Could not remove that finger"
    readonly property string stageTemplate: "%1 of %2"
    readonly property int enrollPadding: 24
    readonly property int doneHold: 1400
    readonly property int viewSpacing: 16
    readonly property int listSpacing: 8
    readonly property int handSize: 5
    readonly property int chipSpacing: 6
    readonly property int chipRowHeight: 34
    readonly property int messageSize: 16
    readonly property int countSize: 13
    readonly property int confirmTimeout: 3000
    readonly property int glyphSize: 240
    readonly property int emptyGlyphSize: 200
    readonly property real glyphStroke: 7
    readonly property real glyphGap: 0.004
    readonly property real glyphSnap: 0.018
    readonly property real glyphSampleDegrees: 4
    readonly property real glyphCentreY: 0.52
    readonly property real glyphPopScale: 1.06
    readonly property int glyphPopDuration: 180
    readonly property int shakeAmplitude: 10
    readonly property int shakeStep: 55
    readonly property int flashHold: 500
    readonly property var ridges: [[0.05, 0.075, 180, 385], [0.095, 0.135, 150, 400], [0.14, 0.195, 165, 375], [0.185, 0.255, 140, 395], [0.23, 0.31, 160, 370], [0.275, 0.365, 145, 385], [0.32, 0.42, 170, 365], [0.365, 0.47, 190, 350]]
}
