local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
if not player then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	player = Players.LocalPlayer
end

local function getSafeGuiParent()
	local ok, result = pcall(function()
		local f = Instance.new("Folder")
		f.Name = "LimzxHubCheck"
		f.Parent = CoreGui
		f:Destroy()
		return CoreGui
	end)
	return (ok and result) or player:WaitForChild("PlayerGui")
end

local parentGui = getSafeGuiParent()
for _, name in ipairs({"LimzxHubUI", "LimzxPetFinderUI"}) do
	local old = parentGui:FindFirstChild(name)
	if old then old:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LimzxHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = parentGui end)
if not ScreenGui.Parent then
	ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

-- ==========================================
-- BAHASA (EN / ID)
-- ==========================================
local Lang = "EN"

local Texts = {
	EN = {
		title = "LIMZX HUB • BREAK & STEAL EGG",
		petFinderTitle = "PET FINDER PANEL",
		langBtn = "Lang: EN",
		toggleFinder = "Pet Finder Panel",
		antiAfk = "Anti-AFK",
		autoBreak = "Auto Break (Zone/Axe)",
		autoTpCollect = "Auto TP & Take Pets",
		tpOnce = "TP & Take Matching Pets",
		espToggle = "ESP Egg & Pet (/s)",
		wallhack = "Wallhack",
		bypass = "Anti-Cheat / Speed Bypass",
		infJump = "Infinite Jump",
		speedToggle = "Speed Boost",
		fpsBoost = "FPS Boost",
		minPerSec = "Min /s",
		maxPerSec = "Max /s (0/none = Unlimited)",
		speedVal = "Speed (10 - 1000)",
		zoneMode = "Break Zone Mode",
		zoneAuto = "Auto (By Axe Power)",
		zoneManual = "Manual Zone",
		hopNow = "Join Hop",
		scanNow = "Scan Eggs & Pets",
		noTarget = "No matching target found. Taking nearest/all available pets...",
	},
	ID = {
		title = "LIMZX HUB • BREAK & STEAL EGG",
		petFinderTitle = "PANEL PENCARI PET",
		langBtn = "Bahasa: ID",
		toggleFinder = "Panel Pencari Pet",
		antiAfk = "Anti-AFK",
		autoBreak = "Auto Break (Zona/Kapak)",
		autoTpCollect = "Auto TP & Ambil Semua Pet",
		tpOnce = "TP & Ambil Pet Sesuai Filter",
		espToggle = "ESP Egg & Pet (/s)",
		wallhack = "Wallhack (Tembus Objek)",
		bypass = "Bypass Kecepatan & Deteksi",
		infJump = "Lompat Tak Terbatas",
		speedToggle = "Speed Boost",
		fpsBoost = "FPS Boost",
		minPerSec = "Min /s",
		maxPerSec = "Max /s (0/none = Unlimited)",
		speedVal = "Kecepatan (10 - 1000)",
		zoneMode = "Mode Zona Break",
		zoneAuto = "Otomatis (Sesuai Power Kapak)",
		zoneManual = "Pilih Zona Manual",
		hopNow = "Join Hop",
		scanNow = "Scan Egg & Pet",
		noTarget = "Target spesifik tidak ada. Mengambil pet terdekat/yang tersedia...",
	}
}

local function T(key)
	return (Texts[Lang] and Texts[Lang][key]) or Texts.EN[key] or key
end

-- ==========================================
-- STATE & KONFIGURASI FITUR
-- ==========================================
local State = {
	AntiAFK = false,
	AutoBreak = false,
	AutoTpCollect = false,
	EspEnabled = false,
	Wallhack = false,
	Bypass = false,
	InfJump = false,
	SpeedEnabled = false,
	FpsBoosted = false,
	PetFinderOpen = true,
	MinPerSec = 0,
	MaxPerSec = math.huge, -- math.huge = Unlimited / None
	SpeedValue = 45,
	AutoZoneByAxe = true,
	SelectedZone = "Spawn / Starter Zone",
}

local ZoneList = {
	"Spawn / Starter Zone",
	"Common Egg Zone",
	"Rare / Mythic Zone",
	"High Tier / 10T+ Zone",
}

local HopPresets = {
	{ Label = "Giant Egg 10T/s", Target = "10T" },
	{ Label = "Giant Egg 100B/s", Target = "100B" },
	{ Label = "Giant Egg 1B/s", Target = "1B" },
	{ Label = "Big Egg Server", Target = "BIG" },
}

-- ==========================================
-- HELPER DRAG + CLAMP LAYAR
-- ==========================================
local function getViewportSize()
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(854, 480)
end

local function clampFrameToScreen(frame)
	local vp = getViewportSize()
	local sz = frame.AbsoluteSize
	local pos = frame.AbsolutePosition
	local maxX = math.max(0, vp.X - sz.X)
	local maxY = math.max(0, vp.Y - sz.Y)
	frame.Position = UDim2.new(0, math.clamp(pos.X, 0, maxX), 0, math.clamp(pos.Y, 0, maxY))
end

local function makeDraggable(frame, handle)
	handle = handle or frame
	local dragging = false
	local dragInput, dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					clampFrameToScreen(frame)
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			local vp = getViewportSize()
			local sz = frame.AbsoluteSize
			local nx = math.clamp(startPos.X.Offset + delta.X, 0, math.max(0, vp.X - sz.X))
			local ny = math.clamp(startPos.Y.Offset + delta.Y, 0, math.max(0, vp.Y - sz.Y))
			frame.Position = UDim2.new(0, nx, 0, ny)
		end
	end)
end

-- ==========================================
-- PARSER NILAI /s (K, M, B, T, Qa, Qi)
-- ==========================================
local SuffixMultiplier = {
	k = 1e3,
	m = 1e6,
	b = 1e9,
	t = 1e12,
	qa = 1e15,
	qi = 1e18,
}

local function parseRateNumber(raw)
	if type(raw) == "number" then
		return raw
	end
	if type(raw) ~= "string" then
		return nil
	end
	local cleaned = string.lower(raw)
	cleaned = string.gsub(cleaned, "/s", "")
	cleaned = string.gsub(cleaned, ",", "")
	local numStr, suf = string.match(cleaned, "([%d%.]+)%s*([a-z]*)")
	local n = tonumber(numStr)
	if not n then return nil end
	if suf and suf ~= "" and SuffixMultiplier[suf] then
		return n * SuffixMultiplier[suf]
	end
	return n
end

local function formatRate(val)
	if val == math.huge or val == nil then
		return "Unlimited"
	end
	if val >= 1e12 then return string.format("%.1fT/s", val / 1e12) end
	if val >= 1e9 then return string.format("%.1fB/s", val / 1e9) end
	if val >= 1e6 then return string.format("%.1fM/s", val / 1e6) end
	if val >= 1e3 then return string.format("%.1fK/s", val / 1e3) end
	return tostring(math.floor(val)) .. "/s"
end

-- ==========================================
-- DETEKSI EGG & PET + NILAI /s
-- ==========================================
local function getTargetPart(inst)
	if inst:IsA("BasePart") then return inst end
	if inst:IsA("Model") then
		return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
	end
	if inst.Parent and inst.Parent:IsA("BasePart") then
		return inst.Parent
	end
	return nil
end

local function extractRateFromInstance(inst)
	for _, attrName in ipairs({"PerSec", "Rate", "Income", "MPS", "BPS", "SPS", "Value"}) do
		local attrVal = inst:GetAttribute(attrName)
		local parsed = parseRateNumber(attrVal)
		if parsed and parsed > 0 then
			return parsed, tostring(attrVal)
		end
	end

	for _, child in ipairs(inst:GetDescendants()) do
		if child:IsA("NumberValue") or child:IsA("IntValue") then
			local lname = string.lower(child.Name)
			if string.find(lname, "sec") or string.find(lname, "rate") or string.find(lname, "income") or string.find(lname, "/s") then
				if child.Value > 0 then
					return child.Value, formatRate(child.Value)
				end
			end
		elseif child:IsA("StringValue") then
			if string.find(string.lower(child.Name), "/s") or string.find(string.lower(child.Value), "/s") then
				local p = parseRateNumber(child.Value)
				if p and p > 0 then
					return p, child.Value
				end
			end
		elseif child:IsA("TextLabel") or child:IsA("TextButton") then
			if string.find(string.lower(child.Text), "/s") then
				local p = parseRateNumber(child.Text)
				if p and p > 0 then
					return p, child.Text
				end
			end
		end
	end

	local nameNum = parseRateNumber(inst.Name)
	if nameNum and nameNum > 0 then
		return nameNum, formatRate(nameNum)
	end

	return 0, "?/s"
end

local function scanEggsAndPets()
	local results = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") or obj:IsA("BasePart") then
			local lname = string.lower(obj.Name)
			local isCandidate = string.find(lname, "egg") or string.find(lname, "pet") or string.find(lname, "hatch")
			if isCandidate then
				local part = getTargetPart(obj)
				if part and part.Parent then
					local rate, labelRate = extractRateFromInstance(obj)
					table.insert(results, {
						Instance = obj,
						Part = part,
						Name = obj.Name,
						Rate = rate,
						RateText = labelRate,
						HasRate = rate > 0,
					})
				end
			end
		end
	end

	table.sort(results, function(a, b)
		return a.Rate > b.Rate
	end)
	return results
end

local function isRateMatched(rate, hasRate)
	local minR = tonumber(State.MinPerSec) or 0
	local maxR = State.MaxPerSec
	if minR <= 0 and (maxR == nil or maxR == math.huge or maxR <= 0) then
		return true
	end
	if not hasRate then
		return minR <= 0
	end
	if rate < minR then
		return false
	end
	if maxR and maxR ~= math.huge and maxR > 0 and rate > maxR then
		return false
	end
	return true
end

-- ==========================================
-- AKSI AMBIL PET & TP
-- ==========================================
local function safeFireTouch(part0, part1)
	local fn = rawget(_G, "firetouchinterest") or (getgenv and getgenv().firetouchinterest)
	if type(fn) == "function" then
		pcall(function()
			fn(part0, part1, 0)
			task.wait(0.03)
			fn(part0, part1, 1)
		end)
	end
end

local function safeFirePrompt(prompt)
	local fn = rawget(_G, "fireproximityprompt") or (getgenv and getgenv().fireproximityprompt)
	if type(fn) == "function" then
		pcall(function() fn(prompt) end)
	end
end

local function collectNearbyPetsAndPrompts(root)
	for _, desc in ipairs(workspace:GetDescendants()) do
		if desc:IsA("ProximityPrompt") then
			local pPart = desc.Parent
			if pPart and pPart:IsA("BasePart") and (pPart.Position - root.Position).Magnitude <= 35 then
				safeFirePrompt(desc)
			end
		elseif desc:IsA("BasePart") then
			local ln = string.lower(desc.Name)
			if string.find(ln, "pet") or string.find(ln, "egg") or string.find(ln, "claim") or string.find(ln, "collect") then
				if (desc.Position - root.Position).Magnitude <= 28 then
					safeFireTouch(root, desc)
				end
			end
		end
	end
end

local function tpAndTakePets(onlyFiltered)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local list = scanEggsAndPets()
	local matched = {}

	if onlyFiltered then
		for _, item in ipairs(list) do
			if isRateMatched(item.Rate, item.HasRate) then
				table.insert(matched, item)
			end
		end
	end

	-- Jika tidak ada target sesuai filter atau mode ambil semua, ambil semua pet/egg yang tersedia
	local targetsToUse = (#matched > 0) and matched or list

	if #targetsToUse == 0 then
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "pet") then
				pcall(function()
					root.CFrame = obj.CFrame + Vector3.new(0, 3.5, 0)
				end)
				safeFireTouch(root, obj)
				task.wait(0.12)
			end
		end
		return
	end

	for i = 1, math.min(#targetsToUse, 8) do
		local entry = targetsToUse[i]
		if entry.Part and entry.Part.Parent then
			pcall(function()
				root.CFrame = entry.Part.CFrame + Vector3.new(0, 3.5, 0)
			end)
			safeFireTouch(root, entry.Part)
			collectNearbyPetsAndPrompts(root)
			task.wait(0.16)
		end
	end
end

-- ==========================================
-- ESP EGG & PET (/s)
-- ==========================================
local EspFolder = Instance.new("Folder")
EspFolder.Name = "LimzxEspFolder"
EspFolder.Parent = ScreenGui

local function clearEsp()
	for _, c in ipairs(EspFolder:GetChildren()) do
		c:Destroy()
	end
end

local function refreshEsp()
	clearEsp()
	if not State.EspEnabled then return end

	local items = scanEggsAndPets()
	for i = 1, math.min(#items, 35) do
		local item = items[i]
		if item.Part and item.Part.Parent then
			local hl = Instance.new("Highlight")
			hl.Name = "LimzxHL"
			hl.Adornee = item.Instance
			hl.FillColor = isRateMatched(item.Rate, item.HasRate) and Color3.fromRGB(190, 75, 255) or Color3.fromRGB(115, 215, 255)
			hl.OutlineColor = Color3.fromRGB(255, 255, 255)
			hl.FillTransparency = 0.55
			hl.Parent = EspFolder

			local bb = Instance.new("BillboardGui")
			bb.Name = "LimzxTag"
			bb.Adornee = item.Part
			bb.Size = UDim2.new(0, 140, 0, 34)
			bb.StudsOffset = Vector3.new(0, 3.2, 0)
			bb.AlwaysOnTop = true
			bb.Parent = EspFolder

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, 0, 1, 0)
			lbl.BackgroundColor3 = Color3.fromRGB(16, 12, 28)
			lbl.BackgroundTransparency = 0.25
			lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 11
			lbl.TextScaled = true
			lbl.Text = string.format("%s\n[%s]", item.Name, item.RateText)
			lbl.Parent = bb

			local uic = Instance.new("UICorner")
			uic.CornerRadius = UDim.new(0, 6)
			uic.Parent = lbl
		end
	end
end

task.spawn(function()
	while ScreenGui.Parent do
		task.wait(1.5)
		if State.EspEnabled then
			pcall(refreshEsp)
		end
	end
end)

-- ==========================================
-- AUTO BREAK (ZONA & POWER KAPAK)
-- ==========================================
local function getAxePower()
	local bestPower = 1
	local function checkTool(tool)
		if not tool or not tool:IsA("Tool") then return end
		local attr = tool:GetAttribute("Power") or tool:GetAttribute("Damage")
		local p = parseRateNumber(attr) or parseRateNumber(tool.Name)
		if p and p > bestPower then
			bestPower = p
		end
	end

	if player.Character then
		for _, v in ipairs(player.Character:GetChildren()) do
			checkTool(v)
		end
	end
	local bp = player:FindFirstChild("Backpack")
	if bp then
		for _, v in ipairs(bp:GetChildren()) do
			checkTool(v)
		end
	end
	return bestPower
end

local function getRecommendedZone(axePower)
	if axePower >= 1e9 then return "High Tier / 10T+ Zone" end
	if axePower >= 1e5 then return "Rare / Mythic Zone" end
	if axePower >= 1e2 then return "Common Egg Zone" end
	return "Spawn / Starter Zone"
end

task.spawn(function()
	while ScreenGui.Parent do
		task.wait(0.16)
		if State.AutoBreak then
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local bp = player:FindFirstChild("Backpack")
			local tool = char and char:FindFirstChildOfClass("Tool")

			if not tool and bp then
				local firstTool = bp:FindFirstChildOfClass("Tool")
				if firstTool and char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then
						pcall(function() hum:EquipTool(firstTool) end)
						tool = firstTool
					end
				end
			end

			if tool then
				pcall(function() tool:Activate() end)
			end

			if root then
				local targetZone = State.AutoZoneByAxe and getRecommendedZone(getAxePower()) or State.SelectedZone
				local zoneHint = string.lower(string.split(targetZone, " ")[1] or "egg")
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("BasePart") then
						local ln = string.lower(obj.Name)
						if string.find(ln, "break") or string.find(ln, "egg") or string.find(ln, zoneHint) then
							if (obj.Position - root.Position).Magnitude <= 14 then
								safeFireTouch(root, obj)
							end
						end
					end
				end
			end
		end
	end
end)

-- ==========================================
-- WALLHACK, BYPASS, ANTI-AFK, INF JUMP, SPEED
-- ==========================================
local WallhackCache = {}

local function applyWallhack(enable)
	if enable then
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and not obj:IsDescendantOf(player.Character) then
				local ln = string.lower(obj.Name)
				if string.find(ln, "wall") or string.find(ln, "door") or string.find(ln, "barrier") or string.find(ln, "gate") or string.find(ln, "block") then
					if not WallhackCache[obj] then
						WallhackCache[obj] = {
							Transparency = obj.Transparency,
							CanCollide = obj.CanCollide,
						}
					end
					pcall(function()
						obj.Transparency = 0.72
						obj.CanCollide = false
					end)
				end
			end
		end
	else
		for part, oldData in pairs(WallhackCache) do
			if part and part.Parent then
				pcall(function()
					part.Transparency = oldData.Transparency
					part.CanCollide = oldData.CanCollide
				end)
			end
		end
		WallhackCache = {}
	end
end

task.spawn(function()
	while ScreenGui.Parent do
		task.wait(0.6)
		if State.Wallhack then
			pcall(function() applyWallhack(true) end)
		end
	end
end)

RunService.Heartbeat:Connect(function()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if State.SpeedEnabled then
		local spd = math.clamp(tonumber(State.SpeedValue) or 45, 10, 1000)
		if hum.WalkSpeed ~= spd then
			pcall(function() hum.WalkSpeed = spd end)
		end
	end

	if State.Bypass then
		pcall(function()
			if hum.WalkSpeed < 16 and not State.SpeedEnabled then
				hum.WalkSpeed = 16
			end
			if hum.JumpPower < 50 then
				hum.UseJumpPower = true
				hum.JumpPower = 50
			end
		end)
	end
end)

player.Idled:Connect(function()
	if State.AntiAFK or State.Bypass then
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
end)

UserInputService.JumpRequest:Connect(function()
	if State.InfJump then
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
		end
	end
end)

local function applyFPSBoost()
	State.FpsBoosted = not State.FpsBoosted
	pcall(function()
		settings().Rendering.QualityLevel = State.FpsBoosted and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
	end)
	pcall(function()
		Lighting.GlobalShadows = not State.FpsBoosted
		if State.FpsBoosted then Lighting.FogEnd = 9e9 end
	end)
	for _, eff in ipairs(Lighting:GetChildren()) do
		if eff:IsA("PostEffect") then
			pcall(function() eff.Enabled = not State.FpsBoosted end)
		end
	end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and State.FpsBoosted then
			pcall(function()
				obj.Material = Enum.Material.SmoothPlastic
				obj.Reflectance = 0
			end)
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
			pcall(function() obj.Enabled = not State.FpsBoosted end)
		end
	end
end

-- ==========================================
-- SERVER HOP MANUAL UNTUK EGG BESAR (10T/s DLL)
-- ==========================================
local function hopToBigEggServer(targetTag)
	pcall(function()
		local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=25", game.PlaceId)
		local raw = game:HttpGet(url)
		local data = HttpService:JSONDecode(raw)
		if data and data.data then
			for _, srv in ipairs(data.data) do
				if srv.id ~= game.JobId and (srv.playing or 0) < (srv.maxPlayers or 20) then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, player)
					return
				end
			end
		end
	end)
	pcall(function()
		TeleportService:Teleport(game.PlaceId, player)
	end)
end

-- ==========================================
-- PANEL 1: LIMZX HUB + BACKGROUND GOJO BERPEDANG
-- ==========================================
local GOJO_SWORD_IMAGE_ID = "rbxassetid://16892837492"

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0, 24, 0, 36)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 12, 24)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.ZIndex = 1
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(190, 75, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local GojoBg = Instance.new("ImageLabel")
GojoBg.Size = UDim2.new(1.18, 0, 1.18, 0)
GojoBg.Position = UDim2.new(-0.09, 0, -0.09, 0)
GojoBg.BackgroundTransparency = 1
GojoBg.Image = GOJO_SWORD_IMAGE_ID
GojoBg.ImageTransparency = 0.52
GojoBg.ScaleType = Enum.ScaleType.Crop
GojoBg.ZIndex = 1
GojoBg.Parent = MainFrame

local GojoShade = Instance.new("Frame")
GojoShade.Size = UDim2.new(1, 0, 1, 0)
GojoShade.BackgroundColor3 = Color3.fromRGB(14, 10, 26)
GojoShade.BackgroundTransparency = 0.44
GojoShade.BorderSizePixel = 0
GojoShade.ZIndex = 2
GojoShade.Parent = MainFrame

local SwordLine = Instance.new("Frame")
SwordLine.Size = UDim2.new(1.5, 0, 0, 3)
SwordLine.Position = UDim2.new(-0.25, 0, 0.2, 0)
SwordLine.Rotation = -22
SwordLine.BackgroundColor3 = Color3.fromRGB(115, 215, 255)
SwordLine.BackgroundTransparency = 0.35
SwordLine.BorderSizePixel = 0
SwordLine.ZIndex = 3
SwordLine.Parent = MainFrame

task.spawn(function()
	while ScreenGui.Parent do
		local t1 = TweenService:Create(GojoBg, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = UDim2.new(-0.04, 0, -0.13, 0), Rotation = 1.6
		})
		local s1 = TweenService:Create(SwordLine, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = UDim2.new(-0.25, 0, 0.82, 0), BackgroundTransparency = 0.72
		})
		t1:Play(); s1:Play(); t1.Completed:Wait()

		local t2 = TweenService:Create(GojoBg, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = UDim2.new(-0.12, 0, -0.05, 0), Rotation = -1.6
		})
		local s2 = TweenService:Create(SwordLine, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = UDim2.new(-0.25, 0, 0.18, 0), BackgroundTransparency = 0.35
		})
		t2:Play(); s2:Play(); t2.Completed:Wait()
	end
end)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -16, 0, 38)
TopBar.Position = UDim2.new(0, 8, 0, 8)
TopBar.BackgroundColor3 = Color3.fromRGB(27, 22, 43)
TopBar.BackgroundTransparency = 0.12
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.ZIndex = 5
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

makeDraggable(MainFrame, TopBar)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -145, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = T("title")
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 6
TitleLabel.Parent = TopBar

local LangBtn = Instance.new("TextButton")
LangBtn.Size = UDim2.new(0, 62, 0, 30)
LangBtn.Position = UDim2.new(1, -104, 0.5, -15)
LangBtn.BackgroundColor3 = Color3.fromRGB(110, 50, 210)
LangBtn.Text = T("langBtn")
LangBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LangBtn.Font = Enum.Font.GothamBold
LangBtn.TextSize = 11
LangBtn.ZIndex = 6
LangBtn.Parent = TopBar

local LangCorner = Instance.new("UICorner")
LangCorner.CornerRadius = UDim.new(0, 7)
LangCorner.Parent = LangBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -37, 0.5, -17)
CloseBtn.BackgroundColor3 = Color3.fromRGB(225, 55, 90)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 15
CloseBtn.ZIndex = 6
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = CloseBtn

local MiniButton = Instance.new("TextButton")
MiniButton.Size = UDim2.new(0, 58, 0, 58)
MiniButton.Position = UDim2.new(0, 16, 0, 80)
MiniButton.BackgroundColor3 = Color3.fromRGB(22, 16, 40)
MiniButton.Text = "⚔️\nLIMZX"
MiniButton.TextColor3 = Color3.fromRGB(225, 130, 255)
MiniButton.Font = Enum.Font.GothamBold
MiniButton.TextSize = 12
MiniButton.Visible = false
MiniButton.Active = true
MiniButton.ZIndex = 12
MiniButton.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(1, 0)
MiniCorner.Parent = MiniButton

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(125, 210, 255)
MiniStroke.Thickness = 2
MiniStroke.Parent = MiniButton
makeDraggable(MiniButton)

CloseBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	MiniButton.Visible = true
	clampFrameToScreen(MiniButton)
end)

MiniButton.MouseButton1Click:Connect(function()
	MiniButton.Visible = false
	MainFrame.Visible = true
	clampFrameToScreen(MainFrame)
end)

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.BackgroundColor3 = Color3.fromRGB(20, 16, 34)
ContentScroll.BackgroundTransparency = 0.25
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 5
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(190, 75, 255)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.ZIndex = 5
ContentScroll.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentScroll

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 7)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentScroll

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 7)
ContentPadding.PaddingBottom = UDim.new(0, 7)
ContentPadding.PaddingLeft = UDim.new(0, 7)
ContentPadding.PaddingRight = UDim.new(0, 9)
ContentPadding.Parent = ContentScroll

local TabsScroll = Instance.new("ScrollingFrame")
TabsScroll.BackgroundColor3 = Color3.fromRGB(24, 19, 40)
TabsScroll.BackgroundTransparency = 0.22
TabsScroll.BorderSizePixel = 0
TabsScroll.ScrollBarThickness = 4
TabsScroll.ScrollBarImageColor3 = Color3.fromRGB(125, 210, 255)
TabsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabsScroll.ZIndex = 5
TabsScroll.Parent = MainFrame

local TabsCorner = Instance.new("UICorner")
TabsCorner.CornerRadius = UDim.new(0, 8)
TabsCorner.Parent = TabsScroll

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.Padding = UDim.new(0, 6)
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Parent = TabsScroll

local TabsPadding = Instance.new("UIPadding")
TabsPadding.PaddingTop = UDim.new(0, 6)
TabsPadding.PaddingBottom = UDim.new(0, 6)
TabsPadding.PaddingLeft = UDim.new(0, 6)
TabsPadding.PaddingRight = UDim.new(0, 6)
TabsPadding.Parent = TabsScroll

-- ==========================================
-- PANEL 2: PET FINDER PANEL (ON/OFF TERPISAH)
-- ==========================================
local FinderFrame = Instance.new("Frame")
FinderFrame.Name = "FinderFrame"
FinderFrame.Size = UDim2.new(0, 260, 0, 250)
FinderFrame.Position = UDim2.new(0, 515, 0, 36)
FinderFrame.BackgroundColor3 = Color3.fromRGB(18, 14, 30)
FinderFrame.BackgroundTransparency = 0.08
FinderFrame.BorderSizePixel = 0
FinderFrame.ClipsDescendants = true
FinderFrame.Active = true
FinderFrame.ZIndex = 4
FinderFrame.Parent = ScreenGui

local FinderCorner = Instance.new("UICorner")
FinderCorner.CornerRadius = UDim.new(0, 12)
FinderCorner.Parent = FinderFrame

local FinderStroke = Instance.new("UIStroke")
FinderStroke.Color = Color3.fromRGB(115, 215, 255)
FinderStroke.Thickness = 2
FinderStroke.Parent = FinderFrame

local FinderTop = Instance.new("Frame")
FinderTop.Size = UDim2.new(1, -12, 0, 34)
FinderTop.Position = UDim2.new(0, 6, 0, 6)
FinderTop.BackgroundColor3 = Color3.fromRGB(30, 24, 48)
FinderTop.BorderSizePixel = 0
FinderTop.Active = true
FinderTop.ZIndex = 5
FinderTop.Parent = FinderFrame

local FinderTopCorner = Instance.new("UICorner")
FinderTopCorner.CornerRadius = UDim.new(0, 7)
FinderTopCorner.Parent = FinderTop

makeDraggable(FinderFrame, FinderTop)

local FinderTitle = Instance.new("TextLabel")
FinderTitle.Size = UDim2.new(1, -36, 1, 0)
FinderTitle.Position = UDim2.new(0, 8, 0, 0)
FinderTitle.BackgroundTransparency = 1
FinderTitle.Text = T("petFinderTitle")
FinderTitle.TextColor3 = Color3.fromRGB(150, 225, 255)
FinderTitle.Font = Enum.Font.GothamBold
FinderTitle.TextSize = 12
FinderTitle.TextXAlignment = Enum.TextXAlignment.Left
FinderTitle.ZIndex = 6
FinderTitle.Parent = FinderTop

local FinderCloseBtn = Instance.new("TextButton")
FinderCloseBtn.Size = UDim2.new(0, 26, 0, 26)
FinderCloseBtn.Position = UDim2.new(1, -30, 0.5, -13)
FinderCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 85)
FinderCloseBtn.Text = "X"
FinderCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FinderCloseBtn.Font = Enum.Font.GothamBold
FinderCloseBtn.TextSize = 13
FinderCloseBtn.ZIndex = 6
FinderCloseBtn.Parent = FinderTop

local FinderCloseCorner = Instance.new("UICorner")
FinderCloseCorner.CornerRadius = UDim.new(0, 6)
FinderCloseCorner.Parent = FinderCloseBtn

local FinderScroll = Instance.new("ScrollingFrame")
FinderScroll.Size = UDim2.new(1, -12, 1, -48)
FinderScroll.Position = UDim2.new(0, 6, 0, 44)
FinderScroll.BackgroundTransparency = 1
FinderScroll.ScrollBarThickness = 4
FinderScroll.ScrollBarImageColor3 = Color3.fromRGB(115, 215, 255)
FinderScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
FinderScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
FinderScroll.ZIndex = 5
FinderScroll.Parent = FinderFrame

local FinderLayout = Instance.new("UIListLayout")
FinderLayout.Padding = UDim.new(0, 6)
FinderLayout.SortOrder = Enum.SortOrder.LayoutOrder
FinderLayout.Parent = FinderScroll

local function rebuildFinderPanel()
	for _, c in ipairs(FinderScroll:GetChildren()) do
		if c:IsA("GuiObject") then c:Destroy() end
	end

	local actionRow = Instance.new("TextButton")
	actionRow.Size = UDim2.new(1, 0, 0, 38)
	actionRow.BackgroundColor3 = Color3.fromRGB(130, 50, 215)
	actionRow.Text = "⚡ " .. T("tpOnce")
	actionRow.TextColor3 = Color3.fromRGB(255, 255, 255)
	actionRow.Font = Enum.Font.GothamBold
	actionRow.TextSize = 12
	actionRow.ZIndex = 6
	actionRow.Parent = FinderScroll
	Instance.new("UICorner", actionRow).CornerRadius = UDim.new(0, 7)
	actionRow.MouseButton1Click:Connect(function()
		task.spawn(function() tpAndTakePets(true) end)
	end)

	local found = scanEggsAndPets()
	for i = 1, math.min(#found, 15) do
		local entry = found[i]
		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, 0, 0, 38)
		row.BackgroundColor3 = Color3.fromRGB(32, 26, 52)
		row.Text = string.format("🥚 %s | %s", entry.Name, entry.RateText)
		row.TextColor3 = Color3.fromRGB(240, 240, 255)
		row.Font = Enum.Font.GothamSemibold
		row.TextSize = 12
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.TextTruncate = Enum.TextTruncate.AtEnd
		row.ZIndex = 6
		row.Parent = FinderScroll
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

		row.MouseButton1Click:Connect(function()
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root and entry.Part and entry.Part.Parent then
				pcall(function()
					root.CFrame = entry.Part.CFrame + Vector3.new(0, 3.5, 0)
				end)
				safeFireTouch(root, entry.Part)
				collectNearbyPetsAndPrompts(root)
			end
		end)
	end
end

local function setPetFinderVisible(vis)
	State.PetFinderOpen = vis
	FinderFrame.Visible = vis
	if vis then
		rebuildFinderPanel()
		clampFrameToScreen(FinderFrame)
	end
end

FinderCloseBtn.MouseButton1Click:Connect(function()
	setPetFinderVisible(false)
end)

-- Loop Auto TP & Take Pets
task.spawn(function()
	while ScreenGui.Parent do
		task.wait(0.75)
		if State.AutoTpCollect then
			pcall(function() tpAndTakePets(true) end)
		end
	end
end)

-- ==========================================
-- PEMBUAT KONTROL UI (TOGGLE, INPUT, HOP + AVATAR)
-- ==========================================
local CurrentTab = "Main"
local TabButtons = {}

local function makeRowBase(height)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, height or 42)
	f.BackgroundColor3 = Color3.fromRGB(34, 28, 54)
	f.BackgroundTransparency = 0.12
	f.BorderSizePixel = 0
	f.ZIndex = 6
	f.Parent = ContentScroll
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
	local st = Instance.new("UIStroke")
	st.Color = Color3.fromRGB(135, 75, 200)
	st.Thickness = 1
	st.Parent = f
	return f
end

local function addToggleRow(labelText, getVal, setVal)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 42)
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 13
	btn.TextTruncate = Enum.TextTruncate.AtEnd
	btn.ZIndex = 6
	btn.Parent = ContentScroll
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local st = Instance.new("UIStroke")
	st.Color = Color3.fromRGB(135, 75, 200)
	st.Thickness = 1
	st.Parent = btn

	local function refresh()
		local active = getVal()
		btn.BackgroundColor3 = active and Color3.fromRGB(145, 45, 215) or Color3.fromRGB(34, 28, 54)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = string.format("  ⚔️ %s [%s]", labelText, active and "ON" or "OFF")
	end

	refresh()
	btn.MouseButton1Click:Connect(function()
		setVal(not getVal())
		refresh()
	end)
end

local function addButtonRow(labelText, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 42)
	btn.BackgroundColor3 = Color3.fromRGB(34, 28, 54)
	btn.BackgroundTransparency = 0.12
	btn.TextColor3 = Color3.fromRGB(240, 240, 255)
	btn.Text = "  ⚔️ " .. labelText
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 13
	btn.TextTruncate = Enum.TextTruncate.AtEnd
	btn.ZIndex = 6
	btn.Parent = ContentScroll
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local st = Instance.new("UIStroke")
	st.Color = Color3.fromRGB(135, 75, 200)
	st.Thickness = 1
	st.Parent = btn

	btn.MouseButton1Click:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(190, 75, 255)
		task.wait(0.1)
		btn.BackgroundColor3 = Color3.fromRGB(34, 28, 54)
		if onClick then onClick() end
	end)
end

local function addNumberInputRow(labelText, initialText, onCommit)
	local row = makeRowBase(42)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.62, -8, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = Color3.fromRGB(235, 230, 250)
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.ZIndex = 7
	lbl.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.35, -4, 0, 30)
	box.Position = UDim2.new(0.64, 0, 0.5, -15)
	box.BackgroundColor3 = Color3.fromRGB(20, 16, 36)
	box.Text = initialText
	box.PlaceholderText = "none"
	box.TextColor3 = Color3.fromRGB(130, 225, 255)
	box.Font = Enum.Font.GothamBold
	box.TextSize = 12
	box.ClearTextOnFocus = false
	box.ZIndex = 7
	box.Parent = row
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

	box.FocusLost:Connect(function()
		onCommit(box.Text, box)
	end)
end

local function addHopCardWithAvatar(preset)
	local card = makeRowBase(52)

	local vp = Instance.new("ViewportFrame")
	vp.Size = UDim2.new(0, 42, 0, 42)
	vp.Position = UDim2.new(0, 6, 0.5, -21)
	vp.BackgroundColor3 = Color3.fromRGB(22, 18, 38)
	vp.ZIndex = 7
	vp.Parent = card
	Instance.new("UICorner", vp).CornerRadius = UDim.new(1, 0)

	local cam = Instance.new("Camera")
	cam.CFrame = CFrame.new(Vector3.new(0, 1.4, 4.2), Vector3.new(0, 1.2, 0))
	vp.CurrentCamera = cam
	cam.Parent = vp

	pcall(function()
		local model = Players:CreateHumanoidModelFromUserId(player.UserId)
		model:PivotTo(CFrame.new(0, 0, 0))
		model.Parent = vp
	end)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -135, 1, 0)
	lbl.Position = UDim2.new(0, 54, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = preset.Label
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 7
	lbl.Parent = card

	local joinBtn = Instance.new("TextButton")
	joinBtn.Size = UDim2.new(0, 74, 0, 34)
	joinBtn.Position = UDim2.new(1, -80, 0.5, -17)
	joinBtn.BackgroundColor3 = Color3.fromRGB(155, 55, 230)
	joinBtn.Text = T("hopNow")
	joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	joinBtn.Font = Enum.Font.GothamBold
	joinBtn.TextSize = 12
	joinBtn.ZIndex = 7
	joinBtn.Parent = card
	Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 7)

	joinBtn.MouseButton1Click:Connect(function()
		hopToBigEggServer(preset.Target)
	end)
end

local function loadTabContent(tabName)
	CurrentTab = tabName
	for _, c in ipairs(ContentScroll:GetChildren()) do
		if c:IsA("GuiObject") then c:Destroy() end
	end
	ContentScroll.CanvasPosition = Vector2.new(0, 0)

	if tabName == "Main" then
		addToggleRow(T("toggleFinder"), function() return State.PetFinderOpen end, function(v) setPetFinderVisible(v) end)
		addToggleRow(T("antiAfk"), function() return State.AntiAFK end, function(v) State.AntiAFK = v end)
		addToggleRow(T("autoTpCollect"), function() return State.AutoTpCollect end, function(v) State.AutoTpCollect = v end)
		addButtonRow(T("tpOnce"), function() task.spawn(function() tpAndTakePets(true) end) end)
		addToggleRow(T("espToggle"), function() return State.EspEnabled end, function(v) State.EspEnabled = v; refreshEsp() end)
		addButtonRow(T("fpsBoost"), function() applyFPSBoost() end)
	elseif tabName == "Pet & TP" then
		addNumberInputRow(T("minPerSec"), formatRate(State.MinPerSec), function(txt, box)
			local val = parseRateNumber(txt)
			State.MinPerSec = val or 0
			box.Text = formatRate(State.MinPerSec)
		end)
		addNumberInputRow(T("maxPerSec"), State.MaxPerSec == math.huge and "none" or formatRate(State.MaxPerSec), function(txt, box)
			local low = string.lower(txt or "")
			if low == "" or low == "none" or low == "unlimited" or low == "inf" or low == "0" then
				State.MaxPerSec = math.huge
				box.Text = "none"
			else
				local val = parseRateNumber(txt)
				State.MaxPerSec = (val and val > 0) and val or math.huge
				box.Text = State.MaxPerSec == math.huge and "none" or formatRate(State.MaxPerSec)
			end
		end)
		addButtonRow(T("tpOnce"), function() task.spawn(function() tpAndTakePets(true) end) end)
		addButtonRow(T("scanNow"), function() refreshEsp(); rebuildFinderPanel() end)
		addToggleRow(T("espToggle"), function() return State.EspEnabled end, function(v) State.EspEnabled = v; refreshEsp() end)
	elseif tabName == "Server Hop" then
		for _, p in ipairs(HopPresets) do
			addHopCardWithAvatar(p)
		end
	elseif tabName == "Break & Axe" then
		addToggleRow(T("autoBreak"), function() return State.AutoBreak end, function(v) State.AutoBreak = v end)
		addToggleRow(T("zoneMode"), function() return State.AutoZoneByAxe end, function(v) State.AutoZoneByAxe = v end)
		addButtonRow("Zone: " .. (State.AutoZoneByAxe and getRecommendedZone(getAxePower()) or State.SelectedZone), function()
			local idx = 1
			for i, z in ipairs(ZoneList) do
				if z == State.SelectedZone then idx = i; break end
			end
			State.SelectedZone = ZoneList[(idx % #ZoneList) + 1]
			loadTabContent("Break & Axe")
		end)
	elseif tabName == "Player" then
		addToggleRow(T("speedToggle"), function() return State.SpeedEnabled end, function(v)
			State.SpeedEnabled = v
			if not v then
				local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if hum then pcall(function() hum.WalkSpeed = 16 end) end
			end
		end)
		addNumberInputRow(T("speedVal"), tostring(State.SpeedValue), function(txt, box)
			local n = tonumber(txt)
			State.SpeedValue = math.clamp(n or 45, 10, 1000)
			box.Text = tostring(State.SpeedValue)
		end)
		addToggleRow(T("wallhack"), function() return State.Wallhack end, function(v) State.Wallhack = v; applyWallhack(v) end)
		addToggleRow(T("bypass"), function() return State.Bypass end, function(v) State.Bypass = v end)
		addToggleRow(T("infJump"), function() return State.InfJump end, function(v) State.InfJump = v end)
	end
end

LangBtn.MouseButton1Click:Connect(function()
	Lang = (Lang == "EN") and "ID" or "EN"
	LangBtn.Text = T("langBtn")
	TitleLabel.Text = T("title")
	FinderTitle.Text = T("petFinderTitle")
	loadTabContent(CurrentTab)
	rebuildFinderPanel()
end)

local TabOrder = {"Main", "Pet & TP", "Server Hop", "Break & Axe", "Player"}

for _, tabName in ipairs(TabOrder) do
	local tBtn = Instance.new("TextButton")
	tBtn.Size = UDim2.new(1, 0, 0, 38)
	tBtn.BackgroundColor3 = Color3.fromRGB(36, 30, 58)
	tBtn.BackgroundTransparency = 0.1
	tBtn.Text = tabName
	tBtn.TextColor3 = Color3.fromRGB(205, 195, 225)
	tBtn.Font = Enum.Font.GothamBold
	tBtn.TextSize = 12
	tBtn.ZIndex = 6
	tBtn.Parent = TabsScroll
	Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 8)
	TabButtons[tabName] = tBtn

	tBtn.MouseButton1Click:Connect(function()
		for name, b in pairs(TabButtons) do
			if name == tabName then
				b.BackgroundColor3 = Color3.fromRGB(180, 65, 245)
				b.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				b.BackgroundColor3 = Color3.fromRGB(36, 30, 58)
				b.TextColor3 = Color3.fromRGB(205, 195, 225)
			end
		end
		loadTabContent(tabName)
	end)
end

-- ==========================================
-- RESPONSIVE PORTRAIT & LANDSCAPE HP
-- ==========================================
local firstLayout = true

local function updateResponsiveLayout()
	local vp = getViewportSize()
	local isPortrait = vp.Y >= vp.X

	if isPortrait then
		local fw = math.clamp(math.floor(vp.X * 0.90), 290, 440)
		local fh = math.clamp(math.floor(vp.Y * 0.50), 290, 420)
		MainFrame.Size = UDim2.new(0, fw, 0, fh)

		TabsScroll.Position = UDim2.new(0, 8, 0, 52)
		TabsScroll.Size = UDim2.new(1, -16, 0, 46)
		TabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
		TabsScroll.ScrollingDirection = Enum.ScrollingDirection.X
		TabsLayout.FillDirection = Enum.FillDirection.Horizontal
		for _, b in pairs(TabButtons) do b.Size = UDim2.new(0, 102, 1, 0) end

		ContentScroll.Position = UDim2.new(0, 8, 0, 104)
		ContentScroll.Size = UDim2.new(1, -16, 1, -112)

		FinderFrame.Size = UDim2.new(0, fw, 0, math.clamp(math.floor(vp.Y * 0.34), 190, 260))
		if firstLayout then
			MainFrame.Position = UDim2.new(0, math.floor((vp.X - fw) / 2), 0, 18)
			FinderFrame.Position = UDim2.new(0, math.floor((vp.X - FinderFrame.Size.X.Offset) / 2), 0, 24 + fh)
		end
	else
		local fw = math.clamp(math.floor(vp.X * 0.56), 380, 500)
		local fh = math.clamp(math.floor(vp.Y * 0.78), 260, 340)
		MainFrame.Size = UDim2.new(0, fw, 0, fh)

		local tabW = math.clamp(math.floor(fw * 0.26), 108, 135)
		TabsScroll.Position = UDim2.new(1, -(tabW + 8), 0, 52)
		TabsScroll.Size = UDim2.new(0, tabW, 1, -60)
		TabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		TabsScroll.ScrollingDirection = Enum.ScrollingDirection.Y
		TabsLayout.FillDirection = Enum.FillDirection.Vertical
		for _, b in pairs(TabButtons) do b.Size = UDim2.new(1, 0, 0, 36) end

		ContentScroll.Position = UDim2.new(0, 8, 0, 52)
		ContentScroll.Size = UDim2.new(1, -(tabW + 20), 1, -60)

		local finderW = math.clamp(math.floor(vp.X * 0.32), 210, 290)
		FinderFrame.Size = UDim2.new(0, finderW, 0, fh)
		if firstLayout then
			MainFrame.Position = UDim2.new(0, 16, 0, math.floor((vp.Y - fh) / 2))
			FinderFrame.Position = UDim2.new(0, math.min(vp.X - finderW - 12, 24 + fw), 0, math.floor((vp.Y - fh) / 2))
		end
	end

	firstLayout = false
	clampFrameToScreen(MainFrame)
	clampFrameToScreen(FinderFrame)
	clampFrameToScreen(MiniButton)
end

updateResponsiveLayout()

local function bindViewport()
	local cam = workspace.CurrentCamera
	if cam then
		cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveLayout)
	end
end
bindViewport()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewport)

TabButtons["Main"].BackgroundColor3 = Color3.fromRGB(180, 65, 245)
TabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
loadTabContent("Main")
rebuildFinderPanel()