--[[
    Role Cheat Sheet - Button Toggle Version
    Click the floating button (bottom-right) to open/close the panel.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local BUTTON_TEXT = "📋 Roles"  -- text on the toggle button
local BUTTON_POSITION = "BottomRight"  -- "BottomRight", "BottomLeft", "TopRight", "TopLeft"
local TOGGLE_KEY = Enum.KeyCode.RightControl  -- backup keyboard toggle (optional)

-- ============================================================
-- STYLE
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
    Button = Color3.fromRGB(60, 60, 80),
    ButtonHover = Color3.fromRGB(80, 80, 110),
}
local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

-- ============================================================
-- HELPER
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

local function getPos(side)
    local off = 20
    if side == "BottomRight" then
        return UDim2.new(1, -100 - off, 1, -50 - off)
    elseif side == "BottomLeft" then
        return UDim2.new(0, off, 1, -50 - off)
    elseif side == "TopRight" then
        return UDim2.new(1, -100 - off, 0, off)
    else
        return UDim2.new(0, off, 0, off)
    end
end

-- ============================================================
-- FIND GAME MODULES
-- ============================================================
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
    local candidates = {
        ReplicatedStorage:FindFirstChild("RoleInfo"),
        ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild("RoleInfo"),
        findModule(ReplicatedStorage, "RoleInfo"),
    }
    for _, c in ipairs(candidates) do
        if c then
            local ok, data = pcall(require, c)
            if ok and type(data) == "table" and next(data) then return data end
        end
    end
    return nil
end

local function getDataController()
    if ReplicatedStorage:FindFirstChild("DataController") then
        local ok, dc = pcall(require, ReplicatedStorage.DataController)
        if ok then return dc end
    end
    if ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild("DataController") then
        local ok, dc = pcall(require, ReplicatedStorage.Data.DataController)
        if ok then return dc end
    end
    return nil
end

local ROLE_INFO = getRoleInfo()
local DATA_CTRL = getDataController()

if not ROLE_INFO then
    warn("[RoleCheatSheet] RoleInfo module not found.")
end

-- ============================================================
-- CLEAN UP OLD GUI
-- ============================================================
local old = LocalPlayer.PlayerGui:FindFirstChild("RoleCheatSheetGUI")
if old then old:Destroy() end

-- ============================================================
-- BUILD GUI
-- ============================================================
local screenGui = make("ScreenGui", {
    Name = "RoleCheatSheetGUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 999,  -- render on top
})

-- === TOGGLE BUTTON (always visible) ===
local toggleButton = make("TextButton", {
    Name = "ToggleButton",
    Size = UDim2.new(0, 110, 0, 50),
    Position = getPos(BUTTON_POSITION),
    BackgroundColor3 = COLORS.Button,
    BorderSizePixel = 0,
    Text = BUTTON_TEXT,
    TextColor3 = COLORS.Text,
    Font = FONT_BOLD,
    TextSize = 16,
    AutoButtonColor = true,
    Parent = screenGui,
})
make("UICorner", {CornerRadius = UDim.new(0, 10), Parent = toggleButton})
make("UIStroke", {Color = COLORS.Accent, Thickness = 2, Parent = toggleButton})

-- hover effect
toggleButton.MouseEnter:Connect(function()
    toggleButton.BackgroundColor3 = COLORS.ButtonHover
end)
toggleButton.MouseLeave:Connect(function()
    toggleButton.BackgroundColor3 = COLORS.Button
end)

-- === MAIN PANEL (hidden by default) ===
local mainFrame = make("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 520, 0, 620),
    Position = UDim2.new(0.5, -260, 0.5, -310),
    BackgroundColor3 = COLORS.Background,
    BorderSizePixel = 0,
    Visible = false,  -- starts hidden
    Parent = screenGui,
})
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
make("Frame", {
    Size = UDim2.new(1, 0, 0.5, 0),
    Position = UDim2.new(0, 0, 0.5, 0),
    BackgroundColor3 = COLORS.Header,
    BorderSizePixel = 0,
    Parent = titleBar,
})

make("TextLabel", {
    Name = "Title",
    Size = UDim2.new(1, -90, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "📋  Role Cheat Sheet",
    TextColor3 = COLORS.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = FONT_BOLD,
    TextSize = 16,
    Parent = titleBar,
})

-- Close button (X) in title bar
local closeBtn = make("TextButton", {
    Name = "Close",
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -35, 0, 5),
    BackgroundColor3 = COLORS.Section,
    BorderSizePixel = 0,
    Text = "X",
    TextColor3 = COLORS.Evil,
    Font = FONT_BOLD,
    TextSize = 16,
    AutoButtonColor = true,
    Parent = titleBar,
})
make("UICorner", {CornerRadius = UDim.new(0, 6), Parent = closeBtn})

make("TextLabel", {
    Name = "Status",
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 0, 42),
    BackgroundTransparency = 1,
    Text = ROLE_INFO and "✓ Hooked into live game data" or "⚠ RoleInfo module not found",
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
        Position = UDim2.new(0, (order - 1) * (1/3) * 100 + (order - 1) * 2, 0, 0),
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
make("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6),
    Parent = contentFrame,
})

-- ============================================================
-- RENDER
-- ============================================================
local function clearContent()
    for _, c in ipairs(contentFrame:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") or c:IsA("TextLabel") then
            c:Destroy()
        end
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

local currentRolelist = nil
local playerCount = nil

local function fetchLiveRolelist()
    if not DATA_CTRL then return nil, nil end
    local ok, replica = pcall(function()
        return DATA_CTRL:GetFirstReplicaOfClass("GameData")
    end)
    if not ok or not replica then return nil, nil end
    local data = replica.Data
    if not data then return nil, nil end
    return data.Rolelist, #data.Players
end

local function createRoleCard(roleName, roleData, order)
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
        LayoutOrder = order or 100,
        Parent = contentFrame,
    })
    make("UICorner", {CornerRadius = UDim.new(0, 8), Parent = card})
    make("UIStroke", {Color = sideColor, Thickness = 1, Transparency = 0.5, Parent = card})
    
    make("TextLabel", {
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.new(0, 10, 0, 4),
        BackgroundTransparency = 1,
        Text = string.format("%s %s%s", roleData.Emoji or "❓", roleName, amountText),
        TextColor3 = sideColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = FONT_BOLD,
        TextSize = 15,
        Parent = card,
    })
    
    local info = roleData.Info or {}
    local lines = {}
    for _, key in ipairs({"Goal", "Abilities", "Details", "Behavior"}) do
        if info[key] and #info[key] > 0 then
            table.insert(lines, "<font color='#" .. COLORS.Muted:ToHex():sub(1,6) .. "'>[" .. key .. "]</font>")
            for _, item in ipairs(info[key]) do
                local txt = type(item) == "string" and item or (item[1] or "")
                table.insert(lines, "  • " .. txt)
            end
            table.insert(lines, "")
        end
    end
    
    make("TextLabel", {
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 36),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = table.concat(lines, "\n"),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Font = FONT,
        TextSize = 12,
        TextColor3 = COLORS.Text,
        RichText = true,
        Parent = card,
    })
    
    make("UIPadding", {
        PaddingBottom = UDim.new(0, 10),
        Parent = card,
    })
end

local function renderLiveRolelist(orderStart)
    if not currentRolelist then return orderStart end
    -- Header
    local header = make("Frame", {
        Name = "LiveHeader",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = COLORS.Header,
        BorderSizePixel = 0,
        LayoutOrder = orderStart,
        Parent = contentFrame,
    })
    make("UICorner", {CornerRadius = UDim.new(0, 6), Parent = header})
    make("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = string.format("🎮 Current Game (%d players)", playerCount or 0),
        TextColor3 = COLORS.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = FONT_BOLD,
        TextSize = 13,
        Parent = header,
    })
    orderStart = orderStart + 1
    
    -- Show actual rolelist entries (respecting the "fewer players than rolelist" rule)
    for i, roles in ipairs(currentRolelist) do
        if playerCount and playerCount < i then break end
        -- Twin → Survivor rule
        local displayRoles = {}
        for _, r in ipairs(roles) do
            if r == "Twin" and playerCount and playerCount <= #currentRolelist then
                table.insert(displayRoles, "Survivor")
            else
                table.insert(displayRoles, r)
            end
        end
        
        local entry = make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = COLORS.Section,
            BorderSizePixel = 0,
            Text = "  Slot " .. i .. ": " .. table.concat(displayRoles, " + "),
            TextColor3 = COLORS.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = FONT,
            TextSize = 12,
            LayoutOrder = orderStart,
            Parent = contentFrame,
        })
        make("UICorner", {CornerRadius = UDim.new(0, 4), Parent = entry})
        orderStart = orderStart + 1
    end
    
    -- Survivor filler
    if playerCount and currentRolelist and playerCount > #currentRolelist then
        local fillers = playerCount - #currentRolelist
        local entry = make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = COLORS.Section,
            BorderSizePixel = 0,
            Text = "  Slot " .. (#currentRolelist + 1) .. ": Survivor x" .. fillers,
            TextColor3 = COLORS.Good,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = FONT,
            TextSize = 12,
            LayoutOrder = orderStart,
            Parent = contentFrame,
        })
        make("UICorner", {CornerRadius = UDim.new(0, 4), Parent = entry})
    end
    
    return orderStart + 1
end

local function renderTab(side)
    clearContent()
    if not ROLE_INFO then
        make("TextLabel", {
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
    
    -- Try to get live rolelist
    currentRolelist, playerCount = fetchLiveRolelist()
    
    local order = 1
    
    -- Show live rolelist at top
    if currentRolelist and side == "Good" then
        order = renderLiveRolelist(order)
    end
    
    -- Show all roles on that side
    -- Collect and sort
    local roleList = {}
    for roleName, roleData in pairs(ROLE_INFO) do
        if type(roleData) == "table" and roleData.Side == side then
            table.insert(roleList, {roleName, roleData})
        end
    end
    table.sort(roleList, function(a, b) return a[1] < b[1] end)
    
    for _, entry in ipairs(roleList) do
        createRoleCard(entry[1], entry[2], order)
        order = order + 1
    end
end

goodTab.MouseButton1Click:Connect(function()
    highlightTab(goodTab)
    renderTab("Good")
end)
evilTab.MouseButton1Click:Connect(function()
    highlightTab(evilTab)
    renderTab("Evil")
end)
neutralTab.MouseButton1Click:Connect(function()
    highlightTab(neutralTab)
    renderTab("Neutral")
end)

-- ============================================================
-- MY ROLE NOTIFICATION
-- ============================================================
local myRole = nil
local myRoleDetails = nil

local function showMyRoleNotification()
    if not myRole or not ROLE_INFO then return end
    local roleData = ROLE_INFO[myRole]
    if not roleData then return end
    
    -- Remove old notification
    local old = screenGui:FindFirstChild("MyRoleNotif")
    if old then old:Destroy() end
    
    local notif = make("Frame", {
        Name = "MyRoleNotif",
        Size = UDim2.new(0, 320, 0, 90),
        Position = UDim2.new(0.5, -160, 0, 20),
        BackgroundColor3 = COLORS.Header,
        BorderSizePixel = 0,
        Parent = screenGui,
    })
    make("UICorner", {CornerRadius = UDim.new(0, 10), Parent = notif})
    make("UIStroke", {Color = getSideColor(roleData.Side), Thickness = 2, Parent = notif})
    
    make("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Text = "🎭 Your Role Was Revealed",
        TextColor3 = COLORS.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = FONT,
        TextSize = 12,
        Parent = notif,
    })
    make("TextLabel", {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = string.format("%s  %s", roleData.Emoji or "", myRole),
        TextColor3 = getSideColor(roleData.Side),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = FONT_BOLD,
        TextSize = 24,
        Parent = notif,
    })
    
    task.delay(8, function()
        if notif and notif.Parent then notif:Destroy() end
    end)
end

-- ============================================================
-- HOOK NETWORK
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
-- TOGGLE LOGIC
-- ============================================================
local function togglePanel()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        -- Refresh content when opening
        if currentTab == "Good" then renderTab("Good")
        elseif currentTab == "Evil" then renderTab("Evil")
        else renderTab("Neutral") end
    end
end

toggleButton.MouseButton1Click:Connect(togglePanel)
closeBtn.MouseButton1Click:Connect(togglePanel)

-- Backup keyboard toggle (might not work in all executors, that's why we have the button)
pcall(function()
    local UIS = game:GetService("UserInputService")
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == TOGGLE_KEY then
            togglePanel()
        end
    end)
end)

-- ============================================================
-- DRAG PANEL
-- ============================================================
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

pcall(function()
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end)

-- ============================================================
-- INIT
-- ============================================================
screenGui.Parent = LocalPlayer.PlayerGui
highlightTab(goodTab)
renderTab("Good")

print("[RoleCheatSheet] Ready! Click the '📋 Roles' button in the corner to open the panel.")
