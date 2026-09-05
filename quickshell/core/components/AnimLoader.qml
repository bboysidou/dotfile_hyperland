import QtQuick
import qs.core.enums

Loader {
    id: root

    property Component sourceComp
    property string outType: AnimType.fastEffects
    property string inType: AnimType.defaultEffects

    property bool ready

    asynchronous: true

    Component.onCompleted: {
        root.ready = true;
        root.sourceComponent = root.sourceComp;
    }

    onSourceCompChanged: {
        if (root.ready)
            swap.restart();
    }

    SequentialAnimation {
        id: swap

        running: false

        Anim {
            target: root
            property: "opacity"
            to: 0
            type: root.outType
        }
        ScriptAction {
            script: root.sourceComponent = root.sourceComp
        }
        Anim {
            target: root
            property: "opacity"
            to: 1
            type: root.inType
        }
    }
}
