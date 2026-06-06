game:GetService("Players")
local v1 = game:GetService("ReplicatedStorage"):WaitForChild("Dependencies")
local v_u_2 = require(v1:WaitForChild("ReplicaController"))
local v_u_3 = require(v1:WaitForChild("ScriptSignal"))
local v_u_4 = {}
v_u_4.__index = v_u_4
function v_u_4.new() -- name: new
	-- upvalues: (copy) v_u_4, (copy) v_u_3, (copy) v_u_2
	local v_u_5 = {
		["Replicas"] = {}
	}
	local v6 = v_u_4
	setmetatable(v_u_5, v6)
	v_u_5.ReplicaAdded = v_u_3.new()
	v_u_2.NewReplicaSignal:Connect(function(p7)
		-- upvalues: (copy) v_u_5
		local v8 = p7.Class
		local v9 = p7.Tags.Target
		print("Replica of class " .. v8 .. " created with Id " .. p7.Id)
		if not v_u_5.Replicas[v8] then
			v_u_5.Replicas[v8] = {}
		end
		v_u_5.Replicas[v8][v9 or p7.Id] = p7
		v_u_5.ReplicaAdded:Fire(v8, p7)
	end)
	v_u_2.RequestData()
	return v_u_5
end
function v_u_4.GetPlayerReplica(p10, p11) -- name: GetPlayerReplica
	if not (p10.Replicas.PlayerProfile and p10.Replicas.PlayerProfile[p11]) then
		repeat
			p10.ReplicaAdded:Wait()
		until p10.Replicas.PlayerProfile and p10.Replicas.PlayerProfile[p11]
	end
	return p10.Replicas.PlayerProfile[p11]
end
function v_u_4.GetFirstReplicaOfClass() -- name: GetFirstReplicaOfClass
	-- -- failed to decompile
end
return v_u_4.new()
