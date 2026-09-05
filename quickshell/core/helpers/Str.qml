pragma Singleton

import Quickshell

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

    function contains(haystack: string, needle: string): bool {
        return root.fold(haystack).includes(root.fold(needle));
    }
}
