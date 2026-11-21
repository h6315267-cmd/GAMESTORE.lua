local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- ==========================================
-- KONFIGURASI LINK, JSONBIN, 1 HARI & WRITEFILE
-- ==========================================
local QUEST_LINK_URL = "https://guileless-lollipop-6f7ef4.netlify.app"
local JSONBIN_BIN_ID = "6b00e78cffd5d16053d26a11"
local JSONBIN_API_KEY = "$2a$10$UpLTAelTQemzALH0qMFlU.qubFu6iLDTCfJXhqmRea9RHXzCmbFnC"
local ONE_DAY_SECONDS = 86400 -- 1 hari (24 jam)
local LOCAL_SESSION_FILE = "AdminHub_Netlify_1Day.json"

-- Urutan Rarity Lengkap dari Common sampai Divine
local RARITY_ORDER = {
	"COMMON",
	"UNCOMMON",
	"RARE",
	"EPIC",
	"LEGENDARY",
	"MYTHIC",
	"COSMIC",
	"SECRET",
	"ETERNAL",
	"DIVINE",
}

local function cleanKey(raw)
	if type(raw) ~= "string" then return "" end
	return string.upper(string.gsub(raw, "%s+", ""))
end

-- ==========================================
-- FILE I/O (WRITEFILE / READFILE)
-- ==========================================
local function getFileApis()
	local wf = rawget(_G, "writefile") or (getgenv and getgenv().writefile)
	local rf = rawget(_G, "readfile") or (getgenv and getgenv().readfile)
	local ifn = rawget(_G, "isfile") or (getgenv and getgenv().isfile)
	return wf, rf, ifn
end

local function writeLocalKeySession(keyStr, tierStr, expiresAt)
	local wf = getFileApis()
	if type(wf) ~= "function" then return false end
	local payload = HttpService:JSONEncode({
		key = cleanKey(keyStr),
		tier = tierStr,
		expiresAt = expiresAt,
		savedAt = os.time(),
	})
	return pcall(function()
		wf(LOCAL_SESSION_FILE, payload)
	end)
end

local function readLocalKeySession()
	local _, rf, ifn = getFileApis()
	if type(rf) ~= "function" then return nil end

	if type(ifn) == "function" then
		local okEx, exists = pcall(function() return ifn(LOCAL_SESSION_FILE) end)
		if not (okEx and exists) then return nil end
	end

	local okRead, raw = pcall(function() return rf(LOCAL_SESSION_FILE) end)
	if not okRead or type(raw) ~= "string" or raw == "" then return nil end

	local okDec, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
	if okDec and type(decoded) == "table" then
		return decoded
	end
	return nil
end

-- ==========================================
-- VERIFIKASI KEY DARI JSONBIN (1 HARI)
-- ==========================================
local function fetchBinKeys()
	local url = string.format("https://api.jsonbin.io/v3/b/%s/latest", JSONBIN_BIN_ID)
	local headers = {
		["X-Master-Key"] = JSONBIN_API_KEY,
		["X-Access-Key"] = JSONBIN_API_KEY,
	}

	local okReq, body = pcall(function()
		local reqFunc = rawget(_G, "request") or (getgenv and getgenv().request) or (syn and syn.request)
		if type(reqFunc) == "function" then
			local resp = reqFunc({
				Url = url,
				Method = "GET",
				Headers = headers,
			})
			return resp and resp.Body
		end
		return game:HttpGet(url)
	end)

	if not okReq or type(body) ~= "string" or body == "" then
		return nil, "Gagal terhubung ke JSONBin."
	end

	local okDec, parsed = pcall(function() return HttpService:JSONDecode(body) end)
	if not okDec or type(parsed) ~= "table" then
		return nil, "Respon JSONBin tidak valid."
	end

	local rec = (type(parsed.record) == "table") and parsed.record or parsed
	return rec, nil
end

local function verifyOneDayKey(rawInput)
	local k = cleanKey(rawInput)
	if k == "" then
		return false, nil, "Masukkan key terlebih dahulu."
	end

	local now = os.time()
	local rec, err = fetchBinKeys()
	if not rec then
		return false, nil, err
	end

	local keysTable = rec.keys
	if type(keysTable) ~= "table" then
		return false, nil, "Data 'keys' belum ditemukan di bin."
	end

	local entry = keysTable[k]
	if type(entry) ~= "table" then
		return false, nil, "Key tidak terdaftar / belum diambil dari link."
	end

	local tier = string.upper(tostring(entry.tier or "REGULAR"))
	if tier ~= "VIP" then
		tier = "REGULAR"
	end

	local expAt = tonumber(entry.expiresAt)
	if not expAt and tonumber(entry.createdAt) then
		expAt = tonumber(entry.createdAt) + ONE_DAY_SECONDS
	end
	if not expAt then
		expAt = now + ONE_DAY_SECONDS
	end

	if now >= expAt then
		return false, tier, "Key 1 hari ini sudah expired."
	end

	writeLocalKeySession(k, tier, expAt)
	local sisaJam = math.max(1, math.ceil((expAt - now) / 3600))
	return true, tier, string.format("Key %s aktif • Sisa %d jam", tier, sisaJam)
end

-- ==========================================
-- HELPER DRAG / GESER PANEL
-- ==========================================
local function getViewport()
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function clampToScreen(guiObj)
	local vp = getViewport()
	local sz = guiObj.AbsoluteSize
	local pos = guiObj.AbsolutePosition
	guiObj.Position = UDim2.new(
		0, math.clamp(pos.X, 0, math.max(0, vp.X - sz.X)),
		0, math.clamp(pos.Y, 0, math.max(0, vp.Y - sz.Y))
	)
end

local function makeDraggable(targetObj, dragHandle)
	dragHandle = dragHandle or targetObj
	local dragging = false
	local activeInput = nil
	local startMouse = Vector2.zero
	local startPos = UDim2.new()

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			activeInput = input
			startMouse = input.Position
			startPos = targetObj.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					activeInput = nil
					clampToScreen(targetObj)
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == activeInput then
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local delta = input.Position - startMouse
				local vp = getViewport()
				local sz = targetObj.AbsoluteSize
				local nextX = math.clamp(startPos.X.Offset + delta.X, 0, math.max(0, vp.X - sz.X))
				local nextY = math.clamp(startPos.Y.Offset + delta.Y, 0, math.max(0, vp.Y - sz.Y))
				targetObj.Position = UDim2.new(0, nextX, 0, nextY)
			end
		end
	end)
end

-- ==========================================
-- PARENT GUI AMAN
-- ==========================================
local function getGuiParent()
	local ok, res = pcall(function()
		local f = Instance.new("Folder")
		f.Name = "AdminHubBenParent"
		f.Parent = CoreGui
		f:Destroy()
		return CoreGui
	end)
	return (ok and res) or player:WaitForChild("PlayerGui")
end

local parentGui = getGuiParent()
local oldGui = parentGui:FindFirstChild("AdminHubBenUI")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminHubBenUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = parentGui end)
if not ScreenGui.Parent then
	ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

-- ==========================================
-- STATE FITUR ADMIN HUB
-- ==========================================
local UnlockedTier = nil
local MinRarityIndex = 1 -- 1 = COMMON ke atas (sampai DIVINE)

local State = {
	AutoStealEgg = false,
	EggFinder = false,
	AutoBreakEventRock = false,
	AutoTreadmill = false,
	AutoUpgradeBase = false,
	AutoUpgradeTreadmill = false,
	AutoBuyTrails = false,
	AntiAfk = false,
}

local function getPartFromInst(inst)
	if not inst or not inst.Parent then return nil end
	if inst:IsA("BasePart") then return inst end
	if inst:IsA("Model") then
		return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
	end
	return nil
end

local function fireTouchSafe(rootPart, targetPart)
	local fn = rawget(_G, "firetouchinterest") or (getgenv and getgenv().firetouchinterest)
	if type(fn) == "function" and rootPart and targetPart then
		pcall(function()
			fn(rootPart, targetPart, 0)
			task.wait(0.02)
			fn(rootPart, targetPart, 1)
		end)
	end
end

local function firePromptSafe(prompt)
	local fn = rawget(_G, "fireproximityprompt") or (getgenv and getgenv().fireproximityprompt)
	if type(fn) == "function" and prompt then
		pcall(function() fn(prompt) end)
	end
end

local function fireClickSafe(cd)
	local fn = rawget(_G, "fireclickdetector") or (getgenv and getgenv().fireclickdetector)
	if type(fn) == "function" and cd then
		pcall(function() fn(cd) end)
	end
end

local function triggerInteractionsNear(rootPart, maxDist, keywordFilter)
	if not rootPart then return end
	for _, desc in ipairs(workspace:GetDescendants()) do
		if desc:IsA("ProximityPrompt") and desc.Parent then
			local pPart = getPartFromInst(desc.Parent) or (desc.Parent:IsA("Attachment") and desc.Parent.Parent and getPartFromInst(desc.Parent.Parent))
			if pPart and (pPart.Position - rootPart.Position).Magnitude <= (maxDist or 35) then
				local combined = string.lower(desc.Name .. " " .. desc.ActionText .. " " .. desc.ObjectText .. " " .. desc.Parent.Name)
				if (not keywordFilter) or string.find(combined, keywordFilter) then
					firePromptSafe(desc)
				end
			end
		elseif desc:IsA("ClickDetector") and desc.Parent then
			local cPart = getPartFromInst(desc.Parent)
			if cPart and (cPart.Position - rootPart.Position).Magnitude <= (maxDist or 35) then
				local combined = string.lower(desc.Name .. " " .. desc.Parent.Name)
				if (not keywordFilter) or string.find(combined, keywordFilter) then
					fireClickSafe(desc)
				end
			end
		end
	end
end

local function detectRarityAndRate(obj)
	local textBlob = obj.Name
	for _, d in ipairs(obj:GetDescendants()) do
		if d:IsA("StringValue") or d:IsA("NumberValue") or d:IsA("IntValue") then
			textBlob = textBlob .. " " .. d.Name .. "=" .. tostring(d.Value)
		elseif d:IsA("TextLabel") or d:IsA("TextButton") then
			textBlob = textBlob .. " " .. tostring(d.Text)
		elseif d:IsA("BillboardGui") then
			for _, lbl in ipairs(d:GetDescendants()) do
				if lbl:IsA("TextLabel") then
					textBlob = textBlob .. " " .. tostring(lbl.Text)
				end
			end
		end
	end

	local upperBlob = string.upper(textBlob)
	local foundRarity = "COMMON"
	local foundRank = 1

	for idx, rName in ipairs(RARITY_ORDER) do
		if string.find(upperBlob, rName, 1, true) then
			foundRarity = rName
			foundRank = idx
		end
	end

	local rateNum = tonumber(string.match(string.lower(textBlob), "([%d%.]+)%s*/%s*s"))
	if not rateNum then
		rateNum = tonumber(string.match(string.lower(textBlob), "([%d%.]+)%s*per%s*sec"))
	end
	if not rateNum then
		rateNum = foundRank * 35
	end

	return foundRarity, foundRank, rateNum
end

local function scanEggsWithRates()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local originPos = root and root.Position or Vector3.zero
	local results = {}

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") or obj:IsA("BasePart") then
			if not (player.Character and obj:IsDescendantOf(player.Character)) then
				local ln = string.lower(obj.Name)
				if string.find(ln, "egg") then
					local part = getPartFromInst(obj)
					if part then
						local rarity, rank, ratePerSec = detectRarityAndRate(obj)
						local dist = (part.Position - originPos).Magnitude
						table.insert(results, {
							Inst = obj,
							Part = part,
							Name = obj.Name,
							Rarity = rarity,
							Rank = rank,
							Rate = ratePerSec,
							Distance = dist,
						})
					end
				end
			end
		end
	end

	table.sort(results, function(a, b)
		if a.Rate ~= b.Rate then
			return a.Rate > b.Rate
		end
		return a.Distance < b.Distance
	end)

	return results
end

-- ==========================================
-- EGG FINDER VISUAL (/S RATE)
-- ==========================================
local EggFinderFolder = Instance.new("Folder")
EggFinderFolder.Name = "AdminHubEggFinderFolder"
EggFinderFolder.Parent = ScreenGui

local function clearEggFinderEsp()
	for _, c in ipairs(EggFinderFolder:GetChildren()) do
		c:Destroy()
	end
end

local function refreshEggFinderEsp()
	clearEggFinderEsp()
	if not UnlockedTier or not State.EggFinder then return end

	local eggs = scanEggsWithRates()
	for i = 1, math.min(#eggs, 25) do
		local e = eggs[i]
		if e.Part and e.Part.Parent then
			local hl = Instance.new("Highlight")
			hl.Adornee = e.Inst
			hl.FillColor = (e.Rarity == "DIVINE" or e.Rarity == "ETERNAL") and Color3.fromRGB(255, 210, 50) or Color3.fromRGB(255, 55, 85)
			hl.OutlineColor = Color3.fromRGB(255, 240, 140)
			hl.FillTransparency = 0.45
			hl.Parent = EggFinderFolder

			local bb = Instance.new("BillboardGui")
			bb.Adornee = e.Part
			bb.Size = UDim2.new(0, 175, 0, 38)
			bb.StudsOffset = Vector3.new(0, 3.4, 0)
			bb.AlwaysOnTop = true
			bb.Parent = EggFinderFolder

			local tag = Instance.new("TextLabel")
			tag.Size = UDim2.new(1, 0, 1, 0)
			tag.BackgroundColor3 = Color3.fromRGB(22, 12, 17)
			tag.BackgroundTransparency = 0.15
			tag.TextColor3 = Color3.fromRGB(255, 240, 244)
			tag.Font = Enum.Font.GothamBold
			tag.TextSize = 11
			tag.TextScaled = true
			tag.Text = string.format("%s [%s]\n%.1f/s • %.0fm", e.Name, e.Rarity, e.Rate, e.Distance)
			tag.Parent = bb
			Instance.new("UICorner", tag).CornerRadius = UDim.new(0, 6)
		end
	end
end

-- ==========================================
-- AKSI FITUR OTOMATIS
-- ==========================================
local function runAutoStealEggOnce()
	if not UnlockedTier then return end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local eggs = scanEggsWithRates()
	local chosen = nil

	for _, e in ipairs(eggs) do
		if e.Rank >= MinRarityIndex then
			chosen = e
			break
		end
	end

	if chosen and chosen.Part and chosen.Part.Parent then
		pcall(function()
			root.CFrame = chosen.Part.CFrame + Vector3.new(0, 3.2, 0)
		end)
		fireTouchSafe(root, chosen.Part)
		triggerInteractionsNear(root, 32, nil)
	end
end

local function equipMiningOrBreakTool(char)
	if not char then return nil end
	local held = char:FindFirstChildOfClass("Tool")
	if held then
		pcall(function() held:Activate() end)
		return held
	end
	local bp = player:FindFirstChildOfClass("Backpack")
	if bp then
		for _, t in ipairs(bp:GetChildren()) do
			if t:IsA("Tool") then
				local ln = string.lower(t.Name)
				if string.find(ln, "pick") or string.find(ln, "hammer") or string.find(ln, "break") or string.find(ln, "hit") or string.find(ln, "bat") or string.find(ln, "club") then
					pcall(function()
						t.Parent = char
						t:Activate()
					end)
					return t
				end
			end
		end
		local firstTool = bp:FindFirstChildOfClass("Tool")
		if firstTool then
			pcall(function()
				firstTool.Parent = char
				firstTool:Activate()
			end)
			return firstTool
		end
	end
	return nil
end

local function runAutoBreakEventRockOnce()
	if not UnlockedTier then return end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local bestRockPart, bestDist = nil, math.huge
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") or obj:IsA("BasePart") then
			if not (player.Character and obj:IsDescendantOf(player.Character)) then
				local ln = string.lower(obj.Name)
				if string.find(ln, "rock")
					or string.find(ln, "stone")
					or string.find(ln, "boulder")
					or string.find(ln, "meteor")
					or string.find(ln, "crystal")
					or string.find(ln, "ore")
					or (string.find(ln, "event") and (string.find(ln, "break") or string.find(ln, "mine") or string.find(ln, "hit"))) then
					local p = getPartFromInst(obj)
					if p and p.CanQuery ~= false then
						local d = (p.Position - root.Position).Magnitude
						if d < bestDist then
							bestDist = d
							bestRockPart = p
						end
					end
				end
			end
		end
	end

	if bestRockPart and bestRockPart.Parent then
		pcall(function()
			root.CFrame = bestRockPart.CFrame + Vector3.new(0, 3.5, 0)
		end)
		local tool = equipMiningOrBreakTool(char)
		if tool then
			pcall(function() tool:Activate() end)
			local handle = tool:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") then
				fireTouchSafe(handle, bestRockPart)
			end
		end
		fireTouchSafe(root, bestRockPart)
		triggerInteractionsNear(root, 35, nil)
	end
end

local function runAutoTreadmillOnce()
	if not UnlockedTier then return end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local bestPart, bestDist = nil, math.huge
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") or obj:IsA("BasePart") then
			if string.find(string.lower(obj.Name), "treadmill") then
				local p = getPartFromInst(obj)
				if p then
					local d = (p.Position - root.Position).Magnitude
					if d < bestDist then
						bestDist = d
						bestPart = p
					end
				end
			end
		end
	end

	if bestPart then
		pcall(function()
			root.CFrame = bestPart.CFrame + Vector3.new(0, 3, 0)
		end)
		fireTouchSafe(root, bestPart)
		triggerInteractionsNear(root, 35, "treadmill")
	end
end

local function runAutoUpgradeBaseOnce()
	if not UnlockedTier then return end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	triggerInteractionsNear(root, 85, "base")
	triggerInteractionsNear(root, 85, "upgrade")

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local ln = string.lower(obj.Name)
			if (string.find(ln, "base") and string.find(ln, "upgrade")) or string.find(ln, "upgradebase") then
				fireTouchSafe(root, obj)
			end
		end
	end
end

local function runAutoUpgradeTreadmillOnce()
	if not UnlockedTier then return end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	triggerInteractionsNear(root, 85, "treadmill")
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local ln = string.lower(obj.Name)
			if (string.find(ln, "treadmill") and string.find(ln, "upgrade")) or string.find(ln, "upgradetreadmill") then
				fireTouchSafe(root, obj)
			end
		end
	end
end

local function runAutoBuyTrailsOnce()
	if not UnlockedTier then return end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	triggerInteractionsNear(root, 100, "trail")
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local ln = string.lower(obj.Name)
			if string.find(ln, "trail") and (string.find(ln, "buy") or string.find(ln, "shop") or string.find(ln, "pad")) then
				fireTouchSafe(root, obj)
			end
		end
	end
end

-- ==========================================
-- LOOP AKTIF
-- ==========================================
task.spawn(function()
	while ScreenGui.Parent do
		task.wait(0.45)
		if UnlockedTier then
			if State.AutoStealEgg then pcall(runAutoStealEggOnce) end
			if State.AutoBreakEventRock then pcall(runAutoBreakEventRockOnce) end
			if State.AutoTreadmill then pcall(runAutoTreadmillOnce) end
			if State.AutoUpgradeBase then pcall(runAutoUpgradeBaseOnce) end
			if State.AutoUpgradeTreadmill then pcall(runAutoUpgradeTreadmillOnce) end
			if State.AutoBuyTrails then pcall(runAutoBuyTrailsOnce) end
			if State.EggFinder then pcall(refreshEggFinderEsp) end
		end
	end
end)

player.Idled:Connect(function()
	if UnlockedTier and State.AntiAfk then
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
end)

-- ==========================================
-- UI UTAMA (BISA DIGESER & MINIMIZE "-")
-- ==========================================
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = UDim2.new(0, 470, 0, 325)
MainPanel.Position = UDim2.new(0, 32, 0, 48)
MainPanel.BackgroundColor3 = Color3.fromRGB(16, 10, 14)
MainPanel.BorderSizePixel = 0
MainPanel.Active = true
MainPanel.Visible = false
MainPanel.ZIndex = 3
MainPanel.Parent = ScreenGui
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 10)
local mStroke = Instance.new("UIStroke")
mStroke.Color = Color3.fromRGB(255, 50, 82)
mStroke.Thickness = 2
mStroke.Parent = MainPanel

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, -16, 0, 36)
TopBar.Position = UDim2.new(0, 8, 0, 8)
TopBar.BackgroundColor3 = Color3.fromRGB(34, 16, 23)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.ZIndex = 5
TopBar.Parent = MainPanel
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 7)
makeDraggable(MainPanel, TopBar)

local BenBadge = Instance.new("TextLabel")
BenBadge.Size = UDim2.new(0, 56, 0, 24)
BenBadge.Position = UDim2.new(0, 6, 0.5, -12)
BenBadge.BackgroundColor3 = Color3.fromRGB(225, 42, 72)
BenBadge.Text = "🌶️ BEN"
BenBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
BenBadge.Font = Enum.Font.GothamBlack
BenBadge.TextSize = 11
BenBadge.ZIndex = 6
BenBadge.Parent = TopBar
Instance.new("UICorner", BenBadge).CornerRadius = UDim.new(0, 5)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -104, 1, 0)
TitleLabel.Position = UDim2.new(0, 68, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ADMIN HUB • STEAL AN EGG"
TitleLabel.TextColor3 = Color3.fromRGB(255, 240, 244)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
TitleLabel.ZIndex = 6
TitleLabel.Parent = TopBar

local HideDashBtn = Instance.new("TextButton")
HideDashBtn.Name = "HideDashBtn"
HideDashBtn.Size = UDim2.new(0, 30, 0, 26)
HideDashBtn.Position = UDim2.new(1, -34, 0.5, -13)
HideDashBtn.BackgroundColor3 = Color3.fromRGB(225, 42, 72)
HideDashBtn.Text = "-"
HideDashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideDashBtn.Font = Enum.Font.GothamBlack
HideDashBtn.TextSize = 16
HideDashBtn.ZIndex = 7
HideDashBtn.Parent = TopBar
Instance.new("UICorner", HideDashBtn).CornerRadius = UDim.new(0, 6)

local MiniBenBtn = Instance.new("TextButton")
MiniBenBtn.Name = "MiniBenBtn"
MiniBenBtn.Size = UDim2.new(0, 58, 0, 58)
MiniBenBtn.Position = UDim2.new(0, 20, 0, 80)
MiniBenBtn.BackgroundColor3 = Color3.fromRGB(24, 12, 18)
MiniBenBtn.Text = "🌶️\nBEN"
MiniBenBtn.TextColor3 = Color3.fromRGB(255, 95, 120)
MiniBenBtn.Font = Enum.Font.GothamBlack
MiniBenBtn.TextSize = 12
MiniBenBtn.Visible = false
MiniBenBtn.Active = true
MiniBenBtn.ZIndex = 15
MiniBenBtn.Parent = ScreenGui
Instance.new("UICorner", MiniBenBtn).CornerRadius = UDim.new(1, 0)
local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(255, 50, 82)
miniStroke.Thickness = 2
miniStroke.Parent = MiniBenBtn
makeDraggable(MiniBenBtn)

HideDashBtn.MouseButton1Click:Connect(function()
	MainPanel.Visible = false
	MiniBenBtn.Visible = true
	clampToScreen(MiniBenBtn)
end)

MiniBenBtn.MouseButton1Click:Connect(function()
	MiniBenBtn.Visible = false
	MainPanel.Visible = true
	clampToScreen(MainPanel)
end)

-- ==========================================
-- BODY SCROLL & TOMBOL FITUR
-- ==========================================
local BodyScroll = Instance.new("ScrollingFrame")
BodyScroll.Size = UDim2.new(1, -16, 1, -54)
BodyScroll.Position = UDim2.new(0, 8, 0, 48)
BodyScroll.BackgroundColor3 = Color3.fromRGB(24, 14, 19)
BodyScroll.BorderSizePixel = 0
BodyScroll.ScrollBarThickness = 5
BodyScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
BodyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
BodyScroll.ZIndex = 4
BodyScroll.Parent = MainPanel
Instance.new("UICorner", BodyScroll).CornerRadius = UDim.new(0, 7)

local bLayout = Instance.new("UIListLayout")
bLayout.Padding = UDim.new(0, 7)
bLayout.Parent = BodyScroll
local bPad = Instance.new("UIPadding")
bPad.PaddingTop = UDim.new(0, 7)
bPad.PaddingBottom = UDim.new(0, 7)
bPad.PaddingLeft = UDim.new(0, 7)
bPad.PaddingRight = UDim.new(0, 9)
bPad.Parent = BodyScroll

local function addToggleButton(labelText, getFn, setFn)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.ZIndex = 5
	btn.Parent = BodyScroll
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local function paint()
		local active = getFn()
		btn.BackgroundColor3 = active and Color3.fromRGB(225, 42, 72) or Color3.fromRGB(38, 22, 29)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = string.format("  %s [%s]", labelText, active and "ON" or "OFF")
	end

	paint()
	btn.MouseButton1Click:Connect(function()
		setFn(not getFn())
		paint()
	end)
end

local function buildMenuButtons()
	for _, c in ipairs(BodyScroll:GetChildren()) do
		if c:IsA("GuiObject") then c:Destroy() end
	end

	TitleLabel.Text = string.format("ADMIN HUB [%s • 1 DAY]", UnlockedTier or "LOCKED")

	-- Tombol Filter Rarity Minimal (Common -> Divine)
	local rarityBtn = Instance.new("TextButton")
	rarityBtn.Size = UDim2.new(1, 0, 0, 38)
	rarityBtn.BackgroundColor3 = Color3.fromRGB(52, 26, 38)
	rarityBtn.TextColor3 = Color3.fromRGB(255, 225, 130)
	rarityBtn.Font = Enum.Font.GothamBold
	rarityBtn.TextSize = 12
	rarityBtn.TextXAlignment = Enum.TextXAlignment.Left
	rarityBtn.ZIndex = 5
	rarityBtn.Parent = BodyScroll
	Instance.new("UICorner", rarityBtn).CornerRadius = UDim.new(0, 6)

	local function refreshRarityText()
		local rName = RARITY_ORDER[MinRarityIndex] or "COMMON"
		rarityBtn.Text = string.format("  Min Rarity Auto Steal: %s ke atas (Klik Ganti)", rName)
	end
	refreshRarityText()

	rarityBtn.MouseButton1Click:Connect(function()
		MinRarityIndex = (MinRarityIndex % #RARITY_ORDER) + 1
		refreshRarityText()
	end)

	addToggleButton("Auto Steal Egg", function() return State.AutoStealEgg end, function(v) State.AutoStealEgg = v end)
	addToggleButton("Egg Finder (/s Rate ESP)", function() return State.EggFinder end, function(v)
		State.EggFinder = v
		refreshEggFinderEsp()
	end)
	addToggleButton("Auto Pecahin Batu Event", function() return State.AutoBreakEventRock end, function(v) State.AutoBreakEventRock = v end)
	addToggleButton("Auto Treadmill", function() return State.AutoTreadmill end, function(v) State.AutoTreadmill = v end)
	addToggleButton("Auto Upgrade Base", function() return State.AutoUpgradeBase end, function(v) State.AutoUpgradeBase = v end)
	addToggleButton("Auto Upgrade Treadmill", function() return State.AutoUpgradeTreadmill end, function(v) State.AutoUpgradeTreadmill = v end)
	addToggleButton("Auto Buy Trails", function() return State.AutoBuyTrails end, function(v) State.AutoBuyTrails = v end)
	addToggleButton("Anti-AFK", function() return State.AntiAfk end, function(v) State.AntiAfk = v end)
end

-- ==========================================
-- KEY GATE FRAME (LINK NETLIFY + BIN + 1 HARI)
-- ==========================================
local GateBox = Instance.new("Frame")
GateBox.Size = UDim2.new(0, 360, 0, 235)
GateBox.Position = UDim2.new(0.5, -180, 0.5, -117)
GateBox.BackgroundColor3 = Color3.fromRGB(20, 12, 16)
GateBox.BorderSizePixel = 0
GateBox.Active = true
GateBox.ZIndex = 20
GateBox.Parent = ScreenGui
Instance.new("UICorner", GateBox).CornerRadius = UDim.new(0, 10)
local gSt = Instance.new("UIStroke")
gSt.Color = Color3.fromRGB(255, 55, 85)
gSt.Thickness = 2
gSt.Parent = GateBox
makeDraggable(GateBox)

local gTitle = Instance.new("TextLabel")
gTitle.Size = UDim2.new(1, -20, 0, 28)
gTitle.Position = UDim2.new(0, 10, 0, 8)
gTitle.BackgroundTransparency = 1
gTitle.Text = "🔑 ADMIN HUB • KEY GATE (1 DAY)"
gTitle.TextColor3 = Color3.fromRGB(255, 240, 242)
gTitle.Font = Enum.Font.GothamBold
gTitle.TextSize = 13
gTitle.ZIndex = 21
gTitle.Parent = GateBox

local gLinkBox = Instance.new("TextBox")
gLinkBox.Size = UDim2.new(1, -24, 0, 30)
gLinkBox.Position = UDim2.new(0, 12, 0, 42)
gLinkBox.BackgroundColor3 = Color3.fromRGB(30, 18, 24)
gLinkBox.TextEditable = false
gLinkBox.ClearTextOnFocus = false
gLinkBox.Text = QUEST_LINK_URL
gLinkBox.TextColor3 = Color3.fromRGB(255, 145, 165)
gLinkBox.Font = Enum.Font.Code
gLinkBox.TextSize = 11
gLinkBox.ZIndex = 21
gLinkBox.Parent = GateBox
Instance.new("UICorner", gLinkBox).CornerRadius = UDim.new(0, 6)

local gCopyBtn = Instance.new("TextButton")
gCopyBtn.Size = UDim2.new(1, -24, 0, 28)
gCopyBtn.Position = UDim2.new(0, 12, 0, 78)
gCopyBtn.BackgroundColor3 = Color3.fromRGB(48, 26, 36)
gCopyBtn.Text = "Copy Link Ambil Key (Netlify)"
gCopyBtn.TextColor3 = Color3.fromRGB(255, 220, 228)
gCopyBtn.Font = Enum.Font.GothamBold
gCopyBtn.TextSize = 11
gCopyBtn.ZIndex = 21
gCopyBtn.Parent = GateBox
Instance.new("UICorner", gCopyBtn).CornerRadius = UDim.new(0, 6)

local gKeyInput = Instance.new("TextBox")
gKeyInput.Size = UDim2.new(1, -24, 0, 34)
gKeyInput.Position = UDim2.new(0, 12, 0, 112)
gKeyInput.BackgroundColor3 = Color3.fromRGB(34, 20, 26)
gKeyInput.PlaceholderText = "Tempel Key 1 Hari dari Netlify..."
gKeyInput.Text = ""
gKeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
gKeyInput.Font = Enum.Font.GothamBold
gKeyInput.TextSize = 12
gKeyInput.ZIndex = 21
gKeyInput.Parent = GateBox
Instance.new("UICorner", gKeyInput).CornerRadius = UDim.new(0, 6)

local gVerify = Instance.new("TextButton")
gVerify.Size = UDim2.new(1, -24, 0, 34)
gVerify.Position = UDim2.new(0, 12, 0, 152)
gVerify.BackgroundColor3 = Color3.fromRGB(225, 45, 75)
gVerify.Text = "Verifikasi Key & Simpan (writefile)"
gVerify.TextColor3 = Color3.fromRGB(255, 255, 255)
gVerify.Font = Enum.Font.GothamBold
gVerify.TextSize = 12
gVerify.ZIndex = 21
gVerify.Parent = GateBox
Instance.new("UICorner", gVerify).CornerRadius = UDim.new(0, 6)

local gMsg = Instance.new("TextLabel")
gMsg.Size = UDim2.new(1, -24, 0, 30)
gMsg.Position = UDim2.new(0, 12, 0, 192)
gMsg.BackgroundTransparency = 1
gMsg.Text = "Ambil key dari link Netlify di atas lalu verifikasi."
gMsg.TextColor3 = Color3.fromRGB(220, 180, 188)
gMsg.Font = Enum.Font.Gotham
gMsg.TextSize = 11
gMsg.TextWrapped = true
gMsg.ZIndex = 21
gMsg.Parent = GateBox

gCopyBtn.MouseButton1Click:Connect(function()
	local clip = rawget(_G, "setclipboard") or (getgenv and getgenv().setclipboard)
	if type(clip) == "function" then
		pcall(function() clip(QUEST_LINK_URL) end)
		gMsg.TextColor3 = Color3.fromRGB(160, 245, 190)
		gMsg.Text = "Link Netlify disalin ke clipboard!"
	else
		gMsg.TextColor3 = Color3.fromRGB(255, 200, 120)
		gMsg.Text = "Salin link manual dari kotak di atas."
	end
end)

local function unlockHub(tier)
	UnlockedTier = tier
	buildMenuButtons()
	GateBox:Destroy()
	MainPanel.Visible = true
	clampToScreen(MainPanel)
end

gVerify.MouseButton1Click:Connect(function()
	local ok, tier, msg = verifyOneDayKey(gKeyInput.Text)
	if ok and tier then
		unlockHub(tier)
	else
		gMsg.TextColor3 = Color3.fromRGB(255, 95, 115)
		gMsg.Text = msg
	end
end)

-- Cek otomatis sesi lokal writefile jika belum lewat expiresAt
local savedSes = readLocalKeySession()
if savedSes and type(savedSes.key) == "string" and tonumber(savedSes.expiresAt) then
	if os.time() < tonumber(savedSes.expiresAt) then
		local t = (string.upper(tostring(savedSes.tier)) == "VIP") and "VIP" or "REGULAR"
		unlockHub(t)
	end
end