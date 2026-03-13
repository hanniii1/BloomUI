local BloomUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/hanniii1/BloomUI/main/main.lua"))()

local window = BloomUI:CreateWindow({
    Title = "BloomUI",
    Subtitle = "Premium script-hub UI.",
    ToggleKey = Enum.KeyCode.RightControl,
    ConfigFolder = "BloomUIConfigs",
})

local overview = window:CreateTab({
    Title = "Overview",
    Desc = "First-look actions.",
    Icon = "OV",
})

overview:Hero({
    Title = "Cleaner, sharper hub UI",
    Desc = "Built for dense hubs with calmer spacing and stronger hierarchy.",
    Tag = "OPEN SOURCE",
    Stats = {"Locks", "Configs", "Keybinds"},
})

overview:Section("Launch")

overview:Button({
    Title = "Launch Route",
    Desc = "Start the default route.",
    Badge = "PLAY",
    Callback = function()
        window:Notify({
            Title = "Route Started",
            Content = "Default route is now active.",
        })
    end,
})

local premiumRaid = overview:Button({
    Title = "Premium Raid",
    Desc = "Locked high-value route.",
    Badge = "PLUS",
    Locked = true,
    LockedTitle = "Premium",
    Callback = function()
        window:Notify({
            Title = "Premium Raid",
            Content = "Premium route launched.",
            Color = window.Theme.Positive,
        })
    end,
})

overview:Button({
    Title = "Unlock Premium",
    Desc = "Reveal the locked action.",
    Badge = "SYNC",
    Callback = function()
        premiumRaid:Unlock()
        window:Notify({
            Title = "Premium Unlocked",
            Content = "Locked content is now available.",
            Color = window.Theme.Positive,
        })
    end,
})

overview:Section("Live Controls")

overview:Toggle({
    Title = "Auto Collect",
    Desc = "Pick up nearby drops.",
    Flag = "AutoCollect",
    Value = true,
})

overview:Slider({
    Title = "Walk Speed",
    Desc = "Tune movement speed.",
    Flag = "WalkSpeed",
    Min = 16,
    Max = 120,
    Step = 1,
    Value = 32,
    Suffix = " ws",
})

overview:Dropdown({
    Title = "Target Zone",
    Desc = "Choose your route.",
    Flag = "TargetZone",
    Values = {"Forest", "Temple", "Cavern", "Sky", "Vault"},
    Value = "Temple",
})

local automation = window:CreateTab({
    Title = "Automation",
    Desc = "Profiles and binds.",
    Icon = "AU",
})

automation:Section("Profile")

automation:Dropdown({
    Title = "Profile",
    Desc = "Swap your preset.",
    Flag = "Profile",
    Values = {"Legit", "Stealth", "Aggressive", "Boss"},
    Value = "Stealth",
})

automation:Input({
    Title = "Webhook",
    Desc = "Session alerts.",
    Placeholder = "discord webhook...",
    Flag = "Webhook",
})

automation:Keybind({
    Title = "Panic Key",
    Desc = "Emergency stop bind.",
    Flag = "PanicKey",
    Value = Enum.KeyCode.P,
    Changed = function(keyName)
        window:Notify({
            Title = "Keybind Updated",
            Content = "Panic Key: " .. tostring(keyName ~= "" and keyName or "NONE"),
        })
    end,
    Callback = function(keyName)
        window:Notify({
            Title = "Panic Triggered",
            Content = "Pressed " .. tostring(keyName),
            Color = window.Theme.Danger,
        })
    end,
})

automation:Button({
    Title = "Test Notification",
    Desc = "Preview alert styling.",
    Badge = "PING",
    Callback = function()
        window:Notify({
            Title = "Automation",
            Content = "Notification preview sent.",
        })
    end,
})

local settings = window:CreateTab({
    Title = "Settings",
    Desc = "Persistence and tools.",
    Icon = "ST",
})

settings:Section("Config")

settings:Button({
    Title = "Save Config",
    Desc = "Write flags to JSON.",
    Badge = "SAVE",
    Callback = function()
        local ok, result = window:SaveConfig("showcase")
        window:Notify({
            Title = ok and "Config Saved" or "Save Failed",
            Content = ok and ("Saved to " .. tostring(result)) or tostring(result),
            Color = ok and window.Theme.Positive or window.Theme.Danger,
        })
    end,
})

settings:Button({
    Title = "Load Config",
    Desc = "Restore saved state.",
    Badge = "LOAD",
    Callback = function()
        local ok, result = window:LoadConfig("showcase")
        window:Notify({
            Title = ok and "Config Loaded" or "Load Failed",
            Content = ok and "State restored from disk." or tostring(result),
            Color = ok and window.Theme.Positive or window.Theme.Danger,
        })
    end,
})

settings:Button({
    Title = "Show Summary",
    Desc = "Preview current values.",
    Badge = "INFO",
    Callback = function()
        local profile = tostring(window:GetValue("Profile") or "Unknown")
        local zone = tostring(window:GetValue("TargetZone") or "Unknown")
        local speed = tostring(window:GetValue("WalkSpeed") or "?")
        window:Notify({
            Title = "Current State",
            Content = profile .. " | " .. zone .. " | " .. speed .. " ws",
        })
    end,
})

window:Notify({
    Title = "BloomUI Loaded",
    Content = "Press RightControl to toggle the window.",
})
