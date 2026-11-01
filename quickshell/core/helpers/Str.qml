pragma Singleton

import Quickshell
import qs.core.constants

Singleton {
    id: root

    function fold(value: string): string {
        return (value ?? "").toLowerCase();
    }

    function oneLine(value: string): string {
        return (value ?? "").replace(/\s+/g, " ").trim();
    }

    function words(value: string): var {
        return value.split(/[\s\-_.]+/).filter(word => word.length > 0);
    }

    function isSubsequence(needle: string, haystack: string): bool {
        let cursor = 0;

        for (const character of haystack) {
            if (character === needle.charAt(cursor))
                cursor++;

            if (cursor === needle.length)
                return true;
        }

        return false;
    }

    function plain(markup: string): string {
        let text = (markup ?? "").replace(NotifHints.markupTag, "");
        for (const [pattern, replacement] of NotifHints.entities)
            text = text.replace(pattern, replacement);
        return text;
    }

    function otp(text: string): string {
        const source = root.plain(text);
        if (!NotifHints.codeContext.test(source))
            return "";
        const match = NotifHints.codeDigits.exec(source);
        return match ? match[1].replace(NotifHints.codeSeparators, "") : "";
    }

    function contains(haystack: string, needle: string): bool {
        return root.fold(haystack).includes(root.fold(needle));
    }

    function choices(value: string): var {
        const tokens = root.oneLine(value).split(" ").filter(token => token.length > 0);
        const marked = tokens.find(token => token.startsWith("[") && token.endsWith("]"));
        const options = tokens.map(token => token.replace(/^\[|\]$/g, ""));

        return {
            current: marked ? marked.slice(1, -1) : (options.length === 1 ? options[0] : ""),
            options: options
        };
    }
}
