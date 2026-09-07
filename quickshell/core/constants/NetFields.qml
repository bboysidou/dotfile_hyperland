pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string mac: "GENERAL.HWADDR"
    readonly property string connection: "GENERAL.CONNECTION"
    readonly property string address: "IP4.ADDRESS"
    readonly property string gateway: "IP4.GATEWAY"
    readonly property string dns: "IP4.DNS"

    readonly property var queried: [root.mac, root.connection, root.address, root.gateway, root.dns]

    readonly property string labelMac: "MAC"
    readonly property string labelConnection: "Profile"
    readonly property string labelAddress: "IPv4"
    readonly property string labelGateway: "Gateway"
    readonly property string labelDns: "DNS"
    readonly property string labelInterface: "Interface"
    readonly property string labelSecurity: "Security"
    readonly property string labelSignal: "Signal"
}
