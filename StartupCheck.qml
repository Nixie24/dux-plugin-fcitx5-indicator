import QtQuick
import qs.Common

QtObject {
    function check(done) {
        Proc.runCommand("fcitx5Indicator.depCheck", ["sh", "-c", "command -v fcitx5-remote && command -v busctl"], (stdout, exitCode) => {
            if (exitCode === 0) {
                done(null);
                return;
            }
            done({
                "title": I18n.trFor("fcitx5Indicator", "Missing fcitx5-remote or busctl"),
                "details": I18n.trFor("fcitx5Indicator", "This plugin reads the input method state through fcitx5-remote and busctl.\n\nInstall fcitx5 (which provides fcitx5-remote) and systemd (which provides busctl), make sure they are on PATH, then enable the plugin again.")
            });
        }, 0, 4000, null);
    }
}
