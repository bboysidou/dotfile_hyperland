pragma Singleton

import Quickshell
import qs.core.config
import qs.core.enums

Singleton {
    id: root

    readonly property var specs: {
        const c = Appearance.anim.curves;
        const d = Appearance.anim.durations;
        const specs = {};
        specs[AnimType.standardSmall] = {
            duration: d.small,
            curve: c.standard
        };
        specs[AnimType.standard] = {
            duration: d.normal,
            curve: c.standard
        };
        specs[AnimType.standardLarge] = {
            duration: d.large,
            curve: c.standard
        };
        specs[AnimType.standardExtraLarge] = {
            duration: d.extraLarge,
            curve: c.standard
        };
        specs[AnimType.emphasizedSmall] = {
            duration: d.small,
            curve: c.emphasized
        };
        specs[AnimType.emphasized] = {
            duration: d.normal,
            curve: c.emphasized
        };
        specs[AnimType.emphasizedLarge] = {
            duration: d.large,
            curve: c.emphasized
        };
        specs[AnimType.emphasizedExtraLarge] = {
            duration: d.extraLarge,
            curve: c.emphasized
        };
        specs[AnimType.fastSpatial] = {
            duration: d.fastSpatial,
            curve: c.fastSpatial
        };
        specs[AnimType.defaultSpatial] = {
            duration: d.defaultSpatial,
            curve: c.defaultSpatial
        };
        specs[AnimType.slowSpatial] = {
            duration: d.slowSpatial,
            curve: c.slowSpatial
        };
        specs[AnimType.fastEffects] = {
            duration: d.fastEffects,
            curve: c.fastEffects
        };
        specs[AnimType.defaultEffects] = {
            duration: d.defaultEffects,
            curve: c.defaultEffects
        };
        specs[AnimType.slowEffects] = {
            duration: d.slowEffects,
            curve: c.slowEffects
        };
        return specs;
    }

    function specFor(type: string): var {
        return root.specs[type] ?? root.specs[AnimType.standard];
    }

    function durationFor(type: string): int {
        return root.specFor(type).duration;
    }

    function curveFor(type: string): var {
        return root.specFor(type).curve;
    }
}
