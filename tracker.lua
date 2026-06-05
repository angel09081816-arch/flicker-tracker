--[[
    RoleInfo Cheat Sheet (Live Hook Version)
    Hooks into the real ReplicatedStorage modules to display accurate, live role data.
    Toggle: Right Control (or Tab to match game)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local TOGGLE_KEY = Enum.KeyCode.RightControl
local USE_TAB_TOGGLE = false -- also toggle with Tab (game's default)
local SHOW_MY_ROLE_AUTO = true -- auto-display your role when received

-- ============================================================
-- COLOR & STYLE
-- ============================================================
local COLORS = {
    Background = Color3.fromRGB(20, 20, 25),
    Header = Color3.fromRGB(30, 30, 40),
    Section = Color3.fromRGB(40, 40, 55),
    Text = Color3.fromRGB(230, 230, 230),
    Muted = Color3.fromRGB(160, 160, 170),
    Good = Color3.fromRGB(103, 225, 122),
    Evil = Color3.fromRGB(255, 85, 88),
    Neutral = Color3.fromRGB(197, 197, 197),
    Accent = Color3.fromRGB(100, 130, 255),
}

local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

-- ============================================================
-- FIND GAME MODULES
-- ============================================================
local function safeRequire(path)
    local ok, mod = pcall(function()
        local obj = path
        for _, name in ipairs({"split"}) do end -- placeholder
        return require(obj)
    end)
    return ok and mod or nil
end

-- Try to find the RoleInfo module
local function findModule(parent, name, depth)
    depth = depth or 0
    if depth > 5 then return nil end
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("ModuleScript") and child.Name == name then
            return child
        end
    end
    for _, child in ipairs(parent:GetChildren()) do
        local found = findModule(child, name, depth + 1)
        if found then return found end
    end
    return nil
end

local function getRoleInfo()
    -- Common locations based on deobfuscated code
    local candidates = {
        ReplicatedStorage:FindFirstChild("RoleInfo"),
        ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild("RoleInfo"),
        findModule(ReplicatedStorage, "RoleInfo"),
    }
    for _, c in ipairs(candidates) do
        if c then
            local ok, data = pcall(require, c)
            if ok and type(data) == "table" then return data end
        end
    end
    return nil
end

local function getDataController()
    if ReplicatedStorage:FindFirstChild("DataController") then
        local ok, dc = pcall(require, ReplicatedStorage.DataController)
        if ok then return dc end
    end
    return nil
end

local ROLE_INFO = getRoleInfo()
local DATA_CTRL = getDataController()

if not ROLE_INFO then
    warn("[RoleCheatSheet] Could not find RoleInfo module. The script will still run with limited functionality.")
end

-- ============================================================
-- GET LIVE ROLIST FROM GAME
-- ============================================================
local currentRolelist = nil
local myRole = nil
local myRoleDetails = nil

local function fetchLiveRolelist()
    if not DATA_CTRL then return nil end
    local ok, replica = pcall(function()
        return DATA_CTRL:GetFirstReplicaOfClass("GameData")
    end)
    if not ok or not replica then return nil end
    local data = replica.Data
    if not data then return nil end
    return data.Rolelist, #data.Players
end

-- ============================================================
-- BUILD GUI
-- ============================================================
local function make(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" and k ~= "Children" then
            pcall(function() inst[k] = v end)
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

-- Destroy old GUI if exists
local old = LocalPlayer.PlayerGui:FindFirstChild("RoleCheatSheetGUI")
if old then old:Destroy() end

local screenGui = make("ScreenGui", {
    Name = "RoleCheatSheetGUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
})

local mainFrame = make("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 520, 0, 620),
    Position = UDim2.new(0.5, -260, 0.5, -310),
    BackgroundColor3 = COLORS.Background,
    BorderSizePixel = 0,
    Visible = true,
}, {})

make("UICorner", {CornerRadius = UDim.new(0, 10), Parent = mainFrame})
make("UIStroke", {Color = COLORS.Accent, Thickness = 2, Parent = mainFrame})

-- Title bar
local titleBar = make("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = COLORS.Header,
    BorderSizePixel = 0,
    Parent = mainFrame,
})
make("UICorner", {CornerRadius = UDim.new(0, 10), Parent = titleBar})
make("Frame", {Size = UDim2.new(1, 0, 0.5, 0), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = COLORS.Header, BorderSizePixel = 0, Parent = titleBar})

local titleLabel = make("TextLabel", {
    Name = "Title",
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "📋  Role Cheat Sheet  (Live Data)",
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = FONT_BOLD,
    TextSize = 16,
    Parent = titleBar,
})

local statusLabel = make("TextLabel", {
    Name = "Status",
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 0, 42),
    BackgroundTransparency = 1,
    Text = ROLE_INFO and "✓ Hooked into live game data" or "⚠ Using fallback data",
    TextColor3 = ROLE_INFO and COLORS.Good or COLORS.Evil,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = FONT,
    TextSize = 11,
    Parent = mainFrame,
})

-- Tab buttons
local tabFrame = make("Frame", {
    Name = "Tabs",
    Size = UDim2.new(1, -20, 0, 32),
    Position = UDim2.new(0, 10, 0, 65),
    BackgroundTransparency = 1,
    Parent = mainFrame,
})

local function makeTab(name, color, order)
    local btn = make("TextButton", {
        Name = name,
        Size = UDim2.new(0.33, -4, 1, 0),
        Position = UDim2.new((order - 1) * 0.33 + 2 * (order > 1 and 1 or 0) / 100, 0, 0, 0),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = COLORS.Section,
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = color,
        Font = FONT_BOLD,
        TextSize = 13,
        AutoButtonColor = false,
        Parent = tabFrame,
    })
    make("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
    return btn
end

local goodTab = makeTab("Good Team", COLORS.Good, 1)
local evilTab = makeTab("Evil Team", COLORS.Evil, 2)
local neutralTab = makeTab("Neutral", COLORS.Neutral, 3)

-- Content area
local contentFrame = make("ScrollingFrame", {
    Name = "Content",
    Size = UDim2.new(1, -20, 1, -110),
    Position = UDim2.new(0, 10, 0, 105),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 6,
    ScrollBarImageColor3 = COLORS.Accent,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = mainFrame,
})

local contentLayout = make("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6),
    Parent = contentFrame,
})

-- ============================================================
-- RENDER ROLES
-- ============================================================
local currentTab = "Good"
local roleButtons = {}

local function clearContent()
    for _, c in ipairs(contentFrame:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end
end

local function highlightTab(activeBtn)
    for _, btn in ipairs({goodTab, evilTab, neutralTab}) do
        btn.BackgroundColor3 = (btn == activeBtn) and COLORS.Accent or COLORS.Section
    end
end

local function getSideColor(side)
    if side == "Good" then return COLORS.Good
    elseif side == "Evil" then return COLORS.Evil
    else return COLORS.Neutral end
end

local function formatList(arr)
    if not arr or #arr == 0 then return "" end
    local parts = {}
    for _, v in ipairs(arr) do
        if type(v) == "string" then
            table.insert(parts, "• " .. v)
        elseif type(v) == "table" then
            local txt = v[1] or ""
            table.insert(parts, "• " .. txt)
        end
    end
    return table.concat(parts, "\n")
end

local function createRoleCard(roleName, roleData)
    local sideColor = getSideColor(roleData.Side)
    local amountText = (roleData.Amount and roleData.Amount > 1) and (" x" .. tostring(roleData.Amount)) or ""
    
    local card = make("TextButton", {
        Name = roleName,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = COLORS.Section,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = true,
        LayoutOrder = #contentFrame:GetChildren(),
        Parent = contentFrame,
    })
    make("UICorner", {CornerRadius = UDim.new(0, 8), Parent = card})
    make("UIStroke", {Color = sideColor, Thickness = 1, Transparency = 0.5, Parent = card})
    
    local header = make("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    make("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = string.format("%s %s%s", roleData.Emoji or "❓", roleName, amountText),
        TextColor3 = sideColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = FONT_BOLD,
        TextSize = 14,
        Parent = header,
    })
    
    local info = roleData.Info or {}
    local body = make("TextLabel", {
        Name = "Body",
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 32),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Font = FONT,
        TextSize = 12,
        TextColor3 = COLORS.Text,
        Parent = card,
    })
    
    local lines = {}
    for _, key in ipairs({"Goal", "Abilities", "Details", "Behavior"}) do
        if info[key] and #info[key] > 0 then
            table.insert(lines, "<font color='#" .. COLORS.Muted:ToHex() .. "'>[" .. key .. "]</font>")
            for _, item in ipairs(info[key]) do
                local txt = type(item) == "string" and item or (item[1] or "")
                table.insert(lines, "  • " .. txt)
            end
            table.insert(lines, "")
        end
    end
    body.Text = table.concat(lines, "\n")
    
    -- Padding at bottom
    make("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        Parent = card,
    })
    
    return card
end

local function renderTab(side)
    clearContent()
    if not ROLE_INFO then
        local lbl = make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 100),
            BackgroundTransparency = 1,
            Text = "RoleInfo module not found.\nGame data unavailable.",
            TextColor3 = COLORS.Evil,
            Font = FONT,
            TextSize = 14,
            TextWrapped = true,
            Parent = contentFrame,
        })
        return
    end
    
    for roleName, roleData in pairs(ROLE_INFO) do
        if type(roleData) == "table" and roleData.Side == side then
            createRoleCard(roleName, roleData)
        end
    end
    
    -- Add live rolelist summary if available
    if currentRolelist then
        make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = COLORS.Header,
            BorderSizePixel = 0,
            LayoutOrder = 9999,
            Parent = contentFrame,
        })
    end
end

goodTab.MouseButton1Click:Connect(function()
    currentTab = "Good"
    highlightTab(goodTab)
    renderTab("Good")
end)
evilTab.MouseButton1Click:Connect(function()
    currentTab = "Evil"
    highlightTab(evilTab)
    renderTab("Evil")
end)
neutralTab.MouseButton1Click:Connect(function()
    currentTab = "Neutral"
    highlightTab(neutralTab)
    renderTab("Neutral")
end)

-- ============================================================
-- LIVE ROLIST DISPLAY
-- ============================================================
local function showLiveRolelist()
    local rolelist, playerCount = fetchLiveRolelist()
    if not rolelist then return end
    currentRolelist = rolelist
    
    -- Header for live rolelist
    local header = make("Frame", {
        Name = "LiveHeader",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = COLORS.Header,
        BorderSizePixel = 0,
        LayoutOrder = 0,
        Parent = contentFrame,
    })
    make("UICorner", {CornerRadius = UDim.new(0, 6), Parent = header})
    make("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = string.format("🎮 Current Game (%d players)", playerCount or 0),
        TextColor3 = COLORS.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = FONT_BOLD,
        TextSize = 13,
        Parent = header,
    })
    
    -- Sort rolelist entries
    local entries = {}
    for i, roles in ipairs(rolelist) do
        if playerCount and playerCount < i then break end
        table.insert(entries, {i, roles})
    end
    table.sort(entries, function(a, b) return a[1] < b[1] end)
    
    for _, entry in ipairs(entries) do
        local slot, roles = entry[1], entry[2]
        local names = {}
        for _, r in ipairs(roles) do
            table.insert(names, r)
        end
        local frame = make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = COLORS.Section,
            BorderSizePixel = 0,
            Text = "  Slot " .. slot .. ": " .. table.concat(names, " + "),
            TextColor3 = COLORS.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = FONT,
            TextSize = 12,
            LayoutOrder = slot,
            Parent = contentFrame,
        })
        make("UICorner", {CornerRadius = UDim.new(0, 4), Parent = frame})
    end
end

-- ============================================================
-- MY ROLE NOTIFICATION
-- ============================================================
local function showMyRoleNotification()
    if not myRole or not SHOW_MY_ROLE_AUTO then return end
    
    local roleData = ROLE_INFO and ROLE_INFO[myRole]
    if not roleData then return end
    
    local notif = make("Frame", {
        Name = "MyRoleNotif",
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, -310, 0, 10),
        BackgroundColor3 = COLORS.Header,
        BorderSizePixel = 0,
        Parent = screenGui,
    })
    make("UICorner", {CornerRadius = UDim.new(0, 8), Parent = notif})
    make("UIStroke", {Color = getSideColor(roleData.Side), Thickness = 2, Parent = notif})
    
    make("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Text = "🎭 Your Role",
        TextColor3 = COLORS.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = FONT,
        TextSize = 12,
        Parent = notif,
    })
    make("TextLabel", {
        Size = UDim2.new(1, -20, 1, -30),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = string.format("%s %s", roleData.Emoji or "", myRole),
        TextColor3 = getSideColor(roleData.Side),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = FONT_BOLD,
        TextSize = 22,
        Parent = notif,
    })
    
    -- Auto-fade after 8s
    task.delay(8, function()
        if notif and notif.Parent then
            notif:Destroy()
        end
    end)
end

-- ============================================================
-- HOOK NETWORK EVENTS
-- ============================================================
pcall(function()
    local Net = require(ReplicatedStorage.Common.Network)
    Net:BindEvents({
        ["SendRoleInfo"] = function(eventType, payload)
            if eventType == "Info" then
                myRole = payload
                showMyRoleNotification()
            elseif eventType == "Details" then
                myRoleDetails = payload
            end
        end
    })
end)

-- ============================================================
-- TOGGLE & DRAG
-- ============================================================
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == TOGGLE_KEY then
        mainFrame.Visible = not mainFrame.Visible
    elseif USE_TAB_TOGGLE and input.KeyCode == Enum.KeyCode.Tab then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Dragging
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ============================================================
-- INIT
-- ============================================================
screenGui.Parent = LocalPlayer.PlayerGui
highlightTab(goodTab)
renderTab("Good")
showLiveRolelist()

print("[RoleCheatSheet] Loaded. Press RightControl to toggle.")
