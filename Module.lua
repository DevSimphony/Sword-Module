local swordModule = {}
swordModule.__index = swordModule
local ComboTable
local remote = game:GetService("ReplicatedStorage").Remotes.remote

function swordModule.New(Owner, Damage, Sword, Swing1, Swing2, Swing3, Swing4)
	local newSword = {}
	newSword.Damage = Damage
	newSword.Sword = Sword:Clone()
	newSword.Owner = Owner
	newSword.Swing1 = Swing1
	newSword.Swing2 = Swing2
	newSword.Swing3 = Swing3
	newSword.Swing4 = Swing4
	newSword.Combo = 1
	newSword.Debounce = false
	newSword.DebounceTime = 0.55
	setmetatable(newSword, swordModule)
	return newSword
end

function swordModule:GiveSword()
	print(self.Sword)
	self.Sword.Parent = self.Owner.Backpack
	self.Sword.Activated:Connect(function()
		self:Attack()
	end)
end


local timePassed = os.clock()
function swordModule:Attack()
	if self.Debounce == false then
		self.Debounce = true
		local char = self.Owner.Character or self.Owner.CharacterAdded:Wait()
		ComboTable = {
			self.Swing1,
			self.Swing2,
			self.Swing3,
			self.Swing4
		}
		print("test")
		if (os.clock() - timePassed) >= 1 then 
			self.Combo = 1
		else
			if self.Combo ~= 4 then
				self.Combo += 1
			else
				self.Combo = 1
			end
		end
		timePassed = os.clock()
		--print(self.Combo)
		--print(ComboTable[self.Combo])
		local anim = char.Humanoid:LoadAnimation(ComboTable[self.Combo])
		anim:Play()
		for _,trail in pairs(self.Sword:GetDescendants()) do
			if trail:IsA("Trail") then
				trail.Enabled = true
				task.spawn(function()
					task.wait(0.6)
					trail.Enabled = false
				end)
			end
		end
		self:HitBox()
		anim.Stopped:Wait()
		self.Debounce = false
	end
end

function swordModule:HitBox()
	local overLapParams = OverlapParams.new()
	local swordSwing = game.ReplicatedStorage.Sounds.swordSwing:Clone()
	swordSwing.Parent = self.Owner.Character
	local swordHit
	swordSwing:Play()
	local hitBox = Instance.new("Part")
	hitBox.Parent = self.Owner.Character
	hitBox.CanCollide = false
	hitBox.BrickColor = BrickColor.new("Really red")
	hitBox.Transparency = 0.8
	hitBox.Size = self.Sword.Handle.Size
	hitBox.Name = "hitBox"
	hitBox.CFrame = self.Sword.Handle.CFrame
	local weld = Instance.new("WeldConstraint")
	weld.Parent = hitBox
	weld.Part0 = self.Sword.Handle
	weld.Part1 = hitBox
	local playerTable = {}
	local heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
		task.wait()
		for _, v in pairs(workspace:GetPartsInPart(hitBox, overLapParams)) do
			if not table.find(playerTable, v.Parent) and v.Parent ~= self.Owner.Character and v.Parent:FindFirstChild("Humanoid") then  
				table.insert(playerTable, v.Parent)
				print(v.Parent)
				local humanoid = v.Parent.Humanoid
				humanoid:TakeDamage(self.Damage)
				swordHit = game.ReplicatedStorage.Sounds.swordHit:Clone()
				swordHit.Parent = v.Parent
				swordHit:Play()
				task.spawn(function()
					task.wait(1)
					swordHit:Destroy()
				end)
			end
		end
	end)
	
	task.spawn(function()
		task.wait(0.6)
		hitBox:Destroy()
		heartbeat:Disconnect()
		swordSwing:Destroy()
	end)
	
end

return swordModule