-- [[ FISH IT - BY FISCCOUNT x MEKNOYU X LIMZ ]]
-- [[ AUTO FISH CEPAT - TELEPORT PULAU - AUTO TRADE ]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- BANNER CATBOX MEKNOYUXLIMZ - UDAH FIX
local BANNER_URL = "https://files.catbox.moe/ecjoqd.jpg"

_G.AutoFish = false
_G.AutoTradeAccept = false
_G.AutoTrade = false
_G.FishSpeed = 0.05

-- ========== CARI REMOTE FISH IT ==========
local Remotes = {}
pcall(function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            if n:find("fish") or n:find("cast") or n:find("reel") or n:find("catch") or n:find("trade") or n:find("accept") then
                Remotes[v.Name] = v
            end
        end
    end
end)

local function GetRemote(keyword)
    for name, remote in pairs(Remotes) do
        if name:lower():find(keyword) then return remote end
    end
    return nil
end

local FishRemote = GetRemote("fish") or GetRemote("cast") or GetRemote("catch")
local TradeRemote = GetRemote("trade")
local AcceptRemote = GetRemote("accept")

-- ========== DAFTAR PULAU FISH IT ==========
local Islands = {
    ["Fisherman Island"] = Vector3.new(0, 10, 0),
    ["Tropical Island"] = Vector3.new(1500, 10, 500),
    ["Volcano Island"] = Vector3.new(-1500, 10, 800),
    ["Snow Island"] = Vector3.new(2000, 10, -1000),
    ["Desert Island"] = Vector3.new(-2000, 10, -1500),
    ["Mushroom Island"] = Vector3.new(1000, 10, 1500),
    ["Treasure Island"] = Vector3.new(-1000, 10, 2000),
    ["Kohana Island"] = Vector3.new(500, 10, -2000),
}

local function TeleportTo(pos)
    pcall(function()
        local Char = LocalPlayer.Character
        if Char and Char:FindFirstChild("HumanoidRootPart") then
            Char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        end
    end)
end

-- ========== UI - BANNER CATBOX ecjoqd.jpg ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeknoyuxLimzFishIt"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 420)
Main.Position = UDim2.new(0.5, -140, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 14)

-- BANNER CATBOX
local Banner = Instance.new("ImageLabel", Main)
Banner.Size = UDim2.new(1, 0, 0, 110)
Banner.Position = UDim2.new(0, 0, 0, 0)
Banner.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Banner.Image = BANNER_URL
Banner.ScaleType = Enum.ScaleType.Crop
local BannerCorner = Instance.new("UICorner", Banner)
BannerCorner.CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 28)
Title.Position = UDim2.new(0, 0, 0, 112)
Title.BackgroundTransparency = 1
Title.Text = "MEKNOYU X LIMZ"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18

local Sub = Instance.new("TextLabel", Main)
Sub.Size = UDim2.new(1, 0, 0, 16)
Sub.Position = UDim2.new(0, 0, 0, 138)
Sub.BackgroundTransparency = 1
Sub.Text = "FISH IT • BY FISCCOUNT • AUTO FISH CEPAT"
Sub.TextColor3 = Color3.fromRGB(255, 255, 255)
Sub.Font = Enum.Font.GothamBold
Sub.TextSize = 9

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 16)
Status.Position = UDim2.new(0, 0, 0, 156)
Status.BackgroundTransparency = 1
Status.Text = "Status: Siap • Idle"
Status.TextColor3 = Color3.fromRGB(255, 200, 0)
Status.Font = Enum.Font.Gotham
Status.TextSize = 10

local function MakeBtn(text, y, color, cb)
    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(0.9, 0, 0, 32)
    B.Position = UDim2.new(0.05, 0, 0, y)
    B.BackgroundColor3 = color
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 12
    B.BorderSizePixel = 0
    local Cc = Instance.new("UICorner", B)
    Cc.CornerRadius = UDim.new(0, 8)
    B.MouseButton1Click:Connect(cb)
    return B
end

local FishBtn = MakeBtn("🎣 AUTO FISH : OFF", 180, Color3.fromRGB(0, 170, 0), function()
    _G.AutoFish = not _G.AutoFish
    FishBtn.Text = _G.AutoFish and "🎣 AUTO FISH : ON - CEPAT!" or "🎣 AUTO FISH : OFF"
    FishBtn.BackgroundColor3 = _G.AutoFish and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 170, 0)
    Status.Text = _G.AutoFish and "Status: Auto Fish Jalan..." or "Status: Siap • Idle"
end)

local AcceptBtn = MakeBtn("🤝 AUTO TERIMA TRADE : OFF", 218, Color3.fromRGB(100, 100, 100), function()
    _G.AutoTradeAccept = not _G.AutoTradeAccept
    AcceptBtn.Text = _G.AutoTradeAccept and "🤝 AUTO TERIMA TRADE : ON" or "🤝 AUTO TERIMA TRADE : OFF"
    AcceptBtn.BackgroundColor3 = _G.AutoTradeAccept and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(100, 100, 100)
end)

local TradeBtn = MakeBtn("💱 AUTO TRADING : OFF", 256, Color3.fromRGB(150, 0, 150), function()
    _G.AutoTrade = not _G.AutoTrade
    TradeBtn.Text = _G.AutoTrade and "💱 AUTO TRADING : ON" or "💱 AUTO TRADING : OFF"
    TradeBtn.BackgroundColor3 = _G.AutoTrade and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(150, 0, 150)
end)

local IslandLabel = Instance.new("TextLabel", Main)
IslandLabel.Size = UDim2.new(1, 0, 0, 16)
IslandLabel.Position = UDim2.new(0, 0, 0, 294)
IslandLabel.BackgroundTransparency = 1
IslandLabel.Text = "— TELEPORT PULAU —"
IslandLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
IslandLabel.Font = Enum.Font.GothamBold
IslandLabel.TextSize = 11

local IslandNames = {}
for name, _ in pairs(Islands) do table.insert(IslandNames, name) end
table.sort(IslandNames)

local CurrentIsland = 1
local IslandBtn = MakeBtn("🏝 TELEPORT : " .. IslandNames[1], 312, Color3.fromRGB(0, 120, 255), function()
    local name = IslandNames[CurrentIsland]
    TeleportTo(Islands[name])
    Status.Text = "Status: Teleport ke " .. name
    CurrentIsland = CurrentIsland + 1
    if CurrentIsland > #IslandNames then CurrentIsland = 1 end
    IslandBtn.Text = "🏝 TELEPORT : " .. IslandNames[CurrentIsland]
end)

local NextBtn = MakeBtn("➡ NEXT PULAU : " .. IslandNames[2], 348, Color3.fromRGB(50, 50, 70), function()
    CurrentIsland = CurrentIsland + 1
    if CurrentIsland > #IslandNames then CurrentIsland = 1 end
    IslandBtn.Text = "🏝 TELEPORT : " .. IslandNames[CurrentIsland]
    local nextIdx = CurrentIsland + 1
    if nextIdx > #IslandNames then nextIdx = 1 end
    NextBtn.Text = "➡ NEXT PULAU : " .. IslandNames[nextIdx]
end)

local CloseBtn = MakeBtn("❌ CLOSE", 384, Color3.fromRGB(40, 40, 40), function()
    ScreenGui:Destroy()
    _G.AutoFish = false
    _G.AutoTradeAccept = false
    _G.AutoTrade = false
end)

-- ========== LOGIC AUTO FISH CEPAT ==========
task.spawn(function()
    while ScreenGui.Parent do
        if _G.AutoFish then
            pcall(function()
                if FishRemote then
                    FishRemote:FireServer("Cast")
                    FishRemote:FireServer("StartFishing")
                end
                task.wait(_G.FishSpeed + 0.3)
                if FishRemote then
                    for i = 1, 3 do
                        FishRemote:FireServer("Reel")
                        FishRemote:FireServer("Catch")
                        FishRemote:FireServer("Complete")
                        task.wait(0.05)
                    end
                end
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if PlayerGui then
                    for _, gui in pairs(PlayerGui:GetDescendants()) do
                        if gui:IsA("TextButton") and (gui.Name:lower():find("reel") or gui.Name:lower():find("catch") or gui.Name:lower():find("fish")) then
                            pcall(function() gui:Activate() end)
                        end
                    end
                end
            end)
        end
        task.wait(_G.FishSpeed)
    end
end)

-- ========== LOGIC AUTO TERIMA TRADING ==========
task.spawn(function()
    while ScreenGui.Parent do
        if _G.AutoTradeAccept then
            pcall(function()
                if AcceptRemote then
                    AcceptRemote:FireServer(true)
                    AcceptRemote:FireServer("Accept")
                end
                if TradeRemote then
                    TradeRemote:FireServer("Accept")
                end
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if PlayerGui then
                    for _, gui in pairs(PlayerGui:GetDescendants()) do
                        if gui:IsA("TextButton") and gui.Name:lower():find("accept") then
                            pcall(function()
                                for _, v in pairs(getconnections(gui.MouseButton1Click)) do v:Function() end
                            end)
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ========== LOGIC AUTO TRADING ==========
task.spawn(function()
    while ScreenGui.Parent do
        if _G.AutoTrade then
            pcall(function()
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and LocalPlayer.Character then
                        local dist = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 20 then
                            if TradeRemote then
                                TradeRemote:FireServer(plr)
                                TradeRemote:FireServer("Request", plr)
                            end
                            break
                        end
                    end
                end
            end)
        end
        task.wait(2)
    end
end)

print("FISH IT - MEKNOYU X LIMZ - BY FISCCOUNT Loaded!")
