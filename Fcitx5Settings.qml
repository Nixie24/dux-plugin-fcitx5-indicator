import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root

    pluginId: "fcitx5Indicator"

    StyledText {
        width: parent.width
        text: I18n.trFor("fcitx5Indicator", "Fcitx5 Indicator")
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    SliderSetting {
        settingKey: "iconScale"
        label: I18n.trFor("fcitx5Indicator", "Icon size")
        description: I18n.trFor("fcitx5Indicator", "Scale the language icon relative to the bar's default icon size.")
        defaultValue: 100
        minimum: 50
        maximum: 200
        unit: "%"
    }
}
