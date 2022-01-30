local katanaModule = {}
local ContextActionService = game:GetService("ContextActionService")
local katanaClickRemote = game:GetService("ReplicatedStorage").Remotes.katanaClick
local katanaEquip = game:GetService("ReplicatedStorage").Remotes.katanaEquip
local katanaClickRemote = game:GetService("ReplicatedStorage").Remotes.katanaClick
local katanaDamageRemote = game:GetService("ReplicatedStorage").Remotes.katanaDamage
local specialAttacksModule = require(game:GetService("ReplicatedStorage").Modules.specialAttacks)
local RunService = game:GetService("RunService")
local ACTION_EQUIP = "Equip"
local ACTION_Attack = "Attack"
local ACTION_HeavySlash = "HeavySlash"
local ACTION_PARRY = "Parry"
local EquipDebounce = os.clock()
local equipped = false
local count
local CollectionService = game:GetService("CollectionService")
local katanaHitEffects = game:GetService("ReplicatedStorage").Remotes.katanaHitEffects

local part = Instance.new("Part")
local overlapParams = OverlapParams.new()

local function contextActionEquip(actionName, inputState, inputObject)
	if (os.clock() - EquipDebounce) < 1 then return end
	local player = game.Players.LocalPlayer
	count = 1
	if actionName == ACTION_EQUIP and inputState == Enum.UserInputState.Begin then
		if equipped == false then
			equipped = true
			print("Equipping")
			katanaModule:EquipKatanaAnimations(player)
			katanaEquip:FireServer(true)
		else
			equipped = false
			print("Unequepping")
			katanaModule:RemoveKatanaAnimations(player)
			katanaEquip:FireServer(false)
		end
		EquipDebounce = os.clock()
	end
end


local function contextActionServiceAttack(actionName, inputState, inputObject)
		if actionName == ACTION_Attack and inputState == Enum.UserInputState.Begin then
		if equipped == true then
			local char = game.Players.LocalPlayer.Character
			if CollectionService:HasTag(char, "Parry") then return end
			katanaClickRemote:FireServer()
			end
		end
end



local function contextActionServiceHeavySlash(actionName, inputState, inputObject)
	if actionName == ACTION_HeavySlash and inputState == Enum.UserInputState.Begin then
		if equipped == true then
			local char = game.Players.LocalPlayer.Character
			warn("Heavy Slash")
			specialAttacksModule:HeavySlashClient()
		end
	end
end

local function contextActionServiceParry(actionName, inputState, inputObject)
	if actionName == ACTION_PARRY and inputState == Enum.UserInputState.Begin then
		if equipped == true then
			specialAttacksModule:ClientParry("Start")
		end
	elseif actionName == ACTION_PARRY and inputState == Enum.UserInputState.End then
		if equipped == true then
			print("ended")
			specialAttacksModule:ClientParry("Stop")
		end
	end
end

pcall(function()
	ContextActionService:BindAction(ACTION_EQUIP, contextActionEquip, true, Enum.KeyCode.Q)
	ContextActionService:BindAction(ACTION_Attack, contextActionServiceAttack, true, Enum.UserInputType.MouseButton1)
	ContextActionService:BindAction(ACTION_HeavySlash, contextActionServiceHeavySlash, true, Enum.KeyCode.X)
	ContextActionService:BindAction(ACTION_PARRY, contextActionServiceParry, true, Enum.KeyCode.F)
end)

local function weldKatana(object, objectToWeldTo)
	local weld = Instance.new("WeldConstraint")
	weld.Parent = object
	weld.Part0 = object
	weld.Part1 = objectToWeldTo
end

local AnimSlice1 = Instance.new("Animation")
AnimSlice1.AnimationId = "rbxassetid://8444462186"

local AnimSlice2 = Instance.new("Animation")
AnimSlice2.AnimationId = "rbxassetid://8444465075"

local AnimSlice3 = Instance.new("Animation")
AnimSlice3.AnimationId = "rbxassetid://8444466934"

local AnimSlice4 = Instance.new("Animation")
AnimSlice4.AnimationId = "rbxassetid://8444873166"

local hitAnim = Instance.new("Animation")
hitAnim.AnimationId = "rbxassetid://8522440400"

function katanaModule:EquipKatana(player, isEquipped)
	local char = player.Character
	self.player = player
	local katanaName = "KatanaMesh"
	if isEquipped == true then
		local katana = game:GetService("ReplicatedStorage").KatanaMesh:Clone()
		katana.Parent = char
		self.katana = katana
		self.katana.CanCollide = false
		self.katana.CFrame = char.RightHand.CFrame * CFrame.new(0,0,-2) * CFrame.Angles(math.rad(-90),math.rad(180),0)
		weldKatana(self.katana, char.RightHand)
	else
		self.katana:Destroy()
	end
end

function katanaModule:EquipKatanaAnimations(player)
	print(player)
	local char = player.Character
	self.char = char
	if equipped == true then
		local AnimationScript = char:FindFirstChild("Animate")
		AnimationScript.idle.Animation1.AnimationId = "rbxassetid://8443255855"
		AnimationScript.idle.Animation2.AnimationId = "rbxassetid://8443255855"
		AnimationScript.run.RunAnim.AnimationId = "rbxassetid://8443258584"
		if char.Humanoid.MoveDirection.Magnitude ~= 0 then
			print("running")
			local Anim = Instance.new("Animation")
			Anim.AnimationId = "rbxassetid://8443258584"
			local runAnim = char.Humanoid:LoadAnimation(Anim)
			runAnim:Play()
		else
			print("not running")
			local Anim = Instance.new("Animation")
			Anim.AnimationId = "rbxassetid://8443255855"
			local idleAnim = char.Humanoid:LoadAnimation(Anim)
			idleAnim:Play()
		end
	end
end

function katanaModule:RemoveKatanaAnimations(player)
	print(player)
	if equipped == false then
		local char = player.Character
		local AnimationScript = char:FindFirstChild("Animate")
		AnimationScript.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=507766388"
		AnimationScript.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=507766666"
		AnimationScript.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=913376220"
		if char.Humanoid.MoveDirection.Magnitude ~= 0 then
			print("running")
			local Anim = Instance.new("Animation")
			Anim.AnimationId = "http://www.roblox.com/asset/?id=913376220"
			local runAnim = char.Humanoid:LoadAnimation(Anim)
			runAnim:Play()
		else
			print("not running")
			local Anim = Instance.new("Animation")
			Anim.AnimationId = "http://www.roblox.com/asset/?id=507766388"
			local idleAnim = char.Humanoid:LoadAnimation(Anim)
			idleAnim:Play()
		end
	end
end



function katanaModule:ServerReceived(player, Debounce, Cooldown)
	if table.find(Debounce, player.UserId) ~= nil then
		--print(player.Name.. " Is Under Debounce")
	else
		print("Server Received")
		katanaClickRemote:FireClient(player)
		--put hitBox spawning code here
	end
end