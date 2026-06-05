-- Flicker Client-Side Remote Spy
-- Requires a client-side executor (e.g., Arceus X) to run.
-- This is a simplified version focusing only on the remote logging features.

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Safely get the PlayerGui with a timeout
local playerGui = player:FindFirstChild("PlayerGui")
if not playerGui then
    playerGui = player:WaitForChild("PlayerGui", 10)
end
if not playerGui then return end

-- State
local logs = {}
local maxLogs = 30
local isSpying = true

-- === UI SETUP ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClientRemoteSpy"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Text = "SPY"
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn)

-- Log Panel
local logPanel = Instance.new("ScrollingFrame")
logPanel.Size = UDim2.new(0, 320, 0, 350)
logPanel.Position = UDim2.new(0, 65, 0.5, -175)
logPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
logPanel.BorderSizePixel = 0
logPanel.ScrollBarThickness = 5
logPanel.Visible = false
logPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
logPanel.Parent = screenGui
Instance.new("UICorner", logPanel)

local logLayout = Instance.new("UIListLayout", logPanel)
logLayout.Padding = UDim.new(0, 2)

-- === LOGGING LOGIC ===
local function formatArgs(args)
    local str = ""
    local limit = math.min(#args, 3)
    for i = 1, limit do
        str = str .. tostring(args[i])
        if i < limit then str = str .. ", " end
    end
    if #args > 3 then str = str .. "..." end
    return str
end

local function addLog(dir, name, args)
    if not isSpying then return end
    table.insert(logs, 1, {
        dir = dir,
        name = name,
        argStr = formatArgs(args)
    })
    while #logs > maxLogs do table.remove(logs) end
    pcall(refreshLogUI)
end

-- Rebuild the log list UI
function refreshLogUI()
    if not logPanel then return end
    for _, c in ipairs(logPanel:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    for _, entry in ipairs(logs) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.RichText = true
        lbl.TextSize = 11
        lbl.Font = Enum.Font.Code
        local color = entry.dir == "IN" and "100,200,255" or "255,180,100"
        lbl.Text = string.format(
            '<font color="rgb(%s)">[%s]</font> %s (%s)',
            color, entry.dir, entry.name, entry.argStr
        )
        lbl.Parent = logPanel
    end
    logPanel.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 5)
end

-- UI Button Interaction
toggleBtn.MouseButton1Click:Connect(function()
    isSpying = not isSpying
    logPanel.Visible = isSpying
    toggleBtn.Text = isSpying and "SPY" or "OFF"
end)

-- === 1. HOOK FIRE SERVER (Client -> Server) ===
-- Hooks the metatable to catch when the client sends data to the server.
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" then
            addLog("OUT", self.Name, {...})
        end
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
end)

-- === 2. HOOK FIRE CLIENT (Server -> Client) ===
-- Listens to incoming events on the client side to log server data.
local function hookRemote(remote)
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        pcall(function()
            remote.OnClientEvent:Connect(function(...)
                addLog("IN", remote.Name, {...})
            end)
        end)
    end
end

-- Hook existing remotes
for _, v in ipairs(game:GetDescendants()) do
    hookRemote(v)
end

-- Hook new remotes as they are added (e.g., loaded during gameplay)
game.DescendantAdded:Connect(function(v)
    task.wait(0.1)
    hookRemote(v)
end)

print("[Client-Side Remote Spy] Loaded ✓")
