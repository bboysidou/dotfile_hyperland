pragma Singleton

import QtQuick
import Quickshell
import qs.core.constants

Singleton {
    id: root

    function chord(text: string): var {
        return text.split("+").map(part => root.cap(part.trim())).filter(part => part.length > 0);
    }

    function cap(token: string): string {
        const alias = KeyNames.aliases[token.toLowerCase()];
        if (alias)
            return alias;

        return token.length === 1 ? token.toUpperCase() : token;
    }

    function tail(text: string): string {
        const caps = root.chord(text);
        return caps.length > 0 ? caps[caps.length - 1] : "";
    }

    function label(action: string): string {
        const text = Str.oneLine(action);

        const command = text.match(/^hl\.dsp\.exec_cmd\(\s*(.*?)\s*\)$/);
        if (command)
            return root.program(command[1]);

        const global = text.match(/^hl\.dsp\.global\(\s*"(.*)"\s*\)$/);
        if (global)
            return root.words(global[1].replace(/^quickshell:/, ""));

        if (text.startsWith("function"))
            return root.label(root.dispatched(text));

        const call = text.match(/^hl\.dsp\.([\w.]+)\(\s*([\s\S]*?)\s*\)$/);
        if (call)
            return (root.words(call[1]) + " " + root.fields(call[2])).trim();

        return root.words(text);
    }

    function program(argument: string): string {
        const bare = argument.replace(/^"(.*)"$/, "$1").replace(/^sh\s+-c\s+/, "").replace(/^'(.*)'$/, "$1").trim();
        const script = bare.match(/([\w-]+)\.sh\b/);

        if (script)
            return root.words(script[1]);

        return bare;
    }

    function dispatched(body: string): string {
        const found = body.match(/hl\.dsp\.[\w.]+\([^()]*(\([^()]*\))?[^()]*\)/g);
        return found ? found[found.length - 1] : body;
    }

    function fields(table: string): string {
        const pattern = /(\w+)\s*=\s*("[^"]*"|[^,{}]+)/g;
        const parts = [];

        let match;
        while ((match = pattern.exec(table)) !== null)
            parts.push(root.field(match[1], match[2].trim()));

        return parts.filter(part => part.length > 0).join(" ");
    }

    function field(name: string, value: string): string {
        const literal = value.match(/^"(.*)"$/);
        if (literal)
            return literal[1];

        if (value === "true" || value === "false")
            return "";

        if (/^-?\d+$/.test(value))
            return Number(value) === 0 ? "" : `${name} ${value}`;

        return name;
    }

    function words(text: string): string {
        const parts = text.split(/[\s.\-_:]+/).filter(part => part.length > 0);
        if (parts.length === 0)
            return "";

        const joined = parts.join(" ").toLowerCase();
        return joined.charAt(0).toUpperCase() + joined.slice(1);
    }
}
