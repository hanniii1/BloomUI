# BloomUI

BloomUI is an open-source Roblox UI library designed for script hubs that want a sharper first impression than the usual generic panel-and-buttons look.

This first version focuses on the pieces that matter most in day-to-day hub usage:

- a premium-feeling window shell with ambient glow and layered surfaces
- tab navigation that reads clearly at a glance
- polished card components for buttons, toggles, and inputs
- a built-in lock state with `:Lock()` and `:Unlock()`
- lightweight notifications
- a single-file `main.lua` that is easy to host from GitHub

## Why it feels different

WindUI gets a lot right: clean API shape, lockable elements, and script-hub-friendly ergonomics. BloomUI keeps those good ideas, then pushes harder on visual hierarchy, materials, and state feedback so the UI feels more custom and less like a public library drop-in.

The visual direction here is:

- warmer bloom accent instead of flat neon
- deeper layered panels with subtle gradients
- stronger card separation and top-line highlights
- a floating reopen chip when minimized
- lock overlays that feel intentional instead of simply disabled

## Current API

### Create the library

```lua
local BloomUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourname/BloomUI/main/main.lua"))()
```

### Create a window

```lua
local window = BloomUI:CreateWindow({
    Title = "BloomUI",
    Subtitle = "A hub shell that feels premium",
    ToggleKey = Enum.KeyCode.RightControl,
})
```

Window options:

- `Title`
- `Subtitle`
- `Size`
- `ToggleKey`
- `Theme`

### Create tabs

```lua
local tab = window:CreateTab({
    Title = "Dashboard",
    Desc = "Primary actions and controls",
    Icon = "DB",
})
```

### Components

Button:

```lua
tab:Button({
    Title = "Launch Farm",
    Desc = "Starts the automation flow",
    Badge = "PLAY",
    Callback = function()
        print("clicked")
    end,
})
```

Toggle:

```lua
tab:Toggle({
    Title = "Auto Collect",
    Desc = "Collect nearby drops",
    Flag = "AutoCollect",
    Value = true,
    Callback = function(state)
        print(state)
    end,
})
```

Input:

```lua
tab:Input({
    Title = "Webhook",
    Desc = "Notification endpoint",
    Placeholder = "https://...",
    Flag = "Webhook",
    Callback = function(value)
        print(value)
    end,
})
```

Sections and spacing:

```lua
tab:Section("Premium")
tab:Spacer(8)
```

### Locked state

Create locked:

```lua
local premium = tab:Button({
    Title = "Premium Raid",
    Desc = "Only available to premium users",
    Locked = true,
    LockedTitle = "Premium",
})
```

Lock and unlock later:

```lua
premium:Lock("Premium")
premium:Unlock()
```

### Notifications

```lua
window:Notify({
    Title = "BloomUI",
    Content = "Ready to go",
    Duration = 4,
})
```

### Flags

```lua
print(window:GetValue("AutoCollect"))
window:SetValue("AutoCollect", false)
```

## Themes

BloomUI ships with a default `Bloom` theme and supports custom themes:

```lua
BloomUI:AddTheme("Solar", {
    Accent = Color3.fromRGB(255, 184, 76),
    AccentSoft = Color3.fromRGB(255, 218, 159),
    Background = Color3.fromRGB(10, 12, 18),
    Panel = Color3.fromRGB(20, 22, 31),
    Surface = Color3.fromRGB(28, 31, 43),
    SurfaceAlt = Color3.fromRGB(21, 24, 35),
    Overlay = Color3.fromRGB(6, 8, 12),
    Outline = Color3.fromRGB(58, 64, 82),
    OutlineStrong = Color3.fromRGB(86, 94, 118),
    Text = Color3.fromRGB(248, 248, 252),
    Subtext = Color3.fromRGB(160, 168, 187),
    Positive = Color3.fromRGB(107, 214, 157),
    Danger = Color3.fromRGB(255, 104, 104),
})
```

Then:

```lua
local window = BloomUI:CreateWindow({
    Theme = "Solar",
})
```

## Repo layout

```text
BloomUI/
  main.lua
  example.lua
  README.md
  LICENSE
  .gitignore
```

## Suggested next upgrades

- sliders, dropdowns, and keybinds
- save manager / config persistence
- richer mobile layout rules
- icon pack support
- modal system and command palette

## License

MIT. See [LICENSE](./LICENSE).
