local BloomUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/hanniii1/BloomUI/main/main.lua"))()

local window = BloomUI:CreateWindow({
    Title = "BloomUI",
    Subtitle = "Premium script-hub language with cleaner density and bigger type.",
    ToggleKey = Enum.KeyCode.RightControl,
    ConfigFolder = "BloomUIConfigs",
})

local overview = window:CreateTab({
    Title = "Overview",
    Desc = "A stronger first impression with premium states and hub-focused controls.",
    Icon = "OV",
})

overview:Hero({
    Title = "BloomUI Hybrid Showcase",
    Desc = "A calmer WindUI-style structure mixed with the branded ambition and premium feel of Nebula-inspired hubs.",
    Tag = "OPEN SOURCE",
    Stats = {"Smooth States", "Larger Type", "Premium Locks"},
})

overview:Section("Quick Actions")

overview:Button({
    Title = "Launch Route",
    Desc = "Start the default farming route with your current profile.",
    Badge = "PLAY",
    Callback = function()
        window:Notify({
            Title = "Route Started",
            Content = "BloomUI fired the launch action cleanly.",
        })
    end,
})

local premiumRaid = overview:Button({
    Title = "Premium Raid",
    Desc = "This card starts locked to show the premium overlay state.",
    Badge = "PLUS",
    Locked = true,
    LockedTitle = "Premium",
    Callback = function()
        window:Notify({
            Title = "Premium Raid",
            Content = "Premium route launched successfully.",
            Color = window.Theme.Positive,
        })
    end,
})

overview:Button({
    Title = "Unlock Premium",
    Desc = "Reveal the locked card and show the transition behavior.",
    Badge = "SYNC",
    Callback = function()
        premiumRaid:Unlock()
        window:Notify({
            Title = "Premium Unlocked",
            Content = "The locked premium action is now live.",
            Color = window.Theme.Positive,
        })
    end,
})

overview:Section("Live Controls")

overview:Toggle({
    Title = "Auto Collect",
    Desc = "Scoops nearby drops and reward orbs automatically.",
    Flag = "AutoCollect",
    Value = true,
    Callback = function(state)
        print("Auto Collect:", state)
    end,
})

overview:Slider({
    Title = "Walk Speed",
    Desc = "Tune movement speed with drag input.",
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

overview:Dropdown({
    Title = "Target Zone",
    Desc = "Choose the active route destination.",
    Flag = "TargetZone",
    Values = {"Forest", "Temple", "Cavern", "Sky Raid", "Void Gate"},
    Value = "Temple",
    Callback = function(value)
        print("Target Zone:", value)
    end,
})

local automation = window:CreateTab({
    Title = "Automation",
    Desc = "The denser hub workflow: profile, input, bind, and config handling.",
    Icon = "AU",
})

automation:Hero({
    Title = "Configurable Hub Flow",
    Desc = "Use inputs, dropdowns, and keybinds together so BloomUI feels like a full suite, not just a button list.",
    Tag = "WORKFLOW",
    Stats = {"Configs", "Profiles", "Keybinds"},
})

automation:Section("Profiles")

automation:Dropdown({
    Title = "Profile",
    Desc = "Swap between saved play styles.",
    Flag = "Profile",
    Values = {"Legit", "Aggressive", "Stealth", "Bossing"},
    Value = "Legit",
    Callback = function(value)
        print("Profile:", value)
    end,
})

automation:Input({
    Title = "Webhook",
    Desc = "Send session updates directly to Discord.",
    Placeholder = "https://discord.com/api/webhooks/...",
    Flag = "Webhook",
    Callback = function(value)
        print("Webhook:", value)
    end,
})

automation:Keybind({
    Title = "Panic Key",
    Desc = "Trigger your emergency routine with a bound key.",
    Flag = "PanicKey",
    Value = Enum.KeyCode.P,
    Changed = function(keyName)
        window:Notify({
            Title = "Keybind Updated",
            Content = "Panic Key is now bound to " .. tostring(keyName ~= "" and keyName or "NONE"),
        })
    end,
    Callback = function(keyName)
        window:Notify({
            Title = "Panic Key Triggered",
            Content = "Triggered with " .. tostring(keyName),
            Color = window.Theme.Danger,
        })
    end,
})

local settings = window:CreateTab({
    Title = "Settings",
    Desc = "Persistence and utility actions for a real script-hub loop.",
    Icon = "ST",
})

settings:Hero({
    Title = "Persistence Layer",
    Desc = "Save and load flags so the library feels practical for real executor usage, not just pretty on first run.",
    Tag = "UTILITY",
    Stats = {"Save JSON", "Load State", "Reusable"},
})

settings:Section("Config")

settings:Button({
    Title = "Save Config",
    Desc = "Writes the current flags to a JSON file.",
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
    Desc = "Loads the saved JSON file back into the live controls.",
    Badge = "LOAD",
    Callback = function()
        local ok, result = window:LoadConfig("showcase")
        window:Notify({
            Title = ok and "Config Loaded" or "Load Failed",
            Content = ok and "Flags restored from disk." or tostring(result),
            Color = ok and window.Theme.Positive or window.Theme.Danger,
        })
    end,
})

settings:Button({
    Title = "Show Summary",
    Desc = "Preview a few live values from the showcase state.",
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
    Content = "RightControl toggles the window. The showcase now opens with hero panels, bigger text, and a cleaner hub flow.",
})
