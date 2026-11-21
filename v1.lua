local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local AdminHubModules = {}

AdminHubModules.State = {
	AntiHit = false,
	AntiKick = false,
	AutoSteal = false,
	StealRadius = 35,
	StealInterval = 0.45,

	-- Pengaturan Emote Ngonten
	AutoEmote = false,
	EmoteMode = "CHAT", -- "CHAT" atau "ANIMATION"
	EmoteInterval = 3.5,
	EmoteIndex = 1,
}

AdminHubModules.ChatEmotes = {
	"/e dance",
	"/e dance2",
	"/e dance3",
	"/e wave",
	"/e cheer",
	"/e laugh",
	"/e point",
}

-- Isi dengan Roblox Animation Asset ID milikmu jika memakai mode "ANIMATION"
AdminHubModules.AnimationIds = {
	-- "rbxassetid://507771019",
	-- "rbxassetid://507776043",
}

local activeTrack = nil

local function stopCurrentAnimation()
	if activeTrack then
		pcall(function()
			activeTrack:Stop(0.15)
			activeTrack:Destroy()
		end)
		activeTrack = nil
	end
end

local function playAnimationId(assetId)
	if type(assetId) ~= "string" or assetId == "" then return false end
	local char = LocalPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end

	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	stopCurrentAnimation()

	local anim = Instance.new("Animation")
	anim.AnimationId = assetId

	local ok, track = pcall(function()
		return animator:LoadAnimation(anim)
	end)
	anim:Destroy()

	if ok and track then
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = true
		pcall(function()
			track:Play(0.15)
		end)
		activeTrack = track
		return true
	end
	return false
end

local function triggerChatEmote(cmd)
	if type(cmd) ~= "string" or cmd == "" then return false end
	local ok = pcall(function()
		LocalPlayer:Chat(cmd)
	end)
	return ok
end

function AdminHubModules.PlayNextEmote()
	local state = AdminHubModules.State
	if state.EmoteMode == "ANIMATION" and #AdminHubModules.AnimationIds > 0 then
		local idx = ((state.EmoteIndex - 1) % #AdminHubModules.AnimationIds) + 1
		state.EmoteIndex = (idx % #AdminHubModules.AnimationIds) + 1
		return playAnimationId(AdminHubModules.AnimationIds[idx])
	else
		local list = AdminHubModules.ChatEmotes
		if #list == 0 then return false end
		local idx = ((state.EmoteIndex - 1) % #list) + 1
		state.EmoteIndex = (idx % #list) + 1
		return triggerChatEmote(list[idx])
	end
end

function AdminHubModules.SetAutoEmote(enabled)
	AdminHubModules.State.AutoEmote = enabled
	if not enabled then
		stopCurrentAnimation()
	else
		AdminHubModules.PlayNextEmote()
	end
end

-- ==========================================
-- 1. ANTI-HIT (Perlindungan Knockback & State)
-- ==========================================
local function applyAntiHitProtection(character)
	stopCurrentAnimation()
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoid then
		humanoid.StateChanged:Connect(function(_, newState)
			if AdminHubModules.State.AntiHit then
				if newState == Enum.HumanoidStateType.Ragdoll
					or newState == Enum.HumanoidStateType.FallingDown
					or newState == Enum.HumanoidStateType.PlatformStanding then
					pcall(function()
						humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
					end)
				end
			end
		end)
	end

	if rootPart then
		rootPart.ChildAdded:Connect(function(child)
			if AdminHubModules.State.AntiHit then
				if child:IsA("BodyVelocity") or child:IsA("LinearVelocity") or child:IsA("VectorForce") then
					pcall(function()
						child:Destroy()
					end)
				end
			end
		end)
	end
end

-- ==========================================
-- 2. ANTI-KICK (Anti-Idle)
-- ==========================================
LocalPlayer.Idled:Connect(function()
	if AdminHubModules.State.AntiKick then
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
end)

-- ==========================================
-- 3. AUTO-STEAL (Pencarian Target & Interaksi)
-- ==========================================
local function getTargetPart(instance)
	if not instance or not instance.Parent then return nil end
	if instance:IsA("BasePart") then
		return instance
	end
	if instance:IsA("Model") then
		return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
	end
	return nil
end

local function findNearestStealable(rootPart, maxRadius)
	local nearestPart, shortestDist = nil, maxRadius or 35

	for _, obj in ipairs(workspace:GetDescendants()) do
		if LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character) then
			continue
		end

		local lowerName = string.lower(obj.Name)
		if string.find(lowerName, "egg") or string.find(lowerName, "steal") or string.find(lowerName, "loot") then
			local part = getTargetPart(obj)
			if part then
				local dist = (part.Position - rootPart.Position).Magnitude
				if dist <= shortestDist then
					shortestDist = dist
					nearestPart = part
				end
			end
		end
	end

	return nearestPart, shortestDist
end

local function triggerNearbyPrompts(rootPart, radius)
	for _, desc in ipairs(workspace:GetDescendants()) do
		if desc:IsA("ProximityPrompt") and desc.Enabled and desc.Parent then
			local promptPart = getTargetPart(desc.Parent)
			if promptPart and (promptPart.Position - rootPart.Position).Magnitude <= radius then
				local firePrompt = rawget(_G, "fireproximityprompt") or (getgenv and getgenv().fireproximityprompt)
				if type(firePrompt) == "function" then
					pcall(function()
						firePrompt(desc)
					end)
				else
					pcall(function()
						desc:InputHoldBegin()
						task.wait(0.05)
						desc:InputHoldEnd()
					end)
				end
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(AdminHubModules.State.StealInterval)
		if AdminHubModules.State.AutoSteal then
			local char = LocalPlayer.Character
			local rootPart = char and char:FindFirstChild("HumanoidRootPart")
			if rootPart then
				local targetPart = findNearestStealable(rootPart, AdminHubModules.State.StealRadius)
				if targetPart then
					pcall(function()
						rootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
					end)
					local touchFn = rawget(_G, "firetouchinterest") or (getgenv and getgenv().firetouchinterest)
					if type(touchFn) == "function" then
						pcall(function()
							touchFn(rootPart, targetPart, 0)
							task.wait(0.02)
							touchFn(rootPart, targetPart, 1)
						end)
					end
				end
				triggerNearbyPrompts(rootPart, AdminHubModules.State.StealRadius)
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(AdminHubModules.State.EmoteInterval)
		if AdminHubModules.State.AutoEmote then
			AdminHubModules.PlayNextEmote()
		end
	end
end)

RunService.Heartbeat:Connect(function()
	if AdminHubModules.State.AntiHit and LocalPlayer.Character then
		local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then
			root.AssemblyLinearVelocity = Vector3.new(
				root.AssemblyLinearVelocity.X * 0.5,
				root.AssemblyLinearVelocity.Y,
				root.AssemblyLinearVelocity.Z * 0.5
			)
		end
	end
end)

if LocalPlayer.Character then
	applyAntiHitProtection(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(applyAntiHitProtection)

return AdminHubModules
