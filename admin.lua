local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- ==========================================
-- KONFIGURASI JSONBIN, QUEST LINK & 1 HARI
-- ==========================================
local JSONBIN_BIN_ID = "6b00e78cffd5d16053d26a11"
local JSONBIN_API_KEY = "$2a$10$UpLTAelTQemzALH0qMFlU.qubFu6iLDTCfJXhqmRea9RHXzCmbFnC"
local QUEST_LINK_URL = "https://your-quest-link-here"
local ONE_DAY_SECONDS = 86400 -- 1 hari (24 jam)
local LOCAL_KEY_FILE = "AdminHub_6b00e78_1Day.json"

local function cleanKey(raw)
	if type(raw) ~= "string" then return "" end
	return string.upper(string.gsub(raw, "%s+", ""))
end

-- ==========================================
-- FILE I/O (WRITEFILE / READFILE)
-- ==========================================
local function getFileApi()
	local wf = rawget(_G, "writefile") or (getgenv and getgenv().writefile)
	local rf = rawget(_G, "readfile") or (getgenv and getgenv().readfile)
	local ifn = rawget(_G, "isfile") or (getgenv and getgenv().isfile)
	return wf, rf, ifn
end

local function saveSessionFile(keyStr, tierStr, expiresAt)
	local wf = getFileApi()
	if type(wf) ~= "function" then return false end
	local payload = HttpService:JSONEncode({
		key = cleanKey(keyStr),
		tier = tierStr,
		expiresAt = expiresAt,
		savedAt = os.time(),
	})
	return pcall(function()
		wf(LOCAL_KEY_FILE, payload)
	end)
end

local function loadSessionFile()
	local _, rf, ifn = getFileApi()
	if type(rf) ~= "function" then return nil end

	if type(ifn) == "function" then
		local okEx, exists = pcall(function() return ifn(LOCAL_KEY_FILE) end)
		if not (okEx and exists) then return nil end
	end

	local okRead, raw = pcall(function() return rf(LOCAL_KEY_FILE) end)
	if not okRead or type(raw) ~= "string" or raw == "" then return nil end

	local okDec, data = pcall(function() return HttpService:JSONDecode(raw) end)
	if okDec and type(data) == "table" then
		return data
	end
	return nil
end

-- ==========================================
-- VERIFIKASI KEY DARI JSONBIN (1 HARI)
-- ==========================================
local function pullBinRecord()
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
		return nil, "Gagal koneksi ke JSONBin. Cek HTTP executor / koneksi."
	end

	local okDec, decoded = pcall(function() return HttpService:JSONDecode(body) end)
	if not okDec or type(decoded) ~= "table" then
		return nil, "Respon JSON dari JSONBin tidak terbaca."
	end

	local record = (type(decoded.record) == "table") and decoded.record or decoded
	return record, nil
end

local function verifyKeyFromBin(userInputKey)
	local k = cleanKey(userInputKey)
	if k == "" then
		return false, nil, "Masukkan key terlebih dahulu."
	end

	local now = os.time()
	local record, err = pullBinRecord()
	if not record then
		return false, nil, err
	end

	local keysMap = record.keys
	if type(keysMap) ~= "table" then
		return false, nil, "Field 'keys' belum ada di isi JSON bin."
	end

	local item = keysMap[k]
	if type(item) ~= "table" then
		return false, nil, "Key tidak ditemukan di bin atau belum di-generate."
	end

	local tier = string.upper(tostring(item.tier or "REGULAR"))
	if tier ~= "VIP" then
		tier = "REGULAR"
	end

	local expAt = tonumber(item.expiresAt)
	if not expAt and tonumber(item.createdAt) then
		expAt = tonumber(item.createdAt) + ONE_DAY_SECONDS
	end
	if not expAt then
		expAt = now + ONE_DAY_SECONDS
	end

	if now >= expAt then
		return false, tier, "Key 1 hari ini sudah expired."
	end

	saveSessionFile(k, tier, expAt)
	local sisaJam = math.max(1, math.ceil((expAt - now) / 3600))
	return true, tier, string.format("Key aktif (%s) • Sisa %d jam", tier, sisaJam)
end

-- ==========================================
-- GUI UTAMA & FITUR ADMIN HUB
-- ==========================================
local function getGuiParent()
	local ok, res = pcall(function()
		local f = Instance.new("Folder")
		f.Name = "AdminHubBinParentTest"
		f.Parent = CoreGui
		f:Destroy()
		return CoreGui
	end)
	return (ok and res) or player:WaitForChild("PlayerGui")
end

local parentGui = getGuiParent()
local prev = parentGui:FindFirstChild("AdminHubBinUI")
if prev then prev:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminHubBinUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = parentGui end)
if not ScreenGui.Parent then
	ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

local UnlockedTier = nil
local State = {
	AutoSteal = false,
	Speed = false,
	InfJump = false,
	AntiAfk = false,
	Wallhack = false,
}

local function findNearestTarget()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return nil, nil end

	local bestPart, bestDist = nil, math.huge
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") or obj:IsA("BasePart") then
			if not (player.Character and obj:IsDescendantOf(player.Character)) then
				local ln = string.lower(obj.Name)
				if string.find(ln, "egg") or string.find(ln, "pet") then
					local p = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)))
					if p and p.Parent then
						local dist = (p.Position - root.Position).Magnitude
						if dist < bestDist then
							bestDist = dist
							bestPart = p
						end
					end
				end
			end
		end
	end
	return root, bestPart
end

local function stealOnce()
	if not UnlockedTier then return end
	local root, target = findNearestTarget()
	if not root or not target then return end

	pcall(function() root.CFrame = target.CFrame + Vector3.new(0, 3, 0) end)

	local touchFn = rawget(_G, "firetouchinterest") or (getgenv and getgenv().firetouchinterest)
	if type(touchFn) == "function" then
		pcall(function()
			touchFn(root, target, 0)
			task.wait(0.02)
			touchFn(root, target, 1)
		end)
	end

	local promptFn = rawget(_G, "fireproximityprompt") or (getgenv and getgenv().fireproximityprompt)
	if type(promptFn) == "function" then
		for _, pr in ipairs(workspace:GetDescendants()) do
			if pr:IsA("ProximityPrompt") and pr.Parent and pr.Parent:IsA("BasePart") then
				if (pr.Parent.Position - root.Position).Magnitude <= 30 then
					pcall(function() promptFn(pr) end)
				end
			end
		end
	end
end

task.spawn(function()
	while ScreenGui.Parent do
		task.wait(0.45)
		if UnlockedTier and State.AutoSteal then
			pcall(stealOnce)
		end
	end
end)

RunService.Heartbeat:Connect(function()
	if not UnlockedTier then return end
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum and State.Speed then
		pcall(function() hum.WalkSpeed = 50 end)
	end
end)

RunService.Stepped:Connect(function()
	if UnlockedTier == "VIP" and State.Wallhack and player.Character then
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if UnlockedTier and State.InfJump then
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
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
-- PANEL HUB UTAMA (TERKUNCI SAMPAI KEY VALID)
-- ==========================================
local HubMain = Instance.new("Frame")
HubMain.Size = UDim2.new(0, 440, 0, 270)
HubMain.Position = UDim2.new(0.5, -220, 0.5, -135)
HubMain.BackgroundColor3 = Color3.fromRGB(18, 11, 15)
HubMain.BorderSizePixel = 0
HubMain.Visible = false
HubMain.ZIndex = 3
HubMain.Parent = ScreenGui
Instance.new("UICorner", HubMain).CornerRadius = UDim.new(0, 10)
local hStroke = Instance.new("UIStroke")
hStroke.Color = Color3.fromRGB(255, 55, 85)
hStroke.Thickness = 2
hStroke.Parent = HubMain

local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(1, -20, 0, 34)
HubTitle.Position = UDim2.new(0, 10, 0, 10)
HubTitle.BackgroundColor3 = Color3.fromRGB(36, 18, 25)
HubTitle.Text = "🌶️ ADMIN HUB • BIN 6b00e78"
HubTitle.TextColor3 = Color3.fromRGB(255, 240, 244)
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextSize = 13
HubTitle.ZIndex = 4
HubTitle.Parent = HubMain
Instance.new("UICorner", HubTitle).CornerRadius = UDim.new(0, 7)

local HubScroll = Instance.new("ScrollingFrame")
HubScroll.Size = UDim2.new(1, -20, 1, -58)
HubScroll.Position = UDim2.new(0, 10, 0, 50)
HubScroll.BackgroundColor3 = Color3.fromRGB(25, 15, 20)
HubScroll.BorderSizePixel = 0
HubScroll.ScrollBarThickness = 5
HubScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
HubScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
HubScroll.ZIndex = 4
HubScroll.Parent = HubMain
Instance.new("UICorner", HubScroll).CornerRadius = UDim.new(0, 7)

local hsLayout = Instance.new("UIListLayout")
hsLayout.Padding = UDim.new(0, 7)
hsLayout.Parent = HubScroll
local hsPad = Instance.new("UIPadding")
hsPad.PaddingTop = UDim.new(0, 7)
hsPad.PaddingBottom = UDim.new(0, 7)
hsPad.PaddingLeft = UDim.new(0, 7)
hsPad.PaddingRight = UDim.new(0, 9)
hsPad.Parent = HubScroll

local function addToggleItem(labelText, vipOnly, getFn, setFn)
	local locked = vipOnly and (UnlockedTier ~= "VIP")
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.ZIndex = 5
	btn.Parent = HubScroll
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	if locked then
		btn.BackgroundColor3 = Color3.fromRGB(28, 22, 26)
		btn.TextColor3 = Color3.fromRGB(150, 130, 136)
		btn.Text = "  🔒 " .. labelText .. " [VIP ONLY]"
		return
	end

	local function refresh()
		local active = getFn()
		btn.BackgroundColor3 = active and Color3.fromRGB(225, 45, 75) or Color3.fromRGB(38, 23, 30)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = string.format("  %s [%s]", labelText, active and "ON" or "OFF")
	end

	refresh()
	btn.MouseButton1Click:Connect(function()
		setFn(not getFn())
		refresh()
	end)
end

local function buildUnlockedHub()
	for _, c in ipairs(HubScroll:GetChildren()) do
		if c:IsA("GuiObject") then c:Destroy() end
	end
	HubTitle.Text = string.format("🌶️ ADMIN HUB [%s • 1 DAY]", UnlockedTier or "LOCKED")
	addToggleItem("Auto Steal", false, function() return State.AutoSteal end, function(v) State.AutoSteal = v end)
	addToggleItem("Speed Boost (50)", false, function() return State.Speed end, function(v) State.Speed = v end)
	addToggleItem("Infinite Jump", false, function() return State.InfJump end, function(v) State.InfJump = v end)
	addToggleItem("Anti-AFK", false, function() return State.AntiAfk end, function(v) State.AntiAfk = v end)
	addToggleItem("Wallhack (VIP)", true, function() return State.Wallhack end, function(v) State.Wallhack = v end)
end

-- ==========================================
-- KEY GATE FRAME
-- ==========================================
local GateBox = Instance.new("Frame")
GateBox.Size = UDim2.new(0, 360, 0, 235)
GateBox.Position = UDim2.new(0.5, -180, 0.5, -117)
GateBox.BackgroundColor3 = Color3.fromRGB(20, 12, 16)
GateBox.BorderSizePixel = 0
GateBox.ZIndex = 20
GateBox.Parent = ScreenGui
Instance.new("UICorner", GateBox).CornerRadius = UDim.new(0, 10)
local gSt = Instance.new("UIStroke")
gSt.Color = Color3.fromRGB(255, 55, 85)
gSt.Thickness = 2
gSt.Parent = GateBox

local gTitle = Instance.new("TextLabel")
gTitle.Size = UDim2.new(1, -20, 0, 28)
gTitle.Position = UDim2.new(0, 10, 0, 8)
gTitle.BackgroundTransparency = 1
gTitle.Text = "🔑 ADMIN HUB • BIN 6b00e78 (1 DAY)"
gTitle.TextColor3 = Color3.fromRGB(255, 240, 242)
gTitle.Font = Enum.Font.GothamBold
gTitle.TextSize = 13
gTitle.ZIndex = 21
gTitle.Parent = GateBox

local gLink = Instance.new("TextBox")
gLink.Size = UDim2.new(1, -24, 0, 30)
gLink.Position = UDim2.new(0, 12, 0, 42)
gLink.BackgroundColor3 = Color3.fromRGB(30, 18, 24)
gLink.TextEditable = false
gLink.ClearTextOnFocus = false
gLink.Text = QUEST_LINK_URL
gLink.TextColor3 = Color3.fromRGB(255, 145, 165)
gLink.Font = Enum.Font.Code
gLink.TextSize = 11
gLink.ZIndex = 21
gLink.Parent = GateBox
Instance.new("UICorner", gLink).CornerRadius = UDim.new(0, 6)

local gCopyLink = Instance.new("TextButton")
gCopyLink.Size = UDim2.new(1, -24, 0, 28)
gCopyLink.Position = UDim2.new(0, 12, 0, 78)
gCopyLink.BackgroundColor3 = Color3.fromRGB(48, 26, 36)
gCopyLink.Text = "Copy Link Quest"
gCopyLink.TextColor3 = Color3.fromRGB(255, 220, 228)
gCopyLink.Font = Enum.Font.GothamBold
gCopyLink.TextSize = 11
gCopyLink.ZIndex = 21
gCopyLink.Parent = GateBox
Instance.new("UICorner", gCopyLink).CornerRadius = UDim.new(0, 6)

local gInput = Instance.new("TextBox")
gInput.Size = UDim2.new(1, -24, 0, 34)
gInput.Position = UDim2.new(0, 12, 0, 112)
gInput.BackgroundColor3 = Color3.fromRGB(34, 20, 26)
gInput.PlaceholderText = "Tempel Key dari Bin 6b00e78..."
gInput.Text = ""
gInput.TextColor3 = Color3.fromRGB(255, 255, 255)
gInput.Font = Enum.Font.GothamBold
gInput.TextSize = 12
gInput.ZIndex = 21
gInput.Parent = GateBox
Instance.new("UICorner", gInput).CornerRadius = UDim.new(0, 6)

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
gMsg.Text = "Ambil key lalu verifikasi untuk membuka ADMIN HUB."
gMsg.TextColor3 = Color3.fromRGB(220, 180, 188)
gMsg.Font = Enum.Font.Gotham
gMsg.TextSize = 11
gMsg.TextWrapped = true
gMsg.ZIndex = 21
gMsg.Parent = GateBox

gCopyLink.MouseButton1Click:Connect(function()
	local clip = rawget(_G, "setclipboard") or (getgenv and getgenv().setclipboard)
	if type(clip) == "function" then
		pcall(function() clip(QUEST_LINK_URL) end)
		gMsg.TextColor3 = Color3.fromRGB(160, 245, 190)
		gMsg.Text = "Link quest disalin ke clipboard!"
	else
		gMsg.TextColor3 = Color3.fromRGB(255, 200, 120)
		gMsg.Text = "Salin manual link dari kotak di atas."
	end
end)

local function unlockHub(tier)
	UnlockedTier = tier
	buildUnlockedHub()
	GateBox:Destroy()
	HubMain.Visible = true
end

gVerify.MouseButton1Click:Connect(function()
	local ok, tier, msg = verifyKeyFromBin(gInput.Text)
	if ok and tier then
		unlockHub(tier)
	else
		gMsg.TextColor3 = Color3.fromRGB(255, 95, 115)
		gMsg.Text = msg
	end
end)

-- Cek otomatis sesi lokal writefile jika belum lewat expiresAt
local savedSes = loadSessionFile()
if savedSes and type(savedSes.key) == "string" and tonumber(savedSes.expiresAt) then
	if os.time() < tonumber(savedSes.expiresAt) then
		local t = (string.upper(tostring(savedSes.tier)) == "VIP") and "VIP" or "REGULAR"
		unlockHub(t)
	end
end
