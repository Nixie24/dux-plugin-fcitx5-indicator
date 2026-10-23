import QtQuick
import Quickshell.Services.SystemTray
import qs.Common
import qs.Services
import qs.DCommon.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    pluginId: "fcitx5Indicator"
    pluginService: PluginService

    readonly property real iconScale: {
        const raw = pluginData.iconScale;
        if (raw === undefined || raw === null || raw === "")
            return 1.0;
        const percent = Number(raw);
        if (!isFinite(percent))
            return 1.0;
        return Math.max(0.5, Math.min(2.0, percent / 100));
    }

    // Hide the whole widget when fcitx5 is not running (exit 0 = visible).
    visibilityCommand: "fcitx5-remote --check"
    visibilityInterval: 10

    // 0 = fcitx exited, 1 = inactive, 2 = active
    property int fcitxState: 1
    property string imUnique: ""
    property string imLang: ""

    readonly property bool active: fcitxState === 2
    readonly property color stateColor: active ? Theme.primary : Theme.surfaceVariantText
    readonly property int glyphSize: Theme.barIconSize(barThickness, -4, barConfig?.maximizeWidgetIcons, (barConfig?.iconScale ?? 1.0) * iconScale)

    readonly property var languageIcons: ({
            "zh": {
                "default": "language_pinyin",
                "wubi": "language_chinese_wubi",
                "cangjie": "language_chinese_cangjie",
                "dayi": "language_chinese_dayi",
                "array": "language_chinese_array",
                "quick": "language_chinese_quick",
                "shuangpin": "language_chinese_pinyin",
                "pinyin": "language_chinese_pinyin"
            },
            "en": {
                "default": "language_us",
                "keyboard-gb": "language_gb_english",
                "dvorak": "language_us_dvorak",
                "colemak": "language_us_colemak",
                "intl": "language_international"
            },
            "es": {
                "default": "language_spanish"
            },
            "fr": {
                "default": "language_french"
            },
            "ja": {
                "default": "language_japanese_kana"
            },
            "ko": {
                "default": "language_korean_latin"
            }
        })

    readonly property string iconName: {
        const unique = (imUnique || "").toLowerCase();
        const lang = (imLang || "").toLowerCase().split(/[-_]/)[0];

        if (!lang)
            return "language";

        const icons = languageIcons[lang];
        if (!icons)
            return "language_international";

        for (const engine in icons) {
            if (engine !== "default" && unique.indexOf(engine) !== -1)
                return icons[engine];
        }

        return icons["default"];
    }

    property var trayItem: null

    function bindTrayItem() {
        const items = SystemTray.items.values;
        for (let i = 0; i < items.length; i++) {
            const item = items[i];
            if (item && item.id === "Fcitx") {
                if (item !== root.trayItem)
                    root.trayItem = item;
                return true;
            }
        }
        root.trayItem = null;
        return false;
    }

    Connections {
        target: SystemTray.items
        function onValuesChanged() {
            root.bindTrayItem();
        }
    }

    Connections {
        target: root.trayItem
        ignoreUnknownSignals: true
        function onTooltipTitleChanged() {
            root.poll();
        }
        function onIconChanged() {
            root.poll();
        }
        function onStatusChanged() {
            root.poll();
        }
    }

    // Retry until the tray item registers
    Timer {
        interval: 1000
        repeat: true
        running: root.trayItem === null
        onTriggered: root.bindTrayItem()
    }

    Timer {
        interval: root.trayItem ? 3000 : 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.poll()
    }

    Component.onCompleted: root.bindTrayItem()

    function poll() {
        Proc.runCommand("fcitx5Indicator.pollState", ["fcitx5-remote"], (stdout, exitCode) => root.applyState(stdout, exitCode), 40, 3000, root);

        Proc.runCommand("fcitx5Indicator.pollInputMethod", ["busctl", "--user", "--json=short", "call", "org.fcitx.Fcitx5", "/controller", "org.fcitx.Fcitx.Controller1", "CurrentInputMethodInfo"], (stdout, exitCode) => root.applyInputMethod(stdout, exitCode), 40, 3000, root);
    }

    function applyState(stdout, exitCode) {
        if (exitCode !== 0 || !stdout) {
            root.fcitxState = 0;
            return;
        }
        const state = parseInt(stdout.trim());
        if (!isNaN(state))
            root.fcitxState = state;
    }

    function applyInputMethod(stdout, exitCode) {
        if (exitCode !== 0 || !stdout)
            return;
        try {
            // CurrentInputMethodInfo is a positional D-Bus tuple:
            // (uniqueName, name, nativeName, icon, label, languageCode, addon, configurable, layout, properties).
            // from https://github.com/fcitx/fcitx5/blob/master/src/modules/dbus/dbusmodule.cpp#L724-L733
            const im = JSON.parse(stdout).data;
            root.imUnique = im[0] || "";
            root.imLang = im[5] || "";
        } catch (e) {
            // Keep the last known input method if the payload is malformed.
        }
    }

    function toggleActive() {
        Proc.runCommand("fcitx5Indicator.toggle", ["fcitx5-remote", "-t"], () => root.poll(), 40, 3000, root);
    }

    pillClickAction: () => root.toggleActive()

    property Component indicatorPill: Component {
        DIcon {
            name: root.iconName
            size: root.glyphSize
            color: root.stateColor
        }
    }

    horizontalBarPill: indicatorPill
    verticalBarPill: indicatorPill
}
