pragma Singleton

import Quickshell

Singleton {
    readonly property string value: "value"
    readonly property string synchronous: "x-canonical-private-synchronous"
    readonly property string stackTag: "x-dunst-stack-tag"
    readonly property string restored: "x-qs-restored"
    readonly property var captured: ["value", "x-canonical-private-synchronous", "x-dunst-stack-tag", "x-qs-restored"]
    readonly property var codeContext: /\b(code|otp|pin|passcode|password|verification|verify|2fa|one[- ]time|security|token|login)\b/i
    readonly property var codeDigits: /(?:^|\D)(\d{3}[- ]\d{3}|\d{4,8})(?!\d)/
    readonly property var codeSeparators: /[- ]/g
    readonly property var markupTag: /<[^>]*>/g
    readonly property var entities: [[/&lt;/g, "<"], [/&gt;/g, ">"], [/&quot;/g, "\""], [/&#39;|&apos;/g, "'"], [/&amp;/g, "&"]]
    readonly property var urgencyNames: ["low", "normal", "critical"]
}
