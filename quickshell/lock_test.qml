import QtQuick
import Quickshell
import Quickshell.Services.Pam
import qs.core.config
import qs.services

ShellRoot {
    id: harness

    property int passed: 0
    property int failed: 0

    function check(name: string, ok: bool): void {
        if (ok) {
            harness.passed += 1;
            console.log("PASS", name);
        } else {
            harness.failed += 1;
            console.log("FAIL", name);
        }
    }

    Component.onCompleted: {
        const legacy = Lock.parse("3");
        harness.check("legacy int state parses", legacy.failures === 3 && legacy.locked === false);

        const modern = Lock.parse(JSON.stringify({
            failures: 5,
            lastFailure: 111,
            cooldownUntil: 222,
            locked: true
        }));
        harness.check("json state parses", modern.failures === 5 && modern.lastFailure === 111 && modern.cooldownUntil === 222 && modern.locked === true);

        harness.check("garbage state is safe", Lock.parse("{broken").failures === 0);
        harness.check("empty state is safe", Lock.parse("").failures === 0);

        Lock.failures = 3;
        Lock.tick();
        Lock.penalise();
        harness.check("3 failures arm cooldown", Lock.cooldown > 0 && Lock.cooldown <= Appearance.lock.faillockCooldown);

        Lock.buffer = "";
        Lock.append("x");
        harness.check("cooldown blocks input", Lock.buffer === "");

        Lock.failures = 9;
        Lock.tick();
        Lock.penalise();
        harness.check("cooldown scales with failures", Lock.cooldown > Appearance.lock.faillockCooldown);

        Lock.failures = 60;
        Lock.tick();
        Lock.penalise();
        harness.check("cooldown is capped", Lock.cooldown <= Appearance.lock.faillockCooldownMax);

        Lock.cooldownUntil = Date.now() - 1000;
        Lock.tick();
        harness.check("expired cooldown clears", Lock.cooldown === 0 && !Lock.coolingDown);

        Lock.buffer = "";
        Lock.append("y");
        harness.check("expired cooldown unblocks input", Lock.buffer === "y");

        Lock.failures = 2;
        Lock.lastFailure = Date.now() - Appearance.lock.faillockWindow - 1000;
        Lock.finish(PamResult.Failed);
        harness.check("stale failures reset in new window", Lock.failures === 1);

        harness.check("failure blocks input", Lock.recovering);
        Lock.buffer = "";
        Lock.append("z");
        harness.check("recovering blocks input", Lock.buffer === "");

        backstop.start();
    }

    Timer {
        id: backstop

        interval: Appearance.lock.recoverTimeout + Appearance.lock.faillockTick

        onTriggered: {
            harness.check("recovery backstop clears recovering", !Lock.recovering);

            Lock.buffer = "";
            Lock.append("w");
            harness.check("input works after backstop", Lock.buffer === "w");

            Lock.show();
            harness.check("show marks locked", Lock.locked);

            persisted.start();
        }
    }

    Timer {
        id: persisted

        interval: Appearance.lock.faillockTick

        onTriggered: {
            console.log("RESULT", harness.passed, "passed,", harness.failed, "failed");
            Quickshell.execDetached(["true"]);
            Qt.exit(harness.failed === 0 ? 0 : 1);
        }
    }
}
