local v1 = game:GetService("ReplicatedStorage")
local v_u_2 = game:GetService("UserInputService")
local v_u_3 = require(v1.Common.Network)
local v_u_4 = require(v1.DataController)
local v_u_5 = require(v1.RoleInfo)
local v6 = v1.Modules
local v_u_7 = require(v6.Frame)
local v_u_8 = require(v6.Button)
local v_u_9 = require(v6.Tabs)
local v_u_10 = v1.Interface
local v_u_11 = require(script.Parent.MainController)
local v_u_12 = {
	["Evil"] = Color3.fromRGB(255, 85, 88),
	["Good"] = Color3.fromRGB(103, 225, 122),
	["Neutral"] = Color3.fromRGB(197, 197, 197)
}
local v_u_13 = {
	["Evil"] = 50,
	["Good"] = 0,
	["Neutral"] = 100
}
local v_u_14 = {
	"Goal",
	"Abilities",
	"Details",
	"Behavior"
}
return {
	["ApplyRoleInfo"] = function(_, p15, p16, p17) -- name: ApplyRoleInfo
		-- upvalues: (copy) v_u_5, (copy) v_u_12, (copy) v_u_14, (copy) v_u_10
		local v18 = v_u_5[p16]
		p15:WaitForChild("RoleName").Text = ("%* %*"):format(v18.Emoji, v18.Name)
		p15:WaitForChild("RoleAlignment").Text = v18.Side
		p15.RoleAlignment.TextColor3 = v_u_12[v18.Side]
		for _, v19 in p15:WaitForChild("Details"):GetChildren() do
			if v19:IsA("TextLabel") then
				v19:Destroy()
			end
		end
		local v20 = 0
		for _, v21 in v_u_14 do
			local v22
			if v21 == "Details" then
				v22 = p17
			else
				v22 = v18.Info[v21]
			end
			if v22 then
				local v23 = v_u_10.RoleDetailsTitle:Clone()
				v23.LayoutOrder = v20
				v23.Text = v21
				v23.LayoutOrder = v20
				v23.Parent = p15.Details
				local v24 = v20 + 1
				local v25 = v_u_10.RoleDetailsDescription:Clone()
				for _, v26 in v22 do
					if typeof(v26) == "string" then
						v25.Text = ("%*\n\226\128\162 %*"):format(v25.Text, v26)
					elseif typeof(v26) == "table" then
						v25.Text = ("%*\n\226\128\162 <font color=\"#%*\">%*</font>"):format(v25.Text, (v26[2] or Color3.new(0.9, 0.9, 0.9)):ToHex(), v26[1])
					end
				end
				v25.Text = string.gsub(v25.Text, "^%s*(.-)%s*$", "%1")
				v25.LayoutOrder = v24
				v25.Parent = p15.Details
				v20 = v24 + 1
			end
		end
		p15.Details.CanvasSize = UDim2.new(0, 0, 0, p15.Details:WaitForChild("UIListLayout").AbsoluteContentSize.Y)
	end,
	["Init"] = function(p27, p28) -- name: Init
		p27._player = p28
		p27._gui = p28.PlayerGui.NewUI
	end,
	["Start"] = function(p_u_29) -- name: Start
		-- upvalues: (copy) v_u_11, (copy) v_u_7, (copy) v_u_9, (copy) v_u_8, (copy) v_u_2, (copy) v_u_4, (copy) v_u_5, (copy) v_u_10, (copy) v_u_12, (copy) v_u_13, (copy) v_u_3
		p_u_29._frameObject = v_u_11:GetRoleInfo()
		p_u_29._frame = v_u_7.getFromObject(p_u_29._frameObject)
		p_u_29._tabsObject = p_u_29._frameObject.Main
		p_u_29._tabs = v_u_9.getFromObject(p_u_29._tabsObject)
		p_u_29._mobileButtonObject = p_u_29._gui.LeftPanel.Buttons.RoleInfo
		p_u_29._mobileButton = v_u_8.getFromObject(p_u_29._mobileButtonObject)
		p_u_29._frame:SetOpen(true)
		p_u_29._frame.StateChanged:Connect(function(p30)
			-- upvalues: (copy) p_u_29
			p_u_29._mobileButton:SetActive(p30)
		end)
		p_u_29._frame:SetOpen(true)
		p_u_29._mobileButtonObject.Activated:Connect(function()
			-- upvalues: (copy) p_u_29
			p_u_29._frame:ToggleOpen()
		end)
		v_u_2.InputBegan:Connect(function(p31, p32)
			-- upvalues: (copy) p_u_29
			if p32 then
				return
			elseif p31.UserInputType == Enum.UserInputType.Keyboard and p31.KeyCode == Enum.KeyCode.Tab then
				p_u_29._frame:ToggleOpen()
			end
		end)
		p_u_29._replica = v_u_4:GetFirstReplicaOfClass("GameData")
		local v33 = p_u_29._replica.Data.Rolelist
		local v34 = #p_u_29._replica.Data.Players
		local v_u_35 = p_u_29._tabsObject.Content.RoleList
		local v36 = v34
		local v37 = v36
		local v38 = v36
		v36 = v37
		v38 = v37
		for v39, v40 in v33 do
			local v41 = {}
			local v42 = {}
			for _, v43 in v40 do
				local v44 = v43 == "Twin" and v34 <= #v33 and "Survivor" or v43
				table.insert(v41, v44)
				local v45 = v_u_5[v44].Amount or 1
				table.insert(v42, v45)
			end
			local v46 = unpack
			v37 = v37 - math.max(v46(v42))
			local v47 = unpack
			v36 = v36 - math.min(v47(v42))
			local v48 = v_u_10.RoleListItem:Clone()
			local v49 = "Neutral"
			for v50, v_u_51 in v41 do
				local v52 = v_u_5[v_u_51]
				local v53 = v_u_10.RoleListItemButton:Clone()
				v53.Text = ("%* <font color=\"#%*\">%*</font>%*"):format(v52.Emoji, v_u_12[v52.Side]:ToHex(), v_u_51, (not v52.Amount or v52.Amount <= 1) and "" or (" (%*)"):format(v52.Amount))
				v53.LayoutOrder = v50 * 2 - 1
				v53.Parent = v48
				if v50 ~= #v41 then
					local v54 = v_u_10.RoleListItemLabel:Clone()
					v54.LayoutOrder = v50 * 2
					v54.Parent = v48
				end
				if v50 == 1 then
					v49 = v52.Side
				end
				v53.Activated:Connect(function()
					-- upvalues: (copy) p_u_29, (copy) v_u_35, (copy) v_u_51
					p_u_29:ApplyRoleInfo(v_u_35.RoleDetails, v_u_51)
					v_u_35.RoleDetails.Visible = true
					v_u_35.List.Visible = false
				end)
			end
			v48.LayoutOrder = v39 + v_u_13[v49]
			v48.Parent = v_u_35.List
			if v34 <= v39 then
				break
			end
		end
		if v36 > 0 then
			local v55 = v_u_10.RoleListItem:Clone()
			local v_u_56 = v_u_5.Survivor
			local v57 = v_u_10.RoleListItemButton:Clone()
			v57.Text = ("%* <font color=\"#%*\">%*</font> (%*%*)"):format(v_u_56.Emoji, v_u_12[v_u_56.Side]:ToHex(), v_u_56.Name, math.max(v37, 0), v37 == v36 and "" or ("-%*"):format(v36))
			v57.LayoutOrder = 1
			v57.Parent = v55
			v57.Activated:Connect(function()
				-- upvalues: (copy) p_u_29, (copy) v_u_35, (copy) v_u_56
				p_u_29:ApplyRoleInfo(v_u_35.RoleDetails, v_u_56.Name)
				v_u_35.RoleDetails.Visible = true
				v_u_35.List.Visible = false
			end)
			v55.LayoutOrder = v_u_13[v_u_56.Side] - 1
			v55.Parent = v_u_35.List
		end
		v_u_35.RoleDetails:WaitForChild("BackButton").Activated:Connect(function()
			-- upvalues: (copy) v_u_35
			v_u_35.RoleDetails.Visible = false
			v_u_35.List.Visible = true
		end)
		local v_u_58 = p_u_29._tabsObject.Content.MyRole
		local v_u_59 = nil
		v_u_3:BindEvents({
			["SendRoleInfo"] = function(p60, p61) -- name: SendRoleInfo
				-- upvalues: (ref) v_u_59, (copy) p_u_29, (copy) v_u_58
				if p60 == "Info" then
					v_u_59 = p61
					p_u_29:ApplyRoleInfo(v_u_58, p61)
				elseif p60 == "Details" then
					p_u_29:ApplyRoleInfo(v_u_58, v_u_59, p61)
				end
			end
		})
	end
}
