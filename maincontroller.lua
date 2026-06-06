local v1 = game:GetService("ReplicatedStorage")
local v_u_2 = game:GetService("CollectionService")
game:GetService("GuiService")
game:GetService("TextChatService")
require(v1.Common.Network)
local v_u_3 = require(v1.Modules.Button)
local v4 = {}
require("./SendNoteController")
function v4.UpdateScale(p5) -- name: UpdateScale
	local v6 = workspace.CurrentCamera.ViewportSize.Y
	local v7 = v6 <= 600
	p5._gui:SetAttribute("IsShortScreen", v7)
	local v8
	if v7 then
		local v9 = v6 / 550 * 10
		local v10 = math.floor(v9) / 10
		v8 = math.max(v10, 0.7)
	elseif v6 > 677 then
		local v11 = (677 + (v6 - 677) * 0.65) / 677 * 10
		v8 = math.floor(v11) / 10
	else
		local v12 = v6 / 677 * 10
		v8 = math.floor(v12) / 10
	end
	p5._scale = v8
	for _, v13 in p5._player.PlayerGui:GetChildren() do
		if v13:IsA("ScreenGui") then
			local v14 = v13:FindFirstChildOfClass("UIScale")
			if v14 then
				v14.Scale = v8
			end
		end
	end
	local v15 = p5._gui:WaitForChild("LeftPanel")
	local v16 = p5._gui:WaitForChild("RightPanel")
	local v17 = v16:WaitForChild("PlayerList")
	p5._gui.LeftPanel.Buttons.RoleInfo.Visible = v7
	local v18 = v7 and 1 or 0
	local v19 = UDim.new(v7 and 1 or 0, 0)
	local v20 = p5._roleInfo
	if v7 then
		v16 = v15:WaitForChild("RoleContainer")
	end
	v20.Parent = v16
	p5._roleInfo:WaitForChild("Minimize").Visible = not v7
	p5._roleInfo.AnchorPoint = Vector2.new(1, v18)
	p5._roleInfo.Position = UDim2.new(UDim.new(1, 0), v19)
	p5._roleInfo:SetAttribute("AnchorY", v18)
	p5._roleInfo:SetAttribute("PositionY", v19)
	p5._roleInfo:SetAttribute("CloseToLeft", v7)
	local v21 = v7 and 0 or 1
	local v22 = UDim.new(v7 and 0 or 1, 0)
	v17.Size = UDim2.new(0, 280, v7 and 0.65 or 0.55, 0)
	v17.Position = UDim2.new(UDim.new(0.5, 0), v22)
	v17.AnchorPoint = Vector2.new(0.5, v21)
	v17:WaitForChild("UISizeConstraint").MaxSize = Vector2.new((1 / 0), v7 and (1 / 0) or 400)
	v17:WaitForChild("Minimize").Position = UDim2.new(0, -12, v7 and 0 or 1, v7 and -4 or 4)
	v17.Minimize.AnchorPoint = Vector2.new(1, v7 and 0 or 1)
	v17:SetAttribute("AnchorY", v21)
	v17:SetAttribute("PositionY", v22)
end
function v4.UpdateVisibility(p23) -- name: UpdateVisibility
	-- upvalues: (copy) v_u_3
	local v24 = p23._player.Team.Name == "Alive"
	local v25 = p23._gui:WaitForChild("LeftPanel")
	p23._gui:SetAttribute("IsAlive", v24)
	p23._roleInfo.Visible = v24
	v25:WaitForChild("Buttons").Visible = v24
	v25:WaitForChild("ReturnToLobby").Visible = not v24
	v25:WaitForChild("RejoinQueue").Visible = not v24
	if not v24 then
		p23._gui:WaitForChild("MyJournal").Visible = false
		p23._gui:WaitForChild("SendNote").Visible = false
		p23._gui:WaitForChild("Results").Visible = false
		local v26 = p23._player.Character and p23._player.Character:FindFirstChildOfClass("Humanoid")
		if v26 then
			v26:UnequipTools()
		end
	end
	for _, v27 in v25.Buttons:GetChildren() do
		if v27:IsA("TextButton") then
			local v28 = v_u_3.getFromObject(v27)
			if v28 then
				v28:SetActive(false, true)
			end
		end
	end
end
function v4.ScrollAdded(p_u_29, p_u_30) -- name: ScrollAdded
	if p_u_30 and (p_u_30.Parent and (p_u_30:IsA("UIListLayout") and p_u_30.Parent:IsA("ScrollingFrame"))) then
		local function v33() -- name: upd
			-- upvalues: (copy) p_u_30, (copy) p_u_29
			local v31 = p_u_30.AbsoluteContentSize.Y
			local v32 = p_u_30.Parent:FindFirstChildOfClass("UIPadding")
			if v32 then
				v31 = v31 + v32.PaddingTop.Offset + v32.PaddingBottom.Offset
			end
			p_u_30.Parent.CanvasSize = UDim2.new(0, 0, 0, v31 / p_u_29._gui.UIScale.Scale)
		end
		v33()
		p_u_30:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(v33)
		p_u_29._gui.UIScale:GetPropertyChangedSignal("Scale"):Connect(v33)
	end
end
function v4.GetRoleInfo(p34) -- name: GetRoleInfo
	return p34._roleInfo
end
function v4.Init(p35, p36) -- name: Init
	p35._player = p36
	p35._gui = p36.PlayerGui.NewUI
	p35._roleInfo = p35._gui.RightPanel.RoleInfo
	p35._scale = 1
end
function v4.Start(p_u_37) -- name: Start
	-- upvalues: (copy) v_u_2
	p_u_37:UpdateScale()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		-- upvalues: (copy) p_u_37
		p_u_37:UpdateScale()
	end)
	p_u_37:UpdateVisibility()
	p_u_37._player:GetPropertyChangedSignal("Team"):Connect(function()
		-- upvalues: (copy) p_u_37
		p_u_37:UpdateVisibility()
	end)
	for _, v38 in v_u_2:GetTagged("AutoSizeScroll") do
		p_u_37:ScrollAdded(v38)
	end
	v_u_2:GetInstanceAddedSignal("AutoSizeScroll"):Connect(function(p39)
		-- upvalues: (copy) p_u_37
		p_u_37:ScrollAdded(p39)
	end)
end
return v4
