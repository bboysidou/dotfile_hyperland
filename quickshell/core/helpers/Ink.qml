pragma Singleton

import QtQuick
import Quickshell
import qs.core.enums

Singleton {
    id: root

    function point(x: real, y: real, zoom: real): point {
        return Qt.point(x * zoom, y * zoom);
    }

    function along(x: real, y: real, ux: real, uy: real, t: real): var {
        return {
            x: x + ux * t,
            y: y + uy * t
        };
    }

    function offset(p, nx: real, ny: real, t: real): var {
        return {
            x: p.x + nx * t,
            y: p.y + ny * t
        };
    }

    function arrow(a, zoom: real, head): var {
        const dx = a.x2 - a.x1;
        const dy = a.y2 - a.y1;
        const length = Math.hypot(dx, dy) || 1;
        const ux = dx / length;
        const uy = dy / length;
        const nx = -uy;
        const ny = ux;
        const twoHeads = a.style === ArrowStyle.double;
        const headLength = Math.min(head.length * a.width + head.min, length * (twoHeads ? head.maxRatio / 1.5 : head.maxRatio));
        const headHalf = (head.width * a.width + head.min) / 2;
        const half = a.width / 2;
        const tip = {
            x: a.x2,
            y: a.y2
        };
        const tail = {
            x: a.x1,
            y: a.y1
        };
        const base = root.along(a.x2, a.y2, ux, uy, -headLength);
        let points;
        if (twoHeads) {
            const back = root.along(a.x1, a.y1, ux, uy, headLength);
            points = [tail, root.offset(back, nx, ny, headHalf), root.offset(back, nx, ny, half), root.offset(base, nx, ny, half), root.offset(base, nx, ny, headHalf), tip, root.offset(base, nx, ny, -headHalf), root.offset(base, nx, ny, -half), root.offset(back, nx, ny, -half), root.offset(back, nx, ny, -headHalf), tail];
        } else {
            const tailHalf = a.style === ArrowStyle.pointy ? half * head.taper : half;
            const bodyHalf = a.style === ArrowStyle.pointy ? half * head.body : half;
            points = [root.offset(tail, nx, ny, tailHalf), root.offset(base, nx, ny, bodyHalf), root.offset(base, nx, ny, headHalf), tip, root.offset(base, nx, ny, -headHalf), root.offset(base, nx, ny, -bodyHalf), root.offset(tail, nx, ny, -tailHalf), root.offset(tail, nx, ny, tailHalf)];
        }
        return points.map(p => root.point(p.x, p.y, zoom));
    }

    function segmentDistance(px: real, py: real, a, b): real {
        const dx = b.x - a.x;
        const dy = b.y - a.y;
        const lengthSquared = dx * dx + dy * dy;
        const t = lengthSquared ? Math.max(0, Math.min(1, ((px - a.x) * dx + (py - a.y) * dy) / lengthSquared)) : 0;
        return Math.hypot(px - (a.x + t * dx), py - (a.y + t * dy));
    }

    function box(a): var {
        const trace = Curve.trace(a);
        if (trace) {
            const xs = trace.map(p => p.x);
            const ys = trace.map(p => p.y);
            const pad = a.width / 2;
            return {
                x: Math.min(...xs) - pad,
                y: Math.min(...ys) - pad,
                width: Math.max(...xs) - Math.min(...xs) + a.width,
                height: Math.max(...ys) - Math.min(...ys) + a.width
            };
        }
        if (a.radius !== undefined)
            return {
                x: a.x1 - a.radius,
                y: a.y1 - a.radius,
                width: a.radius * 2,
                height: a.radius * 2
            };
        if (a.text !== undefined)
            return {
                x: a.x1,
                y: a.y1,
                width: a.measuredWidth ?? 0,
                height: a.measuredHeight ?? 0
            };
        return {
            x: Math.min(a.x1, a.x2),
            y: Math.min(a.y1, a.y2),
            width: Math.abs(a.x2 - a.x1),
            height: Math.abs(a.y2 - a.y1)
        };
    }

    function hits(a, x: real, y: real, tolerance: real): bool {
        const reach = a.width / 2 + tolerance;
        const trace = Curve.trace(a);
        if (trace) {
            for (let i = 1; i < trace.length; i++) {
                if (root.segmentDistance(x, y, trace[i - 1], trace[i]) <= reach)
                    return true;
            }
            return trace.length === 1 && Math.hypot(x - trace[0].x, y - trace[0].y) <= reach;
        }
        if (a.kind === EditTool.arrow || a.kind === EditTool.line)
            return root.segmentDistance(x, y, {
                x: a.x1,
                y: a.y1
            }, {
                x: a.x2,
                y: a.y2
            }) <= reach;

        const b = root.box(a);
        return x >= b.x - tolerance && y >= b.y - tolerance && x <= b.x + b.width + tolerance && y <= b.y + b.height + tolerance;
    }

    function topHit(items, x: real, y: real, tolerance: real): int {
        for (let i = items.length - 1; i >= 0; i--) {
            if (root.hits(items[i], x, y, tolerance))
                return i;
        }
        return -1;
    }

    function moved(a, dx: real, dy: real): var {
        const copy = Object.assign({}, a, {
            x1: a.x1 + dx,
            y1: a.y1 + dy
        });
        if (a.x2 !== undefined) {
            copy.x2 = a.x2 + dx;
            copy.y2 = a.y2 + dy;
        }
        if (Curve.bent(a)) {
            copy.cx = a.cx + dx;
            copy.cy = a.cy + dy;
        }
        if (a.points)
            copy.points = a.points.map(p => ({
                        x: p.x + dx,
                        y: p.y + dy
                    }));
        return copy;
    }

    function constrained(a, x: real, y: real): var {
        const dx = x - a.x1;
        const dy = y - a.y1;
        if (a.kind === EditTool.arrow || a.kind === EditTool.line) {
            const step = Math.PI / 4;
            const angle = Math.round(Math.atan2(dy, dx) / step) * step;
            const length = Math.hypot(dx, dy);
            return {
                x: a.x1 + Math.cos(angle) * length,
                y: a.y1 + Math.sin(angle) * length
            };
        }
        const side = Math.max(Math.abs(dx), Math.abs(dy));
        return {
            x: a.x1 + Math.sign(dx || 1) * side,
            y: a.y1 + Math.sign(dy || 1) * side
        };
    }

    function handles(a): var {
        if (a.kind === EditTool.arrow || a.kind === EditTool.line) {
            const ends = [root.handle(a.x1, a.y1, "x1", "y1"), root.handle(a.x2, a.y2, "x2", "y2")];
            if (a.kind === EditTool.line)
                return ends;
            const middle = Curve.at(a, 0.5);
            return [...ends, root.handle(middle.x, middle.y, "cx", "cy")];
        }
        if (a.kind === EditTool.rect || a.kind === EditTool.ellipse || a.kind === EditTool.redact)
            return [root.handle(a.x1, a.y1, "x1", "y1"), root.handle(a.x2, a.y1, "x2", "y1"), root.handle(a.x1, a.y2, "x1", "y2"), root.handle(a.x2, a.y2, "x2", "y2")];
        return [];
    }

    function handle(x: real, y: real, fx: string, fy: string): var {
        return {
            x: x,
            y: y,
            fx: fx,
            fy: fy
        };
    }

    function handleAt(a, x: real, y: real, tolerance: real): var {
        return root.handles(a).find(h => Math.hypot(x - h.x, y - h.y) <= tolerance) ?? null;
    }

    function gripped(a, h, x: real, y: real): var {
        const copy = Object.assign({}, a);
        const bend = h.fx === "cx";
        copy[h.fx] = bend ? 2 * x - (a.x1 + a.x2) / 2 : x;
        copy[h.fy] = bend ? 2 * y - (a.y1 + a.y2) / 2 : y;
        return copy;
    }

    function luminance(colour: color): real {
        return 0.2126 * colour.r + 0.7152 * colour.g + 0.0722 * colour.b;
    }
}
