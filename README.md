# Fcitx5 Indicator

An indicator that shows the active Fcitx5 input method as a Material Symbols language icon in DankBar.

## Requirements

* Dux Shell (DMS) ≥ 2.0
* `fcitx5` (provides `fcitx5-remote`)
* `busctl` (systemd)

The plugin runs `StartupCheck.qml` before it is enabled and refuses to load if either tool is missing.

## Installation

Copy or symlink this directory into the DMS plugin directory:

```bash
# create a symlink
ln -s "$PWD" ~/.config/dms/plugins/fcitx5Indicator
# or just
cp "$PWD" ~/.config/dms/plugins/fcitx5Indicator
```

Then:

1. Settings → Plugins → Scan for Plugins
2. Enable **Fcitx5 Indicator** and change the icon size if you want
3. Settings → DankBar → Add widget → **Fcitx5 Indicator** 

## How it works

The widget polls `fcitx5-remote` for the active/inactive state and `org.fcitx.Fcitx.Controller1.CurrentInputMethodInfo` for the current input method's unique name and language code.

### Icon mapping

| Detected | Icon |
| --- | --- |
| Chinese pinyin / shuangpin | `language_chinese_pinyin` |
| Chinese wubi | `language_chinese_wubi` |
| Chinese cangjie | `language_chinese_cangjie` |
| Chinese dayi | `language_chinese_dayi` |
| Chinese not detected | `language_pinyin` |
| array | `language_chinese_array` |
| quick | `language_chinese_quick` |
| English (US) | `language_us` |
| English (US Dvorak) | `language_us_dvorak` |
| English (US Colemak) | `language_us_colemak` |
| English (UK) | `language_gb_english` |
| English (international layout) | `language_international` |
| Spanish | `language_spanish` |
| French | `language_french` |
| Japanese | `language_japanese_kana` |
| Korean | `language_korean_latin` |
| Any other known language | `language_international` |
| Unknown / empty | `language` |

## Settings

| Key | Default | Description |
| --- | --- | --- |
| `iconScale` | `100` | Icon size as a percentage of the bar's default icon size (50–200) |

## Hiding Fcitx's tray icon

Add `DMS_HIDE_TRAYIDS=Fcitx` to your environment variables.

The variable is **overwritten** , not appended: to hide several items use
`DMS_HIDE_TRAYIDS=Fcitx,OtherId` .

[Reference](https://duxlabs.dev/docs/dms/advanced-configuration#dms_hide_trayids)

## License

MIT — see [LICENSE](LICENSE).
