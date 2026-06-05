--[[
    FLICKER TRACKER v2 - ULTRA STABLE
    Mobile Safe | Arceus X Tested
]]

-- 1. Safe boot
local ok, err = pcall(function()
    local Players = game:GetService("Players")
    local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 15)
    if not PlayerGui then return end
    
    -- Remove old
    pcall(function()
        local old = PlayerGui:FindFirstChild("FT2")
        if old then old:Destroy() end
    end)
    
    -- 2. Create GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "FT2"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui
    
    -- Toggle button (left side, big touch target)
    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0, 10, 0.4, 0)
    btn.AnchorPoint = Vector2.new(0, 0.5)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.2
    btn.Text = "EYE"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    -- Main frame
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 300, 0, 400)
    main.Position = UDim2.new(0.5, -150, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    main.Visible = false
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local ms = Instance.new("UIStroke", main)
    ms.Color = Color3.fromRGB(100, 100, 110)
    ms.Thickness = 1
    
    -- Title bar
    local tb = Instance.new("Frame", main)
    tb.Size = UDim2.new(1, 0, 0, 40)
    tb.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 10)
    local fix = Instance.new("Frame", tb)
    fix.Size = UDim2.new(1, 0, 0, 12)
    fix.Position = UDim2.new(0, 0, 1, -12)
    fix.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    fix.BorderSizePixel = 0
    
    local ttl = Instance.new("TextLabel", tb)
    ttl.Size = UDim2.new(1, -40, 1, 0)
    ttl.Position = UDim2.new(0, 10, 0, 0)
    ttl.BackgroundTransparency = 1
    ttl.Text = "Flicker Tracker"
    ttl.TextColor3 = Color3.new(1, 1, 1)
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.TextSize = 15
    ttl.Font = Enum.Font.GothamBold
    
    -- Close X
    local cls = Instance.new("TextButton", tb)
    cls.Size = UDim2.new(0, 30, 0, 30)
    cls.Position = UDim2.new(1, -35, 0, 5)
    cls.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    cls.Text = "X"
    cls.TextColor3 = Color3.new(1, 1, 1)
    cls.TextSize = 16
    cls.Font = Enum.Font.GothamBold
    Instance.new("UICorner", cls).CornerRadius = UDim.new(0, 6)
    
    -- Hint
    local hint = Instance.new("TextLabel", main)
    hint.Size = UDim2.new(1, -10, 0, 18)
    hint.Position = UDim2.new(0, 8, 0, 42)
    hint.BackgroundTransparency = 1
    hint.Text = "Tap player: ? -> Evil -> Good"
    hint.TextColor3 = Color3.fromRGB(140, 140, 150)
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.TextSize = 10
    hint.Font = Enum.Font.Gotham
    
    -- Player scroll list
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -10, 1, -65)
    scroll.Position = UDim2.new(0, 5, 0, 60)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 4)
    
    -- 3. State storage
    local tags = {} -- [name] = true=evil / false=good / nil=?
    
    -- 4. Build list
    local function refresh()
        pcall(function()
            -- Clear old rows
            for _, c in ipairs(scroll:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            
            -- Sort players
            local plist = Players:GetPlayers()
            table.sort(plist, function(a, b) return a.Name:lower() < b.Name:lower() end)
            
            -- Add row per player
            for _, player in ipairs(plist) do
                if player ~= Players.LocalPlayer then -- Skip yourself
                    local row = Instance.new("TextButton", scroll)
                    row.Size = UDim2.new(1, 0, 0, 35)
                    row.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
                    row.Text = ""
                    row.AutoButtonColor = false
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
                    
                    -- Color circle
                    local state = tags[player.Name]
                    local color = Color3.fromRGB(120, 120, 120) -- gray = unknown
                    local label = "?"
                    if state == true then
                        color = Color3.fromRGB(220, 30, 30)
                        label = "EVIL"
                    elseif state == false then
                        color = Color3.fromRGB(30, 200, 60)
                        label = "GOOD"
                    end
                    
                    local circ = Instance.new("Frame", row)
                    circ.Size = UDim2.new(0, 16, 0, 16)
                    circ.Position = UDim2.new(0, 8, 0.5, -8)
                    circ.BackgroundColor3 = color
                    circ.BorderSizePixel = 0
                    Instance.new("UICorner", circ).CornerRadius = UDim.new(1, 0)
                    
                    -- Name
                    local nm = Instance.new("TextLabel", row)
                    nm.Size = UDim2.new(1, -90, 1, 0)
                    nm.Position = UDim2.new(0, 30, 0, 0)
                    nm.BackgroundTransparency = 1
                    nm.Text = player.Name
                    nm.TextColor3 = Color3.new(1, 1, 1)
                    nm.TextXAlignment = Enum.TextXAlignment.Left
                    nm.TextSize = 13
                    nm.Font = Enum.Font.Gotham
                    
                    -- Tag label
                    local tg = Instance.new("TextLabel", row)
                    tg.Size = UDim2.new(0, 55, 1, 0)
                    tg.Position = UDim2.new(1, -60, 0, 0)
                    tg.BackgroundTransparency = 1
                    tg.Text = label
                    tg.TextColor3 = color
                    tg.TextXAlignment = Enum.TextXAlignment.Right
                    tg.TextSize = 11
                    tg.Font = Enum.Font.GothamBold
                    
                    -- Tap to cycle: ? -> evil -> good -> ?
                    row.MouseButton1Click:Connect(function()
                        pcall(function()
                            local s = tags[player.Name]
                            if s == nil then tags[player.Name] = true
                            elseif s == true then tags[player.Name] = false
                            else tags[player.Name] = nil end
                            refresh()
                        end)
                    end)
                end
            end
        end)
    end
    
    -- 5. Toggle logic
    local isOpen = false
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            isOpen = not isOpen
            main.Visible = isOpen
            if isOpen then refresh() end
        end)
    end)
    
    cls.MouseButton1Click:Connect(function()
        pcall(function()
            isOpen = false
            main.Visible = false
        end)
    end)
    
    -- 6. Update on join/leave (no tight loop!)
    Players.PlayerAdded:Connect(function()
        if isOpen then pcall(refresh) end
    end)
    
    Players.PlayerRemoving:Connect(function(p)
        pcall(function()
            tags[p.Name] = nil
            if isOpen then refresh() end
        end)
    end)
    
    -- 7. Done
    print("[Flicker Tracker] Loaded! Tap the EYE button.")
end)

if not ok then
    warn("[Flicker Tracker] FAILED TO LOAD: " .. tostring(err))
end
