-- [[ MEKNOYU X LIMZ - STEAL AN EGG V2 - ANTI LAG + ANTI BAN + UI PRO ]]
-- [[ NO KEY - FREE ]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

_G.AutoBreak = false
_G.AutoSteal = false
_G.OneHit = false
_G.AntiBan = true -- SELALU ON
_G.Speed = 0.25 -- JANGAN DIBAWAH 0.2 BIAR GAK LAG

local BANNER_URL = "https://files.catbox.moe/ecjoqd.jpg"
local BannerAsset = "rbxassetid://0"
pcall(function()
    if getcustomasset and writefile then
        local ok, data = pcall(game.HttpGet, game, BANNER_URL)
        if ok and data and data ~= "" then
            writefile("Meknoyux_Banner.jpg", data)
            BannerAsset = getcustomasset("Meknoyux_Banner.jpg")
        end
    end
end)

-- ========== ANTI BAN SYSTEM ==========
local LastHit = 0
local HitCount = 0

local function HumanDelay()
    -- Delay acak kayak manusia, bukan bot
    -- 0.25 - 0.45 detik, biar server gak curiga
    return math.random(25, 45) / 100
end

local function ShouldHit()
    if not _G.AntiBan then return true end
    local now = tick()
    -- Max 3 hit per detik, kalo lebih, skip
    if now - LastHit < 0.3 then return false end
    LastHit = now
    HitCount = HitCount + 1
    -- Tiap 30 hit, istirahat 1 detik biar kayak manusia
    if HitCount % 30 == 0 then
        task.wait(1)
    end
    return true
end

-- Cari Remote sekali aja, jangan tiap detik scan semua!
local CachedRemotes = {}
pcall(function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            if n:find("hit") or n:find("break") or n:find("attack") or n:find("click") or n:find("damage") or n:find("egg") or n:find("steal") or n:find("collect") then
                table.insert(CachedRemotes, v)
            end
        end
    end
end)
print("MEKNOYU - Remote ketemu: " .. #CachedRemotes)

-- ========== UI PRO - BAGUS + GAK LAG ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeknoyuxV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 460)
Main.Position = UDim2.new(0.5, -160, 0.5, -230)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 16)

-- Shadow biar keliatan PRO
local Shadow = Instance.new("ImageLabel", Main)
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0,0,0)
Shadow.ImageTransparency = 0.5
Shadow.ZIndex = 0
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)

-- BANNER
local BG = Instance.new("ImageLabel", Main)
BG.Size = UDim2.new(1, 0, 0, 140)
BG.BackgroundTransparency = 1
BG.Image = BannerAsset
BG.ScaleType = Enum.ScaleType.Crop
BG.ZIndex = 1
local BGCorner = Instance.new("UICorner", BG)
BGCorner.CornerRadius = UDim.new(0, 16)

local Dark = Instance.new("Frame", Main)
Dark.Size = UDim2.new(1, 0, 0, 140)
Dark.BackgroundColor3 = Color3.fromRGB(0,0,0)
Dark.BackgroundTransparency = 0.35
Dark.BorderSizePixel = 0
Dark.ZIndex = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "🌶️ MEKNOYU X LIMZ"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.ZIndex = 3

local Sub = Instance.new("TextLabel", Main)
Sub.Size = UDim2.new(1, 0, 0, 22)
Sub.Position = UDim2.new(0, 0, 0, 52)
Sub.BackgroundTransparency = 1
Sub.Text = "STEAL AN EGG  •  V2 ANTI LAG"
Sub.TextColor3 = Color3.fromRGB(255, 200, 0)
Sub.Font = Enum.Font.GothamBold
Sub.TextSize = 13
Sub.ZIndex = 3

local StatusLabel = Instance.new("TextLabel", Main)
StatusLabel.Size = UDim2.new(0.85, 0, 0, 22)
StatusLabel.Position = UDim2.new(0.075, 0, 0, 82)
StatusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
StatusLabel.Text = "● ANTI BAN : ON  •  ANTI LAG : ON"
StatusLabel.TextColor3 = Color3.fromRGB(255,255,255)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 11
StatusLabel.ZIndex = 3
local SLCorner = Instance.new("UICorner", StatusLabel)
SLCorner.CornerRadius = UDim.new(0, 20)

local SL = Instance.new("TextLabel", Main)
SL.Size = UDim2.new(1, 0, 0, 18)
SL.Position = UDim2.new(0, 0, 0, 112)
SL.BackgroundTransparency = 1
SL.Text = "JOIN SL: whatsapp.com/channel/0029Vb931ZM9Bb5ttQxYtL0z"
SL.TextColor3 = Color3.fromRGB(255,255,255)
SL.Font = Enum.Font.Gotham
SL.TextSize = 9
SL.ZIndex = 3

-- Tombol PRO dengan animasi
local function MakeButton(text, y, color, callback)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0.85, 0, 0, 44)
    Btn.Position = UDim2.new(0.075, 0, 0, y)
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    local C = Instance.new("UICorner", Btn)
    C.CornerRadius = UDim.new(0, 12)
    -- Efek klik
    Btn.MouseButton1Down:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.83, 0, 0, 42)}):Play()
    end)
    Btn.MouseButton1Up:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.85, 0, 0, 44)}):Play()
    end)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local OneHitBtn = MakeButton("💥 ONE HIT : OFF", 155, Color3.fromRGB(60,60,70), function()
    _G.OneHit = not _G.OneHit
    OneHitBtn.Text = _G.OneHit and "💥 ONE HIT : ON" or "💥 ONE HIT : OFF"
    OneHitBtn.BackgroundColor3 = _G.OneHit and Color3.fromRGB(220, 30, 30) or Color3.fromRGB(60,60,70)
end)

local BreakBtn = MakeButton("🥚 AUTO BREAK : OFF", 208, Color3.fromRGB(60,60,70), function()
    _G.AutoBreak = not _G.AutoBreak
    BreakBtn.Text = _G.AutoBreak and "🥚 AUTO BREAK : ON" or "🥚 AUTO BREAK : OFF"
    BreakBtn.BackgroundColor3 = _G.AutoBreak and Color3.fromRGB(0, 170, 60) or Color3.fromRGB(60,60,70)
end)

local StealBtn = MakeButton("👑 AUTO STEAL : OFF", 261, Color3.fromRGB(60,60,70), function()
    _G.AutoSteal = not _G.AutoSteal
    StealBtn.Text = _G.AutoSteal and "👑 AUTO STEAL : ON" or "👑 AUTO STEAL : OFF"
    StealBtn.BackgroundColor3 = _G.AutoSteal and Color3.fromRGB(150, 80, 255) or Color3.fromRGB(60,60,70)
end)

local AllBtn = MakeButton("🔥 NYALAIN SEMUA - ANTI LAG", 314, Color3.fromRGB(255, 90, 0), function()
    _G.OneHit = true; _G.AutoBreak = true; _G.AutoSteal = true
    OneHitBtn.Text = "💥 ONE HIT : ON"; OneHitBtn.BackgroundColor3 = Color3.fromRGB(220,30,30)
    BreakBtn.Text = "🥚 AUTO BREAK : ON"; BreakBtn.BackgroundColor3 = Color3.fromRGB(0,170,60)
    StealBtn.Text = "👑 AUTO STEAL : ON"; StealBtn.BackgroundColor3 = Color3.fromRGB(150,80,255)
end)

local CloseBtn = MakeButton("❌ CLOSE", 367, Color3.fromRGB(35,35,45), function()
    ScreenGui:Destroy()
    _G.AutoBreak = false; _G.AutoSteal = false; _G.OneHit = false
end)

local FpsLabel = Instance.new("TextLabel", Main)
FpsLabel.Size = UDim2.new(1, 0, 0, 18)
FpsLabel.Position = UDim2.new(0, 0, 0, 420)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Text = "FPS: 60  •  PING: 30ms  •  MEKNOYU V2"
FpsLabel.TextColor3 = Color3.fromRGB(150,150,150)
FpsLabel.Font = Enum.Font.Gotham
FpsLabel.TextSize = 9

-- FPS Counter biar keliatan gak lag
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        pcall(function()
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            FpsLabel.Text = "FPS: " .. fps .. "  •  HIT: " .. HitCount .. "  •  MEKNOYU V2 - ANTI LAG"
        end)
    end
end)

-- ========== LOGIC ANTI LAG ==========
-- Pake Heartbeat, bukan while true spam
local EggCache = nil
local LastScan = 0

RunService.Heartbeat:Connect(function()
    if not _G.AutoBreak and not _G.OneHit and not _G.AutoSteal then return end
    if not ShouldHit() then return end

    -- Scan egg tiap 2 detik aja, jangan tiap frame!
    if tick() - LastScan > 2 then
        LastScan = tick()
        EggCache = nil
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("egg") and obj:IsA("BasePart") then
                    EggCache = obj
                    break
                end
            end
        end)
    end

    if not EggCache then return end

    pcall(function()
        -- ANTI BAN: Cuma fire 1-2x, bukan 20x!
        local times = _G.OneHit and 2 or 1
        for i = 1, times do
            for _, remote in pairs(CachedRemotes) do
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(EggCache)
                    -- Kasih delay kecil antar remote biar gak ke-detect spam
                    task.wait(0.02)
                elseif remote:IsA("RemoteFunction") then
                    pcall(function() remote:InvokeServer(EggCache, 999999) end)
                end
            end
        end

        -- Auto Steal - ambil telur orang
        if _G.AutoSteal then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                -- Teleport deket telur tapi jangan nempel banget biar gak ke-detect teleport
                if (EggCache.Position - hrp.Position).Magnitude > 10 then
                    hrp.CFrame = EggCache.CFrame + Vector3.new(3, 0, 3)
                end
            end
        end

        -- Delay manusiawi
        task.wait(HumanDelay())
    end)
end)

print("MEKNOYU X LIMZ V2 Loaded! Anti Lag + Anti Ban ON!")
