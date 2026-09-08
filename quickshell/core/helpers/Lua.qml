pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    function binds(source: string): var {
        const code = root.stripped(source);
        const base = root.strings(code);
        const marks = root.headings(source);
        const blocks = root.loops(code);
        const pattern = /hl\.bind\s*\(/g;
        const found = [];

        let match;
        while ((match = pattern.exec(code)) !== null) {
            const parts = root.args(code, match.index + match[0].length - 1);
            if (parts.length < 2)
                continue;

            const section = root.headingAt(marks, match.index);
            const block = blocks.find(entry => match.index > entry.start && match.index < entry.stop) ?? null;
            const action = root.substitute(parts[1], base);

            if (block)
                root.unrolled(code, parts[0], action, block, base, section, found);
            else
                root.single(parts[0], action, base, section, found);
        }

        return found;
    }

    function stripped(source: string): string {
        const characters = source.split("");

        let quote = "";
        let comment = false;

        for (let index = 0; index < characters.length; index++) {
            const character = characters[index];

            if (character === "\n") {
                comment = false;
                continue;
            }

            if (comment) {
                characters[index] = " ";
                continue;
            }

            if (quote) {
                if (character === quote && source[index - 1] !== "\\")
                    quote = "";
                continue;
            }

            if (character === '"' || character === "'")
                quote = character;
            else if (character === "-" && source[index + 1] === "-") {
                comment = true;
                characters[index] = " ";
            }
        }

        return characters.join("");
    }

    function substitute(action: string, base: var): string {
        return action.replace(/[A-Za-z_]\w*/g, token => {
            const value = base[token];
            return value === undefined ? token : `"${value}"`;
        });
    }

    function single(expr: string, action: string, base: var, section: string, found: var): void {
        const chord = root.resolve(expr, base);

        if (chord)
            found.push({
                section,
                chord,
                through: "",
                action
            });
    }

    function unrolled(code: string, expr: string, action: string, block: var, base: var, section: string, found: var): void {
        const body = code.slice(block.start, block.stop);
        const chords = [];

        for (let step = block.from; step <= block.to; step++) {
            const chord = root.resolve(expr, root.scope(body, base, block.name, step));

            if (chord)
                chords.push(chord);
        }

        if (chords.length > 0)
            found.push({
                section,
                chord: chords[0],
                through: chords.length > 1 ? chords[chords.length - 1] : "",
                action
            });
    }

    function strings(source: string): var {
        const pattern = /local\s+(\w+)\s*=\s*"([^"]*)"/g;
        const found = {};

        let match;
        while ((match = pattern.exec(source)) !== null)
            found[match[1]] = match[2];

        return found;
    }

    function headings(source: string): var {
        const pattern = /^--\s*(.*?)\s*-{3,}\s*$/gm;
        const found = [];

        let match;
        while ((match = pattern.exec(source)) !== null)
            found.push({
                index: match.index,
                title: match[1]
            });

        return found;
    }

    function headingAt(marks: var, index: int): string {
        let title = "";

        for (const mark of marks) {
            if (mark.index > index)
                break;

            title = mark.title;
        }

        return title;
    }

    function loops(source: string): var {
        const pattern = /for\s+(\w+)\s*=\s*(-?\d+)\s*,\s*(-?\d+)\s*do/g;
        const found = [];

        let match;
        while ((match = pattern.exec(source)) !== null)
            found.push({
                name: match[1],
                from: Number(match[2]),
                to: Number(match[3]),
                start: match.index,
                stop: root.blockEnd(source, match.index + match[0].length)
            });

        return found;
    }

    function blockEnd(source: string, from: int): int {
        const pattern = /\b(function|do|if|end)\b/g;
        pattern.lastIndex = from;

        let depth = 1;
        let match;

        while ((match = pattern.exec(source)) !== null) {
            if (match[1] !== "end") {
                depth++;
                continue;
            }

            depth--;
            if (depth === 0)
                return match.index;
        }

        return source.length;
    }

    function args(source: string, open: int): var {
        const parts = [];

        let depth = 0;
        let start = open + 1;
        let quote = "";

        for (let index = open; index < source.length; index++) {
            const character = source[index];

            if (quote) {
                if (character === quote && source[index - 1] !== "\\")
                    quote = "";
                continue;
            }

            if (character === '"' || character === "'")
                quote = character;
            else if (character === "(" || character === "{")
                depth++;
            else if (character === "," && depth === 1) {
                parts.push(source.slice(start, index).trim());
                start = index + 1;
            } else if (character === ")" || character === "}") {
                depth--;

                if (depth === 0) {
                    parts.push(source.slice(start, index).trim());
                    return parts;
                }
            }
        }

        return parts;
    }

    function resolve(expr: string, locals: var): string {
        let text = "";

        for (const part of expr.split("..")) {
            const token = part.trim();
            const literal = token.match(/^"([^"]*)"$/);

            if (literal) {
                text += literal[1];
                continue;
            }

            const value = locals[token];
            if (value === undefined)
                return "";

            text += value;
        }

        return text;
    }

    function scope(body: string, base: var, name: string, step: int): var {
        const pattern = /local\s+(\w+)\s*=\s*([^\n]+)/g;
        const locals = Object.assign({}, base);
        locals[name] = step;

        let match;
        while ((match = pattern.exec(body)) !== null) {
            const computed = root.evaluate(match[2].split("--")[0].trim(), locals);

            if (computed !== null)
                locals[match[1]] = computed;
        }

        return locals;
    }

    function evaluate(expr: string, locals: var): var {
        const parts = expr.match(/^(\w+)\s*([%+\-*/])\s*(\w+)$/);
        if (!parts)
            return root.number(expr, locals);

        const left = root.number(parts[1], locals);
        const right = root.number(parts[3], locals);

        if (left === null || right === null)
            return null;

        if (parts[2] === "%")
            return right === 0 ? null : left % right;
        if (parts[2] === "+")
            return left + right;
        if (parts[2] === "-")
            return left - right;
        if (parts[2] === "*")
            return left * right;

        return right === 0 ? null : Math.floor(left / right);
    }

    function number(token: string, locals: var): var {
        const trimmed = token.trim();

        if (/^-?\d+$/.test(trimmed))
            return Number(trimmed);

        const found = locals[trimmed];
        return typeof found === "number" ? found : null;
    }
}
