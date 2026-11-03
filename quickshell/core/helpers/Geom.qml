pragma Singleton

import Quickshell

Singleton {
    id: root

    function rect(x: real, y: real, width: real, height: real): var {
        return {
            x: x,
            y: y,
            width: width,
            height: height
        };
    }

    function span(x0: real, y0: real, x1: real, y1: real, ratio: real): var {
        const dx = x1 - x0;
        let dy = y1 - y0;
        if (ratio > 0)
            dy = Math.sign(dy || 1) * Math.abs(dx) * ratio;

        return root.rect(Math.min(x0, x0 + dx), Math.min(y0, y0 + dy), Math.abs(dx), Math.abs(dy));
    }

    function clamp(r, width: real, height: real): var {
        const x = Math.max(0, Math.min(r.x, width));
        const y = Math.max(0, Math.min(r.y, height));
        return root.rect(x, y, Math.min(r.x + r.width, width) - x, Math.min(r.y + r.height, height) - y);
    }

    function contains(r, x: real, y: real): bool {
        return x >= r.x && y >= r.y && x < r.x + r.width && y < r.y + r.height;
    }

    function topAt(items, x: real, y: real): var {
        return items.find(item => root.contains(item, x, y)) ?? null;
    }

    function centre(r): var {
        return {
            x: r.x + r.width / 2,
            y: r.y + r.height / 2
        };
    }

    function step(items, current, dx: int, dy: int): var {
        if (!current)
            return items[0] ?? null;

        const from = root.centre(current);
        let best = null;
        let bestScore = Infinity;
        for (const item of items) {
            const to = root.centre(item);
            const along = (to.x - from.x) * dx + (to.y - from.y) * dy;
            if (item === current || along <= 0)
                continue;

            const across = Math.abs((to.x - from.x) * dy) + Math.abs((to.y - from.y) * dx);
            const score = along + across * 2;
            if (score < bestScore) {
                bestScore = score;
                best = item;
            }
        }
        return best ?? current;
    }
}
