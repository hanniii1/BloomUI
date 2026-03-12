local BloomUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourname/BloomUI/main/main.lua"))()

local window = BloomUI:CreateWindow({
    Title = "BloomUI",
    Subtitle = "A script hub shell that actually feels expensive",
    ToggleKey = Enum.KeyCode.RightControl,
})

local dashboard = window:CreateTab({
    Title = "Dashboard",
    Desc = "Core actions, control toggles, and locked premium states.",
    Icon = "DB",
})

dashboard:Section("Core")

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

local lockedButton = dashboard:Button({
    Title = "Premium Raid",
    Desc = "A showcase of the built-in lock layer.",
    Badge = "PLUS",
    Locked = true,
    LockedTitle = "Premium",
    Callback = function()
        print("This only fires after unlock.")
    end,
})

dashboard:Toggle({
    Title = "Auto Collect",
    Desc = "Scoops drops and rewards automatically.",
    Flag = "AutoCollect",
    Value = true,
    Callback = function(state)
        print("Auto Collect:", state)
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

dashboard:Spacer(6)
dashboard:Section("Unlock Flow")

dashboard:Button({
    Title = "Grant Premium",
    Desc = "Unlock the premium card to show the transition.",
    Badge = "SYNC",
    Callback = function()
        lockedButton:Unlock()
        window:Notify({
            Title = "Unlocked",
            Content = "Premium Raid is now available.",
            Color = window.Theme.Positive,
        })
    end,
})

local visuals = window:CreateTab({
    Title = "Visuals",
    Desc = "Second page so the tab system is visible immediately.",
    Icon = "FX",
})

visuals:Section("Coming Soon")
visuals:Button({
    Title = "Theme Editor",
    Desc = "Swap the accent or build your own style pack next.",
    Badge = "EDIT",
    Callback = function()
        window:Notify({
            Title = "BloomUI",
            Content = "Theme editing is easy to add on top of this base.",
        })
    end,
})

window:Notify({
    Title = "BloomUI Loaded",
    Content = "RightControl toggles the window. The premium card starts locked.",
})
