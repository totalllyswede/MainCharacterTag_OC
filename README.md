# MainCharacterTag

![Version](https://img.shields.io/badge/version-1.1-blue) ![Interface](https://img.shields.io/badge/interface-1.12.1-yellow)

A lightweight World of Warcraft addon for vanilla (1.12.1) that automatically tags your guild chat messages with your main character's name when playing on alts.

## What it does

When you chat in **Guild** or **Guild Officer** chat on an alt, your messages are automatically prefixed with your main's name so guildmates always know who they're talking to.

**Example:** Playing on your alt `Shadowpoke` with main set to `Thunderbash`:
> **(Thunderbash): Hey all, it's me just on my alt!**

Messages sent from your main character are unaffected.

## Installation

1. Download and unzip the addon
2. Place the `MainCharacterTag` folder in:
   ```
   World of Warcraft/Interface/AddOns/
   ```
3. Restart WoW or reload your UI (`/reload`)
4. Enable **MainCharacterTag** on the character select screen

## Usage

Type `/mct` or `/mainchartag` to open the options window.

Enter your main character's name and click **Save**. That's it.

## Options

| Command | Description |
|---|---|
| `/mct` | Toggle the options window |
| `/mainchartag` | Toggle the options window (alternate) |

## Notes

- Only affects **Guild** (`/g`) and **Guild Officer** (`/o`) chat
- Your main's name is saved between sessions per character
- Works on any number of alts
- No performance impact — only runs when you send a guild message

## Changelog

### 1.1
- Fixed an issue where logging in on an alt could trigger unintended chat messages from other addons during the login sequence

### 1.0
- Initial release
