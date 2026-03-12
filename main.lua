local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local BloomUI = {
    Themes = {},
}

local DEFAULT_THEME = {
    Accent = Color3.fromRGB(255, 132, 76),
    AccentSoft = Color3.fromRGB(255, 188, 140),
    Background = Color3.fromRGB(8, 10, 16),
    Panel = Color3.fromRGB(17, 20, 29),
    Surface = Color3.fromRGB(26, 29, 41),
    SurfaceAlt = Color3.fromRGB(19, 22, 33),
    Overlay = Color3.fromRGB(6, 7, 12),
    Outline = Color3.fromRGB(53, 58, 74),
    OutlineStrong = Color3.fromRGB(82, 90, 112),
    Text = Color3.fromRGB(246, 247, 251),
    Subtext = Color3.fromRGB(160, 167, 186),
    Positive = Color3.fromRGB(99, 214, 153),
    Danger = Color3.fromRGB(255, 104, 104),
}

local DEFAULT_WINDOW = {
    Title = "BloomUI",
    Subtitle = "Luxury shell for script hubs",
    Size = UDim2.fromOffset(760, 500),
    ToggleKey = Enum.KeyCode.RightControl,
    Theme = nil,
}

local function cloneTheme(theme)
    local result = {}
    for key, value in pairs(DEFAULT_THEME) do
        result[key] = value
    end
    if theme then
        for key, value in pairs(theme) do
            result[key] = value
        end
    end
    return result
end

function BloomUI:AddTheme(name, theme)
    if type(name) == "table" then
        theme = name
        name = theme and theme.Name
    end

    assert(type(name) == "string" and name ~= "", "BloomUI:AddTheme expected a theme name")
    assert(type(theme) == "table", "BloomUI:AddTheme expected a theme table")

    self.Themes[name] = cloneTheme(theme)
    return self.Themes[name]
end

local function tween(object, info, props)
    local t = TweenService:Create(object, info, props)
    t:Play()
    return t
end

local function create(className, props)
    local object = Instance.new(className)
    if props then
        for key, value in pairs(props) do
            object[key] = value
        end
    end
    return object
end

local function corner(parent, radius)
    local ui = create("UICorner", {
        CornerRadius = UDim.new(0, radius),
    })
    ui.Parent = parent
    return ui
end

local function stroke(parent, color, transparency)
    local ui = create("UIStroke", {
        Color = color,
        Thickness = 1,
        Transparency = transparency or 0,
    })
    ui.Parent = parent
    return ui
end

local function gradient(parent, colorA, colorB, rotation)
    local ui = create("UIGradient", {
        Rotation = rotation or 90,
        Color = ColorSequence.new(colorA, colorB),
    })
    ui.Parent = parent
    return ui
end

local function padding(parent, left, right, top, bottom)
    local ui = create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
    })
    ui.Parent = parent
    return ui
end

local function bindHover(button, onEnter, onLeave)
    button.MouseEnter:Connect(onEnter)
    button.MouseLeave:Connect(onLeave)
end

local function glyph(text)
    local token = tostring(text or "UI"):gsub("%s+", ""):upper():sub(1, 2)
    return token ~= "" and token or "UI"
end

local function getGuiParent()
    if typeof(gethui) == "function" then
        local ok, gui = pcall(gethui)
        if ok and gui then
            return gui
        end
    end

    local player = Players.LocalPlayer
    if player then
        local playerGui = player:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            return playerGui
        end
    end

    return game:GetService("CoreGui")
end

local function clampSize(size)
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    return UDim2.fromOffset(
        math.clamp(size.X.Offset, 500, math.floor(viewport.X * 0.92)),
        math.clamp(size.Y.Offset, 360, math.floor(viewport.Y * 0.9))
    )
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Element = {}
Element.__index = Element

local function registerFlag(window, config, value)
    if config.Flag and window.Flags[config.Flag] == nil then
        window.Flags[config.Flag] = value
    end
end

local function setFlag(window, config, value)
    if config.Flag then
        window.Flags[config.Flag] = value
    end
end

local function makeCard(tab, config)
    local theme = tab.Window.Theme

    local card = create("Frame", {
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, config.Desc and config.Desc ~= "" and 82 or 60),
    })
    corner(card, 20)
    stroke(card, theme.Outline, 0.08)
    gradient(card, theme.Surface, theme.SurfaceAlt, 90)

    local bloomLine = create("Frame", {
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -28, 0, 2),
    })
    bloomLine.Parent = card
    gradient(bloomLine, theme.AccentSoft, theme.Accent, 0)

    local wrap = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 0),
        Size = UDim2.new(1, -170, 1, 0),
    })
    wrap.Parent = card

    local list = create("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
    })
    list.Parent = wrap

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 20),
        Text = config.Title or "Untitled",
        TextColor3 = theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    title.Parent = wrap

    local desc = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Size = UDim2.new(1, 0, 0, 16),
        Text = config.Desc or "",
        TextColor3 = theme.Subtext,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = config.Desc ~= nil and config.Desc ~= "",
    })
    desc.Parent = wrap

    local overlay = create("Frame", {
        BackgroundColor3 = theme.Overlay,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
    })
    overlay.Parent = card
    corner(overlay, 20)

    local pill = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(132, 34),
    })
    pill.Parent = overlay
    corner(pill, 17)
    stroke(pill, theme.OutlineStrong, 0.14)

    local badge = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 56, 1, 0),
        Text = "LOCKED",
        TextColor3 = theme.AccentSoft,
        TextSize = 10,
    })
    badge.Parent = pill

    local lockText = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Position = UDim2.new(0, 58, 0, 0),
        Size = UDim2.new(1, -66, 1, 0),
        Text = config.LockedTitle or "Locked",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    lockText.Parent = pill

    return setmetatable({
        Window = tab.Window,
        Tab = tab,
        Config = config,
        Card = card,
        TitleLabel = title,
        DescLabel = desc,
        LockOverlay = overlay,
        LockText = lockText,
        Locked = false,
    }, Element)
end

function Element:SetLockedState(locked, label)
    self.Locked = locked
    self.Config.Locked = locked
    if label then
        self.Config.LockedTitle = label
    end

    self.LockText.Text = self.Config.LockedTitle or "Locked"
    self.LockOverlay.Visible = locked
    self.TitleLabel.TextTransparency = locked and 0.45 or 0
    self.DescLabel.TextTransparency = locked and 0.6 or 0

    if self.Hitbox then
        self.Hitbox.Active = not locked
    end
    if self.InputBox then
        self.InputBox.TextEditable = not locked
    end

    return self
end

function Element:Lock(label)
    return self:SetLockedState(true, label)
end

function Element:Unlock()
    return self:SetLockedState(false)
end

function BloomUI:CreateWindow(config)
    config = config or {}
    local resolved = {}
    for key, value in pairs(DEFAULT_WINDOW) do
        resolved[key] = value
    end
    for key, value in pairs(config) do
        resolved[key] = value
    end

    local theme = resolved.Theme
    if type(theme) == "string" then
        theme = self.Themes[theme]
    end
    theme = cloneTheme(theme)

    local screenGui = create("ScreenGui", {
        Name = "BloomUI_" .. HttpService:GenerateGUID(false),
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    screenGui.Parent = getGuiParent()

    local shell = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = clampSize(resolved.Size),
    })
    shell.Parent = screenGui

    local shellScale = create("UIScale", {
        Scale = 0.96,
    })
    shellScale.Parent = shell

    local glowA = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Accent,
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0,
        Position = UDim2.new(0.38, 0, 0.4, 0),
        Size = UDim2.fromOffset(300, 300),
    })
    glowA.Parent = screenGui
    corner(glowA, 999)

    local glowB = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.AccentSoft,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        Position = UDim2.new(0.66, 0, 0.66, 0),
        Size = UDim2.fromOffset(380, 380),
    })
    glowB.Parent = screenGui
    corner(glowB, 999)

    local shadow = create("Frame", {
        BackgroundColor3 = Color3.new(),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 18),
        Size = UDim2.fromScale(1, 1),
    })
    shadow.Parent = shell
    corner(shadow, 32)

    local root = create("Frame", {
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
    })
    root.Parent = shell
    corner(root, 32)
    stroke(root, theme.OutlineStrong, 0.14)
    gradient(root, theme.Background, Color3.fromRGB(5, 7, 12), 90)
    padding(root, 14, 14, 14, 14)

    local sidebar = create("Frame", {
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 214, 1, 0),
    })
    sidebar.Parent = root
    corner(sidebar, 26)
    stroke(sidebar, theme.Outline, 0.14)
    gradient(sidebar, theme.Panel, theme.SurfaceAlt, 90)
    padding(sidebar, 18, 18, 18, 18)

    local brand = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, -52, 0, 24),
        Text = resolved.Title,
        TextColor3 = theme.Text,
        TextSize = 21,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    brand.Parent = sidebar

    local subtitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 0, 0, 28),
        Size = UDim2.new(1, -52, 0, 16),
        Text = resolved.Subtitle,
        TextColor3 = theme.Subtext,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    subtitle.Parent = sidebar

    local brandChip = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(42, 28),
        Font = Enum.Font.GothamBold,
        Text = glyph(resolved.Title),
        TextColor3 = theme.AccentSoft,
        TextSize = 11,
    })
    brandChip.Parent = sidebar
    corner(brandChip, 14)

    local tabHolder = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        Position = UDim2.new(0, 0, 0, 74),
        ScrollBarImageTransparency = 1,
        Size = UDim2.new(1, 0, 1, -74),
    })
    tabHolder.Parent = sidebar

    local tabLayout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    tabLayout.Parent = tabHolder
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabHolder.CanvasSize = UDim2.fromOffset(0, tabLayout.AbsoluteContentSize.Y + 8)
    end)

    local content = create("Frame", {
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 228, 0, 0),
        Size = UDim2.new(1, -228, 1, 0),
    })
    content.Parent = root
    corner(content, 26)
    stroke(content, theme.Outline, 0.14)
    gradient(content, theme.Panel, theme.SurfaceAlt, 90)
    padding(content, 18, 18, 18, 18)

    local topbar = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
    })
    topbar.Parent = content

    local topTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, -110, 0, 22),
        Text = "Dashboard",
        TextColor3 = theme.Text,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    topTitle.Parent = topbar

    local topSub = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 0, 0, 24),
        Size = UDim2.new(1, -110, 0, 18),
        Text = "Built to feel custom, not copied.",
        TextColor3 = theme.Subtext,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    topSub.Parent = topbar

    local pageHost = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -60),
    })
    pageHost.Parent = content

    local actionRow = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(76, 32),
    })
    actionRow.Parent = topbar

    local actionLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
    })
    actionLayout.Parent = actionRow

    local chip = create("TextButton", {
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 1, -24),
        Size = UDim2.fromOffset(150, 44),
        Font = Enum.Font.GothamBold,
        Text = "BloomUI  OPEN",
        TextColor3 = theme.Text,
        TextSize = 13,
        Visible = false,
    })
    chip.Parent = screenGui
    corner(chip, 22)
    stroke(chip, theme.OutlineStrong, 0.14)
    gradient(chip, theme.Panel, theme.Surface, 90)

    local notifyHost = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0, 24),
        Size = UDim2.new(0, 320, 1, -48),
    })
    notifyHost.Parent = screenGui

    create("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = notifyHost,
    })

    local window = setmetatable({
        Theme = theme,
        Config = resolved,
        ScreenGui = screenGui,
        Shell = shell,
        Root = root,
        PageHost = pageHost,
        TabHolder = tabHolder,
        TopTitle = topTitle,
        TopSubtitle = topSub,
        OpenChip = chip,
        ShellScale = shellScale,
        NotificationHost = notifyHost,
        Flags = {},
        Tabs = {},
        Visible = true,
    }, Window)

    local function action(symbol, callback)
        local button = create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(32, 32),
            Font = Enum.Font.GothamBold,
            Text = symbol,
            TextColor3 = theme.Subtext,
            TextSize = 14,
        })
        button.Parent = actionRow
        corner(button, 16)
        stroke(button, theme.Outline, 0.18)

        local scale = create("UIScale", {
            Scale = 1,
        })
        scale.Parent = button

        bindHover(button, function()
            tween(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Scale = 1.04 })
        end, function()
            tween(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Scale = 1 })
        end)

        button.MouseButton1Click:Connect(callback)
    end

    action("-", function()
        window:Close()
    end)

    action("X", function()
        window:Destroy()
    end)

    local dragging = false
    local dragStart
    local startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = shell.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            shell.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    if resolved.ToggleKey then
        UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == resolved.ToggleKey then
                window:Toggle()
            end
        end)
    end

    chip.MouseButton1Click:Connect(function()
        window:Open()
    end)

    tween(shellScale, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
        Scale = 1,
    })

    return window
end

function Window:CreateTab(config)
    config = config or {}
    local theme = self.Theme

    local button = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.SurfaceAlt,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 54),
        Font = Enum.Font.GothamBold,
        Text = "",
    })
    button.Parent = self.TabHolder
    corner(button, 18)
    stroke(button, theme.Outline, 0.18)

    local scale = create("UIScale", {
        Scale = 1,
    })
    scale.Parent = button

    local icon = create("TextLabel", {
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, -16),
        Size = UDim2.fromOffset(32, 32),
        Font = Enum.Font.GothamBold,
        Text = glyph(config.Icon or config.Title),
        TextColor3 = theme.AccentSoft,
        TextSize = 11,
    })
    icon.Parent = button
    corner(icon, 16)

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 52, 0, 10),
        Size = UDim2.new(1, -64, 0, 18),
        Text = config.Title or "Tab",
        TextColor3 = theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    title.Parent = button

    local subtitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 52, 0, 28),
        Size = UDim2.new(1, -64, 0, 14),
        Text = config.Desc or "Build your flow here",
        TextColor3 = theme.Subtext,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    subtitle.Parent = button

    local page = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarImageTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
    })
    page.Parent = self.PageHost

    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 12),
    })
    layout.Parent = page
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
    end)

    local tab = setmetatable({
        Window = self,
        Config = config,
        Button = button,
        Page = page,
        Icon = icon,
        Title = title,
        Scale = scale,
        Active = false,
    }, Tab)

    function tab:SetActive(active)
        self.Active = active
        self.Page.Visible = active
        tween(self.Button, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
            BackgroundColor3 = active and theme.Surface or theme.SurfaceAlt,
        })
        tween(self.Icon, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
            BackgroundColor3 = active and theme.Accent or theme.Surface,
            TextColor3 = active and theme.Background or theme.AccentSoft,
        })
        tween(self.Scale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
            Scale = active and 1.01 or 1,
        })
        if active then
            self.Window.TopTitle.Text = self.Config.Title or "Dashboard"
            self.Window.TopSubtitle.Text = self.Config.Desc or "Built to feel custom, not copied."
        end
    end

    button.MouseButton1Click:Connect(function()
        for _, other in ipairs(self.Tabs) do
            other:SetActive(false)
        end
        tab:SetActive(true)
    end)

    bindHover(button, function()
        if not tab.Active then
            tween(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Scale = 1.015 })
        end
    end, function()
        if not tab.Active then
            tween(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Scale = 1 })
        end
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        tab:SetActive(true)
    end

    return tab
end

function Tab:Section(text)
    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 16),
        Text = tostring(text or "Section"):upper(),
        TextColor3 = self.Window.Theme.AccentSoft,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    label.Parent = self.Page
    return label
end

function Tab:Spacer(height)
    local spacer = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 4),
    })
    spacer.Parent = self.Page
    return spacer
end

function Tab:Button(config)
    config = config or {}
    local theme = self.Window.Theme
    local element = makeCard(self, config)

    local hitbox = create("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Text = "",
    })
    hitbox.Parent = element.Card

    local badge = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = theme.SurfaceAlt,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(88, 38),
        Font = Enum.Font.GothamBold,
        Text = config.Badge or "RUN",
        TextColor3 = theme.AccentSoft,
        TextSize = 12,
    })
    badge.Parent = element.Card
    corner(badge, 19)
    stroke(badge, theme.Outline, 0.18)

    local scale = create("UIScale", {
        Scale = 1,
    })
    scale.Parent = element.Card

    bindHover(hitbox, function()
        if not element.Locked then
            tween(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Scale = 1.01 })
        end
    end, function()
        tween(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Scale = 1 })
    end)

    hitbox.MouseButton1Click:Connect(function()
        if element.Locked then
            return
        end
        tween(scale, TweenInfo.new(0.16, Enum.EasingStyle.Quint), { Scale = 0.99 })
        task.delay(0.16, function()
            if scale.Parent then
                tween(scale, TweenInfo.new(0.18, Enum.EasingStyle.Back), { Scale = 1 })
            end
        end)
        if config.Callback then
            task.spawn(config.Callback)
        end
    end)

    element.Hitbox = hitbox
    element.Card.Parent = self.Page
    element.LockOverlay.Parent = nil
    element.LockOverlay.Parent = element.Card
    element:SetLockedState(config.Locked == true, config.LockedTitle)
    return element
end

function Tab:Toggle(config)
    config = config or {}
    local theme = self.Window.Theme
    local value = config.Value == true

    registerFlag(self.Window, config, value)
    value = config.Flag and self.Window.Flags[config.Flag] or value

    local element = makeCard(self, config)
    local hitbox = create("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Text = "",
    })
    hitbox.Parent = element.Card

    local rail = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = value and theme.Accent or theme.SurfaceAlt,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -18, 0.5, 0),
        Size = UDim2.fromOffset(62, 34),
    })
    rail.Parent = element.Card
    corner(rail, 17)

    local knob = create("Frame", {
        BackgroundColor3 = value and theme.Background or theme.Text,
        BorderSizePixel = 0,
        Position = value and UDim2.new(1, -30, 0.5, -13) or UDim2.new(0, 4, 0.5, -13),
        Size = UDim2.fromOffset(26, 26),
    })
    knob.Parent = rail
    corner(knob, 13)

    local function apply(nextValue)
        value = nextValue == true
        setFlag(self.Window, config, value)
        tween(rail, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
            BackgroundColor3 = value and theme.Accent or theme.SurfaceAlt,
        })
        tween(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
            BackgroundColor3 = value and theme.Background or theme.Text,
            Position = value and UDim2.new(1, -30, 0.5, -13) or UDim2.new(0, 4, 0.5, -13),
        })
        if config.Callback then
            task.spawn(config.Callback, value)
        end
    end

    hitbox.MouseButton1Click:Connect(function()
        if not element.Locked then
            apply(not value)
        end
    end)

    element.Hitbox = hitbox
    element.GetValue = function()
        return value
    end
    element.SetValue = function(_, nextValue)
        apply(nextValue)
    end
    element.Card.Parent = self.Page
    element.LockOverlay.Parent = nil
    element.LockOverlay.Parent = element.Card
    element:SetLockedState(config.Locked == true, config.LockedTitle)
    return element
end

function Tab:Input(config)
    config = config or {}
    local theme = self.Window.Theme
    local value = tostring(config.Value or "")

    registerFlag(self.Window, config, value)
    value = config.Flag and self.Window.Flags[config.Flag] or value

    local element = makeCard(self, config)
    local wrap = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = theme.SurfaceAlt,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(210, 40),
    })
    wrap.Parent = element.Card
    corner(wrap, 18)
    stroke(wrap, theme.Outline, 0.16)

    local box = create("TextBox", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderColor3 = theme.Subtext,
        PlaceholderText = config.Placeholder or "Type here...",
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Text = value,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    box.Parent = wrap

    box.FocusLost:Connect(function(enterPressed)
        value = box.Text
        setFlag(self.Window, config, value)
        if config.Callback then
            task.spawn(config.Callback, value, enterPressed)
        end
    end)

    element.InputBox = box
    element.GetValue = function()
        return value
    end
    element.SetValue = function(_, nextValue)
        value = tostring(nextValue or "")
        box.Text = value
        setFlag(self.Window, config, value)
    end
    element.Card.Parent = self.Page
    element.LockOverlay.Parent = nil
    element.LockOverlay.Parent = element.Card
    element:SetLockedState(config.Locked == true, config.LockedTitle)
    return element
end

function Window:GetValue(flag)
    return self.Flags[flag]
end

function Window:SetValue(flag, value)
    self.Flags[flag] = value
end

function Window:Notify(config)
    config = config or {}
    local theme = self.Theme

    local toast = create("Frame", {
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(320, 78),
    })
    toast.Parent = self.NotificationHost
    corner(toast, 22)
    stroke(toast, theme.OutlineStrong, 0.16)
    gradient(toast, theme.Panel, theme.Surface, 90)

    local bar = create("Frame", {
        BackgroundColor3 = config.Color or theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 4, 1, -20),
    })
    bar.Parent = toast
    corner(bar, 2)

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(0, 24, 0, 14),
        Size = UDim2.new(1, -38, 0, 20),
        Text = config.Title or "BloomUI",
        TextColor3 = theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    title.Parent = toast

    local body = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(0, 24, 0, 36),
        Size = UDim2.new(1, -38, 0, 28),
        Text = config.Content or "Ready.",
        TextColor3 = theme.Subtext,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
    body.Parent = toast

    local scale = create("UIScale", {
        Scale = 0.92,
    })
    scale.Parent = toast

    tween(scale, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Scale = 1 })

    task.delay(config.Duration or 4, function()
        if not toast.Parent then
            return
        end
        tween(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Scale = 0.94 })
        task.wait(0.18)
        toast:Destroy()
    end)

    return toast
end

function Window:Open()
    self.Visible = true
    self.Shell.Visible = true
    self.OpenChip.Visible = false
    tween(self.ShellScale, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Scale = 1 })
end

function Window:Close()
    self.Visible = false
    self.OpenChip.Visible = true
    tween(self.ShellScale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Scale = 0.94 })
    task.delay(0.18, function()
        if not self.Visible and self.Shell then
            self.Shell.Visible = false
        end
    end)
end

function Window:Toggle()
    if self.Visible then
        self:Close()
    else
        self:Open()
    end
end

function Window:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end
end

BloomUI.Themes.Bloom = cloneTheme(DEFAULT_THEME)

return BloomUI


