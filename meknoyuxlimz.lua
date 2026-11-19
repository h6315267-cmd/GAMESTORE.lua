-- [[ BREAK & STEAL AN EGG - MEKNOYU X LIMZ - V2 BACK EGG ]]
-- [[ TARGET: TELUR BELAKANG KE 4,3,2,1 - ONE HIT KAPAK ]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BANNER_URL = "https://files.catbox.moe/ecjoqd.jpg"

-- ========== CONFIG ==========
local Config = {
    AutoBreak = false,
    AutoSteal = false,
    AutoCollectGem = true,
    BreakSpeed = 0.3, -- 0.3 aman, 0.1 barbar
    OneHit = true, -- TRUE = Kapak One Hit, langsung pecah
    OneHitPower = 999999, -- Damage kapak one hit
    TargetMode = "Back", -- JANGAN DIGANTI, udah mode Belakang
    BackOrder = {4,3,2,1}, -- Urutan: ke-4 dulu, terus ke-3, ke-2, ke-1, balik lagi ke-4
    TeleportToEgg = true, -- Harus ON biar nyampe ke telur belakang
    TargetEgg = "All",
    FPSBoost = true,
    RenderOff = false,
    AntiAFK = true,
    SafeMode = true,
}

if Config.FPSBoost then
    pcall(function()
        settings().Rendering.QualityLevel = 1
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").FogEnd = 80
    end)
end
if Config.RenderOff then
    pcall(function() RunService:Set3dRenderingEnabled(false) end)
end

-- ========== CARI REMOTE ==========
local MyRemote = nil
local StealRemote = nil
pcall(function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if not MyRemote and (n:find("hit") or n:find("break") or n:find("egg") or n:find("attack") or n:find("damage") or n:find("axe") or n:find("swing")) then
                MyRemote = v
            end
            if not StealRemote and (n:find("steal") or n:find("take") or n:find("collect")) then
                StealRemote = v
            end
        end
    end
end)

-- ========== FUNGSI CARI TELUR - MODE BELAKANG ==========
local function GetEggsSortedBack()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return {} end
    local myPos = Char.HumanoidRootPart.Position
    local eggs = {}
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:lower():find("egg") then
            local part = nil
            if obj:IsA("Model") then
                part = obj:FindFirstChildOfClass("BasePart") or obj.PrimaryPart
            elseif obj:IsA("BasePart") then
                part = obj
            end
            if part then
                if Config.TargetEgg == "All" or obj.Name:lower():find(Config.TargetEgg:lower()) then
                    local dist = (part.Position - myPos).Magnitude
                    table.insert(eggs, {Model = obj, Part = part, Dist = dist})
                end
            end
        end
    end
    -- SORT DARI YANG PALING JAUH -> PALING DEKAT (BELAKANG DULU)
    table.sort(eggs, function(a,b) return a.Dist > b.Dist end)
    return eggs
end

-- Urutan 4,3,2,1
local BackIndex = 1
local function GetBackEgg()
    local eggs = GetEggsSortedBack()
    if #eggs == 0 then return nil, 0, #eggs end
    -- Kalo telur cuma dikit, ambil yang paling belakang aja
    local orderPos = Config.BackOrder[BackIndex]
    if orderPos > #eggs then orderPos = #eggs end -- Kalo telur cuma 2, jangan maksa ambil ke-4
    local target = eggs[orderPos]
    -- Geser ke urutan berikutnya: 4 -> 3 -> 2 -> 1 -> balik ke 4
    BackIndex = BackIndex + 1
    if BackIndex > #Config.BackOrder then BackIndex = 1 end
    return target, target.Dist, #eggs, orderPos
end

-- ========== UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeknoyuxLimzEggV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 290, 0, 480)
Main.Position = UDim2.new(0.5, -145, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
local MC = Instance.new("UICorner", Main)
MC.CornerRadius = UDim.new(0, 14)

local Banner = Instance.new("ImageLabel", Main)
Banner.Size = UDim2.new(1, 0, 0, 110)
Banner.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Banner.Image = BANNER_URL
Banner.ScaleType = Enum.ScaleType.Crop
local BC = Instance.new("UICorner", Banner)
BC.CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 26)
Title.Position = UDim2.new(0, 0, 0, 112)
Title.BackgroundTransparency = 1
Title.Text = "MEKNOYU X LIMZ"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 17

local Sub = Instance.new("TextLabel", Main)
Sub.Size = UDim2.new(1, 0, 0, 16)
Sub.Position = UDim2.new(0, 0, 0, 136)
Sub.BackgroundTransparency = 1
Sub.Text = "BACK EGG 4,3,2,1 • ONE HIT KAPAK"
Sub.TextColor3 = Color3.fromRGB(255, 255, 255)
Sub.Font = Enum.Font.GothamBold
Sub.TextSize = 9

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 16)
Status.Position = UDim2.new(0, 0, 0, 154)
Status.BackgroundTransparency = 1
Status.Text = "Status: Siap • Telur: 0"
Status.TextColor3 = Color3.fromRGB(255, 200, 0)
Status.Font = Enum.Font.Gotham
Status.TextSize = 10

local TargetInfo = Instance.new("TextLabel", Main)
TargetInfo.Size = UDim2.new(1, 0, 0, 16)
TargetInfo.Position = UDim2.new(0, 0, 0, 170)
TargetInfo.BackgroundTransparency = 1
TargetInfo.Text = "Target: Belakang ke-4"
TargetInfo.TextColor3 = Color3.fromRGB(0, 255, 255)
TargetInfo.Font = Enum.Font.GothamBold
TargetInfo.TextSize = 10

local function MakeToggle(text, y, key)
    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(0.9, 0, 0, 30)
    B.Position = UDim2.new(0.05, 0, 0, y)
    B.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
    B.Text = text .. " : " .. (Config[key] and "ON" or "OFF")
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 11
    B.BorderSizePixel = 0
    local Cc = Instance.new("UICorner", B)
    Cc.CornerRadius = UDim.new(0, 8)
    B.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        B.Text = text .. " : " .. (Config[key] and "ON" or "OFF")
        B.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
        if key == "RenderOff" then
            pcall(function() RunService:Set3dRenderingEnabled(not Config.RenderOff) end)
        end
    end)
    return B
end

MakeToggle("💥 AUTO BREAK - ONE HIT", 196, "AutoBreak")
MakeToggle("🥚 AUTO STEAL", 230, "AutoSteal")
MakeToggle("💎 AUTO COLLECT GEM", 264, "AutoCollectGem")
MakeToggle("✈️ TELEPORT TO EGG", 298, "TeleportToEgg")
MakeToggle("🛡️ SAFE MODE", 332, "SafeMode")
MakeToggle("👁 RENDER OFF", 366, "RenderOff")

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0.9, 0, 0, 28)
CloseBtn.Position = UDim2.new(0.05, 0, 0, 430)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseBtn.Text = "❌ CLOSE"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.BorderSizePixel = 0
local CC = Instance.new("UICorner", CloseBtn)
CC.CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    Config.AutoBreak = false
    Config.AutoSteal = false
end)

-- ========== LOGIC UTAMA - BACK 4,3,2,1 + ONE HIT ==========
task.spawn(function()
    while ScreenGui.Parent do
        if Config.AutoBreak or Config.AutoSteal then
            pcall(function()
                local egg, dist, total, orderPos = GetBackEgg()
                if egg then
                    TargetInfo.Text = "Target: Belakang ke-" .. orderPos .. " | Jarak: " .. math.floor(dist) .. " | Total: " .. total
                    Status.Text = "Status: Breaking Belakang ke-" .. orderPos .. " • One Hit ON"

                    -- Teleport ke telur belakang
                    if Config.TeleportToEgg and dist > 15 then
                        local Char = LocalPlayer.Character
                        if Char and Char:FindFirstChild("HumanoidRootPart") then
                            Char.HumanoidRootPart.CFrame = CFrame.new(egg.Part.Position + Vector3.new(0, 5, 3))
                        end
                        task.wait(0.3)
                    end

                    -- ONE HIT KAPAK - Kirim damage gede + spam 3x format beda biar tembus
                    if Config.AutoBreak and MyRemote then
                        if Config.OneHit then
                            -- Cara 1: Damage gede
                            MyRemote:FireServer(egg.Part, Config.OneHitPower)
                            MyRemote:FireServer(egg.Model, Config.OneHitPower)
                            -- Cara 2: Format Hit + Damage
                            MyRemote:FireServer("Hit", egg.Part, Config.OneHitPower)
                            MyRemote:FireServer("Damage", egg.Part, Config.OneHitPower)
                            -- Cara 3: Format Axe
                            MyRemote:FireServer(egg.Part, "Axe", Config.OneHitPower)
                        else
                            MyRemote:FireServer(egg.Part)
                        end
                    end

                    -- STEAL
                    if Config.AutoSteal and StealRemote then
                        StealRemote:FireServer(egg.Part)
                        StealRemote:FireServer(egg.Model)
                    elseif Config.AutoSteal and MyRemote then
                        MyRemote:FireServer("Steal", egg.Part)
                    end

                    -- Collect Gem
                    if Config.AutoCollectGem then
                        for _, obj in pairs(workspace:GetChildren()) do
                            if obj.Name:lower():find("gem") or obj.Name:lower():find("coin") then
                                if obj:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    local d = (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                    if d < 25 then
                                        pcall(function() firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0) end)
                                        pcall(function() firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 1) end)
                                    end
                                end
                            end
                        end
                    end
                else
                    Status.Text = "Status: Cari Telur..."
                end
            end)
            local delay = Config.SafeMode and math.max(Config.BreakSpeed, 0.3) or Config.BreakSpeed
            task.wait(delay)
        else
            task.wait(0.5)
            pcall(function()
                local eggs = GetEggsSortedBack()
                Status.Text = "Status: Idle • Telur: " .. #eggs
            end)
        end
    end
end)

if Config.AntiAFK then
    pcall(function()
        local VU = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end

print("MEKNOYU X LIMZ - BACK 4,3,2,1 - ONE HIT Loaded!")
