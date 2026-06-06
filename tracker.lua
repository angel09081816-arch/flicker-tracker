--[[
    Flicker Role Viewer
    Builds a Dex-like GUI that scans for roles and displays them in tabs.
    Methods: Player value scan, ReplicatedStorage scan, PlayerGui text scan
]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local me = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = me:WaitForChild("PlayerGui")

local task_spawn = (task and task.spawn) or spawn
local task_wait = (task and task.wait) or wait
local task_defer = (task and task.defer) or function(fn) spawn(fn) end

local function connectButton(button, fn)
    if button then
        button.Activated:Connect(fn)
        button.MouseButton1Click:Connect(fn)
    end
end

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
        RS:FindFirstChild("RoleInfo"),
        RS:FindFirstChild("Data") and RS.Data:FindFirstChild("RoleInfo"),
        findModule(RS, "RoleInfo"),
    }
    for _, c in ipairs(candidates) do
        if c then
            local ok, data = pcall(require, c)
            if ok and type(data) == "table" and next(data) then
                return data
            end
        end
    end
    return nil
end

local function getDataController()
    local candidates = {
        RS:FindFirstChild("DataController"),
        RS:FindFirstChild("Data") and RS.Data:FindFirstChild("DataController"),
        findModule(RS, "DataController"),
    }
    for _, c in ipairs(candidates) do
        if c then
            local ok, data = pcall(require, c)
            if ok and type(data) == "table" then
                return data
            end
        end
    end
    return nil
end

local ROLE_INFO = getRoleInfo()
local DATA_CTRL = getDataController()

local function buildRoleLookup()
    local lookup = {}
    if ROLE_INFO then
        for key, info in pairs(ROLE_INFO) do
            if type(info) == "table" then
                lookup[key:lower()] = key
                if type(info.Name) == "string" then
                    lookup[info.Name:lower()] = key
                end
                if type(info.Aliases) == "table" then
                    for _, alias in ipairs(info.Aliases) do
                        if type(alias) == "string" then
                            lookup[alias:lower()] = key
                        end
                    end
                end
            end
        end
    end
    local aliases = {
        murderer = "Murderer",
        serialkiller = "SerialKiller",
        ["serial killer"] = "SerialKiller",
        assassin = "Assassin",
        survivor = "Survivor",
        innocent = "Innocent",
        detective = "Detective",
        sheriff = "Sheriff",
        psychic = "Psychic",
        clown = "Clown",
        twin = "Twin",
        twins = "Twins",
        savior = "Savior",
        spy = "Spy",
        scout = "Scout",
        witch = "Witch",
        executioner = "Executioner",
        bodyguard = "Bodyguard",
        tracker = "Tracker",
    }
    for alias, canonical in pairs(aliases) do
        if not lookup[alias] then
            lookup[alias] = canonical
        end
    end
    return lookup
end

local ROLE_LOOKUP = buildRoleLookup()

local function normalizeRoleName(value)
    if value == nil then
        return nil
    end
    local text = tostring(value):gsub("[%s%p]+", " "):lower():gsub("^%s*(.-)%s*$", "%1")
    if text == "" then
        return nil
    end
    if ROLE_LOOKUP[text] then
        return ROLE_LOOKUP[text]
    end
    for alias, canonical in pairs(ROLE_LOOKUP) do
        if alias ~= text and text:find(alias, 1, true) then
            return canonical
        end
    end
    return tostring(value)
end

-- ============== CONFIG ==============
local CONFIG = {
    autoRefreshInterval = 3,
    windowSize = UDim2.new(0, 380, 0, 480),
    primaryColor  = Color3.fromRGB(30, 30, 40),
    accentColor   = Color3.fromRGB(85, 130, 255),
    headerColor   = Color3.fromRGB(45, 45, 60),
    textColor     = Color3.fromRGB(230, 230, 240),
    dangerColor   = Color3.fromRGB(255, 80, 80),
    goodColor     = Color3.fromRGB(80, 220, 120),
    mutedColor    = Color3.fromRGB(150, 150, 170),
}

-- Known Flicker role colors
local ROLE_COLORS = {
    ["Murderer"]     = Color3.fromRGB(255, 60, 60),
    ["SerialKiller"] = Color3.fromRGB(255, 60, 60),
    ["Assassin"]     = Color3.fromRGB(255, 80, 80),
    ["Survivor"]     = Color3.fromRGB(80, 200, 120),
    ["Innocent"]     = Color3.fromRGB(80, 200, 120),
    ["Detective"]    = Color3.fromRGB(80, 150, 255),
    ["Sheriff"]      = Color3.fromRGB(80, 150, 255),
    ["Psychic"]      = Color3.fromRGB(180, 100, 255),
    ["Clown"]        = Color3.fromRGB(255, 180, 50),
    ["Twins"]        = Color3.fromRGB(255, 130, 200),
    ["Twin"]         = Color3.fromRGB(255, 130, 200),
    ["Savior"]       = Color3.fromRGB(100, 220, 255),
    ["Spy"]          = Color3.fromRGB(200, 200, 200),
    ["Scout"]        = Color3.fromRGB(150, 220, 100),
    ["Witch"]        = Color3.fromRGB(200, 100, 255),
    ["Executioner"]  = Color3.fromRGB(255, 100, 150),
    ["Bodyguard"]    = Color3.fromRGB(100, 180, 255),
    ["Tracker"]      = Color3.fromRGB(255, 200, 100),
}

-- ============== GUI BUILD ==============
local old = playerGui:FindFirstChild("FlickerRoleViewer")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "FlickerRoleViewer"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.Parent = playerGui

-- Main window
local main = Instance.new("Frame")
main.Size = CONFIG.windowSize
main.Position = UDim2.new(0.5, -190, 0.5, -240)
main.BackgroundColor3 = CONFIG.primaryColor
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = CONFIG.accentColor
mainStroke.Thickness = 1.5

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = CONFIG.headerColor
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

-- Patch bottom of title bar to be flat
local patch = Instance.new("Frame")
patch.Size = UDim2.new(1, 0, 0, 12)
patch.Position = UDim2.new(0, 0, 1, -12)
patch.BackgroundColor3 = CONFIG.headerColor
patch.BorderSizePixel = 0
patch.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "👁  Flicker Role Viewer"
title.TextColor3 = CONFIG.textColor
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = titleBar

-- Window buttons
local function makeWindowBtn(pos, text, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = pos
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = CONFIG.textColor
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Parent = titleBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local closeBtn = makeWindowBtn(UDim2.new(1, -32, 0, 4), "X", CONFIG.dangerColor)
local minBtn   = makeWindowBtn(UDim2.new(1, -64, 0, 4), "—", CONFIG.accentColor)

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 28)
tabBar.Position = UDim2.new(0, 8, 0, 44)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main
Instance.new("UIListLayout", tabBar).Padding = UDim.new(0, 4)

-- Pages container
local pages = Instance.new("Frame")
pages.Size = UDim2.new(1, -16, 1, -90)
pages.Position = UDim2.new(0, 8, 0, 76)
pages.BackgroundTransparency = 1
pages.Parent = main

-- Footer
local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, -16, 0, 32)
footer.Position = UDim2.new(0, 8, 1, -38)
footer.BackgroundColor3 = CONFIG.headerColor
footer.BorderSizePixel = 0
footer.Parent = main
Instance.new("UICorner", footer).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.5, -8, 1, 0)
statusLabel.Position = UDim2.new(0, 8, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = CONFIG.textColor
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = footer

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 60, 0, 22)
refreshBtn.Position = UDim2.new(1, -68, 0.5, -11)
refreshBtn.BackgroundColor3 = CONFIG.accentColor
refreshBtn.BorderSizePixel = 0
refreshBtn.Text = "Scan"
refreshBtn.TextColor3 = CONFIG.textColor
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 12
refreshBtn.Parent = footer
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 5)

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0, 70, 0, 22)
autoBtn.Position = UDim2.new(1, -142, 0.5, -11)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
autoBtn.BorderSizePixel = 0
autoBtn.Text = "Auto: Off"
autoBtn.TextColor3 = CONFIG.textColor
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 12
autoBtn.Parent = footer
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 5)

-- ============== TAB SYSTEM ==============
local tabs = {}

local function makeTab(name, displayName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.BackgroundColor3 = CONFIG.headerColor
    btn.BorderSizePixel = 0
    btn.Text = displayName
    btn.TextColor3 = CONFIG.mutedColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = pages

    tabs[name] = {button = btn, page = page}

    connectButton(btn, function()
        for n, t in pairs(tabs) do
            t.page.Visible = (n == name)
            if n == name then
                t.button.BackgroundColor3 = CONFIG.accentColor
                t.button.TextColor3 = CONFIG.textColor
            else
                t.button.BackgroundColor3 = CONFIG.headerColor
                t.button.TextColor3 = CONFIG.mutedColor
            end
        end
    end)

    return page
end

-- ============== SCROLLING LIST HELPER ==============
local function makeScrollingList(parent)
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, 0, 1, 0)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 4
    list.ScrollBarImageColor3 = CONFIG.accentColor
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Parent = parent
    Instance.new("UIListLayout", list).Padding = UDim.new(0, 4)
    return list
end

local roleListCache = {}

local function getGameDataReplica()
    if not DATA_CTRL then
        return nil
    end
    local ok, replica = pcall(function()
        return DATA_CTRL:GetFirstReplicaOfClass("GameData")
    end)
    if not ok or type(replica) ~= "table" then
        return nil
    end
    return replica
end

local function getPlayerNameFromPath(path)
    if type(path) ~= "string" then
        return nil
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if path:find(p.Name, 1, true) then
            return p.Name
        end
    end
    return nil
end

local function scanGameDataRoles()
    local replica = getGameDataReplica()
    if not replica or type(replica.Data) ~= "table" then
        roleListCache = {}
        return nil
    end

    local playersData = replica.Data.Players
    local rolelist = replica.Data.Rolelist
    if type(rolelist) ~= "table" then
        roleListCache = {}
        return nil
    end

    local roleEntries = {}
    for _, entry in ipairs(rolelist) do
        if type(entry) == "table" then
            for _, role in ipairs(entry) do
                local normalized = normalizeRoleName(role)
                if normalized then
                    table.insert(roleEntries, normalized)
                end
            end
        elseif type(entry) == "string" then
            local normalized = normalizeRoleName(entry)
            if normalized then
                table.insert(roleEntries, normalized)
            end
        end
    end

    roleListCache = {}
    for _, role in ipairs(roleEntries) do
        table.insert(roleListCache, role)
    end

    if #roleEntries > 0 and type(playersData) == "table" and #playersData == #roleEntries then
        local assignments = {}
        for idx, player in ipairs(playersData) do
            local playerName
            if type(player) == "string" then
                playerName = player
            elseif type(player) == "table" and type(player.Name) == "string" then
                playerName = player.Name
            end
            if playerName then
                assignments[playerName] = {
                    role = roleEntries[idx],
                    source = "GameData",
                    method = "GameData"
                }
            end
        end
        return assignments
    end

    return nil
end

local function clearList(list)
    for _, c in ipairs(list:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
    end
end

local function addRow(list, name, role, source)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 40)
    row.BackgroundColor3 = CONFIG.headerColor
    row.BorderSizePixel = 0
    row.LayoutOrder = #list:GetChildren()
    row.Parent = list
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    -- Avatar circle
    local avatar = Instance.new("Frame")
    avatar.Size = UDim2.new(0, 30, 0, 30)
    avatar.Position = UDim2.new(0, 5, 0.5, -15)
    avatar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    avatar.BorderSizePixel = 0
    avatar.Parent = row
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

    local initial = Instance.new("TextLabel")
    initial.Size = UDim2.new(1, 0, 1, 0)
    initial.BackgroundTransparency = 1
    initial.Text = string.upper(string.sub(name, 1, 1))
    initial.TextColor3 = CONFIG.textColor
    initial.Font = Enum.Font.GothamBold
    initial.TextSize = 14
    initial.Parent = avatar

    -- Player name + role
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -80, 0, 18)
    nameLabel.Position = UDim2.new(0, 40, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = CONFIG.textColor
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.Parent = row

    local roleColor = ROLE_COLORS[role] or CONFIG.mutedColor
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, -80, 0, 14)
    roleLabel.Position = UDim2.new(0, 40, 0, 22)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = role
    roleLabel.TextColor3 = roleColor
    roleLabel.TextXAlignment = Enum.TextXAlignment.Left
    roleLabel.Font = Enum.Font.Gotham
    roleLabel.TextSize = 11
    roleLabel.Parent = row

    -- Role badge
    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, 28, 0, 28)
    badge.Position = UDim2.new(1, -36, 0.5, -14)
    badge.BackgroundColor3 = roleColor
    badge.BorderSizePixel = 0
    badge.Parent = row
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)

    local badgeText = Instance.new("TextLabel")
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Text = string.sub(role, 1, 1):upper()
    badgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextSize = 13
    badgeText.Parent = badge

    -- Hover for source
    if source then
        row.MouseEnter:Connect(function() statusLabel.Text = "📍 " .. source end)
        row.MouseLeave:Connect(function() statusLabel.Text = "Ready" end)
    end
end

local function addCountRow(list, label, count, source)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 40)
    row.BackgroundColor3 = CONFIG.headerColor
    row.BorderSizePixel = 0
    row.LayoutOrder = #list:GetChildren()
    row.Parent = list
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -80, 0, 20)
    nameLabel.Position = UDim2.new(0, 8, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = label
    nameLabel.TextColor3 = CONFIG.textColor
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.Parent = row

    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, -80, 0, 14)
    countLabel.Position = UDim2.new(0, 8, 0, 22)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "Count: " .. tostring(count)
    countLabel.TextColor3 = CONFIG.mutedColor
    countLabel.TextXAlignment = Enum.TextXAlignment.Left
    countLabel.Font = Enum.Font.Gotham
    countLabel.TextSize = 11
    countLabel.Parent = row

    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, 28, 0, 28)
    badge.Position = UDim2.new(1, -36, 0.5, -14)
    badge.BackgroundColor3 = CONFIG.accentColor
    badge.BorderSizePixel = 0
    badge.Parent = row
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)

    local badgeText = Instance.new("TextLabel")
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Text = tostring(count)
    badgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextSize = 13
    badgeText.Parent = badge

    if source then
        row.MouseEnter:Connect(function() statusLabel.Text = "📍 " .. source end)
        row.MouseLeave:Connect(function() statusLabel.Text = "Ready" end)
    end
end

-- ============== SCAN LOGIC ==============
local roleCache = {}

local function deepScan(target, depth, maxDepth, results, keywords)
    if depth > maxDepth then return end
    local ok, children = pcall(function() return target:GetChildren() end)
    if not ok then return end
    for _, obj in ipairs(children) do
        if obj:IsA("ValueBase") then
            local val = tostring(obj.Value)
            for _, kw in ipairs(keywords) do
                if val:lower():find(kw) or obj.Name:lower():find(kw) then
                    table.insert(results, {
                        name = obj.Name,
                        value = val,
                        path = obj:GetFullName()
                    })
                    break
                end
            end
        elseif not obj:IsA("GuiObject") then
            deepScan(obj, depth + 1, maxDepth, results, keywords)
        end
    end
end

local KEYWORDS = {
    "role", "team", "class", "job", "alignment",
    "survivor", "murderer", "detective", "psychic",
    "clown", "twin", "savior", "spy", "scout",
    "witch", "executioner", "bodyguard", "tracker",
    "innocent", "guilty", "good", "evil"
}

local function scanRoles()
    roleCache = {}

    local gameDataAssignments = scanGameDataRoles()
    if gameDataAssignments then
        for name, data in pairs(gameDataAssignments) do
            if type(name) == "string" and type(data.role) == "string" then
                roleCache[name] = data
            end
        end
    end

    -- Method 1: Player values
    for _, p in ipairs(Players:GetPlayers()) do
        local r = {}
        deepScan(p, 0, 3, r, KEYWORDS)
        for _, hit in ipairs(r) do
            if not roleCache[p.Name] then
                local normalized = normalizeRoleName(hit.value)
                roleCache[p.Name] = {role = normalized or hit.value, source = hit.path, method = "Player"}
            end
        end
    end

    -- Method 2: ReplicatedStorage (cross-references player names)
    local rsHits = {}
    deepScan(RS, 0, 4, rsHits, KEYWORDS)
    for _, hit in ipairs(rsHits) do
        local playerName = getPlayerNameFromPath(hit.path)
        if playerName and not roleCache[playerName] then
            local normalized = normalizeRoleName(hit.value)
            roleCache[playerName] = {role = normalized or hit.value, source = hit.path, method = "Storage"}
        end
    end

    -- Method 3: PlayerGui text labels
    for _, p in ipairs(Players:GetPlayers()) do
        if p:FindFirstChild("PlayerGui") and not roleCache[p.Name] then
            for _, g in ipairs(p.PlayerGui:GetDescendants()) do
                if g:IsA("TextLabel") and g.Text and #g.Text < 30 then
                    local t = g.Text:lower()
                    for _, kw in ipairs(KEYWORDS) do
                        if t:find(kw) then
                            local normalized = normalizeRoleName(g.Text)
                            roleCache[p.Name] = {role = normalized or g.Text, source = g:GetFullName(), method = "GUI"}
                            break
                        end
                    end
                    if roleCache[p.Name] then break end
                end
            end
        end
    end

    return roleCache
end

-- ============== BUILD TABS ==============
local playersPage = makeTab("Players", "Players")
local playersList = makeScrollingList(playersPage)

local livePage = makeTab("Live", "Live Scan")
local liveList = makeScrollingList(livePage)

local rolesPage = makeTab("Roles", "Roles")
local rolesList = makeScrollingList(rolesPage)

local infoPage = makeTab("Info", "Info")
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -16, 1, -16)
infoText.Position = UDim2.new(0, 8, 0, 8)
infoText.BackgroundTransparency = 1
infoText.TextColor3 = CONFIG.textColor
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 12
infoText.TextWrapped = true
infoText.Text = [[
Flicker Role Viewer v1.0

3 scan methods:
  1. Player values (leaderstats, etc.)
  2. ReplicatedStorage (cross-refs names)
  3. ReplicatedStorage GameData and RoleInfo for Flicker roles
  4. PlayerGui text labels

How to use:
  • Click "Scan" to refresh
  • Toggle "Auto" for live updates (3s)
  • Hover any row → see data source
  • Drag title bar to move window
  • "—" to minimize, "X" to close

Limitations:
  • Only finds client-readable values
  • Some games hide roles server-side
  • Heuristic — may need a path hint
]]
infoText.Parent = infoPage

-- Activate first tab
tabs["Players"].button.MouseButton1Click:Fire()

-- ============== UPDATE FUNCTIONS ==============
local function updatePlayersList()
    clearList(playersList)
    if next(roleCache) == nil then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -8, 0, 60)
        empty.BackgroundTransparency = 1
        empty.Text = "No roles detected.\nClick 'Scan' to start."
        empty.TextColor3 = CONFIG.mutedColor
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 13
        empty.TextWrapped = true
        empty.Parent = playersList
        return
    end
    for name, data in pairs(roleCache) do
        addRow(playersList, name, data.role, data.source)
    end
end

local function updateLiveList()
    clearList(liveList)
    for _, p in ipairs(Players:GetPlayers()) do
        if roleCache[p.Name] then
            addRow(liveList, p.Name, roleCache[p.Name].role, roleCache[p.Name].source)
        else
            addRow(liveList, p.Name, "Unknown", nil)
        end
    end
end

local function updateRolesList()
    clearList(rolesList)
    if #roleListCache == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -8, 0, 60)
        empty.BackgroundTransparency = 1
        empty.Text = "No active role list found. Join a Flicker game and click Scan."
        empty.TextColor3 = CONFIG.mutedColor
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 13
        empty.TextWrapped = true
        empty.Parent = rolesList
        return
    end
    local counts = {}
    for _, role in ipairs(roleListCache) do
        counts[role] = (counts[role] or 0) + 1
    end
    for role, count in pairs(counts) do
        addCountRow(rolesList, role, count, "GameData Rolelist")
    end
end

-- ============== EVENTS ==============
connectButton(refreshBtn, function()
    statusLabel.Text = "Scanning..."
    task_wait(0.2)
    scanRoles()
    updatePlayersList()
    updateLiveList()
    updateRolesList()
    local count = 0
    for _ in pairs(roleCache) do count = count + 1 end
    statusLabel.Text = "✓ Found " .. count .. " role(s)"
end)

local autoOn = false
connectButton(autoBtn, function()
    autoOn = not autoOn
    if autoOn then
        autoBtn.Text = "Auto: On"
        autoBtn.BackgroundColor3 = CONFIG.goodColor
        autoBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    else
        autoBtn.Text = "Auto: Off"
        autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
        autoBtn.TextColor3 = CONFIG.textColor
    end
end)

task_spawn(function()
    while gui and gui.Parent do
        if autoOn then
            scanRoles()
            updatePlayersList()
            updateLiveList()
            updateRolesList()
            local count = 0
            for _ in pairs(roleCache) do count = count + 1 end
            statusLabel.Text = "⟳ Auto: " .. count .. " found"
        end
        task_wait(CONFIG.autoRefreshInterval)
    end
end)

local minimized = false
connectButton(minBtn, function()
    minimized = not minimized
    pages.Visible = not minimized
    footer.Visible = not minimized
    tabBar.Visible = not minimized
    main.Size = minimized and UDim2.new(0, 380, 0, 36) or CONFIG.windowSize
end)

connectButton(closeBtn, function()
    gui:Destroy()
end)

-- Initial scan
task_defer(function()
    scanRoles()
    updatePlayersList()
    updateLiveList()
    updateRolesList()
end)

print("[FlickerRoleViewer] Loaded ✓  Use the GUI to scan.")
