local BloomUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/hanniii1/BloomUI/refs/heads/main/main.lua"))()

local window = BloomUI:CreateWindow({
    Title = "BloomUI",
    Subtitle = "Script hub presentation with real control depth",
    ToggleKey = Enum.KeyCode.RightControl,
    ConfigFolder = "BloomUIConfigs",
})

local dashboard = window:CreateTab({
    Title = "Dashboard",
    Desc = "Core actions, premium locks, and the wow-factor controls.",
    Icon = "DB",
})

dashboard:Section("Launch")

dashboard:Button({
    Title = "Launch Farm",
    Desc = "Boots the route planner and combat loop.",
    Badge = "PLAY",
    Callback = function()
        window:Notify({
            Title = "Farm Started",
            Content = "Your route planner is now live.",
        })
    end,
})

local lockedRaid = dashboard:Button({
    Title = "Premium Raid",
    Desc = "Starts locked to show the overlay treatment.",
    Badge = "PLUS",
    Locked = true,
    LockedTitle = "Premium",
    Callback = function()
        window:Notify({
            Title = "Raid Ready",
            Content = "The premium route launched successfully.",
            Color = window.Theme.Positive,
        })
    end,
})

dashboard:Button({
    Title = "Grant Premium",
    Desc = "Unlocks the premium card to show the transition.",
    Badge = "SYNC",
    Callback = function()
        lockedRaid:Unlock()
        window:Notify({
            Title = "Unlocked",
            Content = "Premium Raid is now available.",
            Color = window.Theme.Positive,
        })
    end,
})

dashboard:Spacer(6)
dashboard:Section("Automation")

dashboard:Toggle({
    Title = "Auto Collect",
    Desc = "Scoops drops and reward orbs automatically.",
    Flag = "AutoCollect",
    Value = true,
    Callback = function(state)
        print("Auto Collect:", state)
    end,
})

dashboard:Slider({
    Title = "Walk Speed",
    Desc = "Tune the movement speed with drag input.",
    Flag = "WalkSpeed",
    Min = 16,
    Max = 120,
    Step = 1,
    Value = 32,
    Suffix = " ws",
    Callback = function(value)
        print("Walk Speed:", value)
    end,
})

dashboard:Dropdown({
    Title = "Target Area",
    Desc = "Choose the route destination.",
    Flag = "TargetArea",
    Values = {"Forest", "Temple", "Cavern", "Sky Raid", "Void Gate"},
    Value = "Temple",
    Callback = function(value)
        print("Target Area:", value)
    end,
})

dashboard:Input({
    Title = "Webhook",
    Desc = "Receive updates directly in Discord.",
    Placeholder = "https://discord.com/api/webhooks/...",
    Flag = "Webhook",
    Callback = function(value)
        print("Webhook:", value)
    end,
})

local system = window:CreateTab({
    Title = "System",
    Desc = "Persistence, binds, and a more complete script-hub workflow.",
    Icon = "SY",
})

system:Section("Controls")

system:Keybind({
    Title = "Panic Key",
    Desc = "Press the bound key to trigger your emergency routine.",
    Flag = "PanicKey",
    Value = Enum.KeyCode.P,
    Callback = function(keyName)
        window:Notify({
            Title = "Panic Key",
            Content = "Triggered with " .. tostring(keyName),
            Color = window.Theme.Danger,
        })
    end,
})

system:Dropdown({
    Title = "Profile",
    Desc = "Swap between saved play styles.",
    Flag = "Profile",
    Values = {"Legit", "Aggressive", "Stealth", "Bossing"},
    Value = "Legit",
    Callback = function(value)
        print("Profile:", value)
    end,
})

system:Spacer(6)
system:Section("Config")

system:Button({
    Title = "Save Config",
    Desc = "Writes the current flags to a JSON file.",
    Badge = "SAVE",
    Callback = function()
        local ok, result = window:SaveConfig("demo")
        window:Notify({
            Title = ok and "Config Saved" or "Save Failed",
            Content = ok and ("Saved to " .. tostring(result)) or tostring(result),
            Color = ok and window.Theme.Positive or window.Theme.Danger,
        })
    end,
})

system:Button({
    Title = "Load Config",
    Desc = "Loads the JSON file back into the live controls.",
    Badge = "LOAD",
    Callback = function()
        local ok, result = window:LoadConfig("demo")
        window:Notify({
            Title = ok and "Config Loaded" or "Load Failed",
            Content = ok and "Flags restored from disk." or tostring(result),
            Color = ok and window.Theme.Positive or window.Theme.Danger,
        })
    end,
})

window:Notify({
    Title = "BloomUI Loaded",
    Content = "RightControl toggles the window. The demo now covers locks, slider, dropdown, keybind, and config save/load.",
})
