-- [[ MEKNOYU X LIMZ - STEAL AN EGG - ONE HIT ]]
-- [[ Background: https://files.catbox.moe/ecjoqd.jpg ]]
-- [[ NO KEY - FREE ]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.AutoBreak = false
_G.AutoCollect = false
_G.OneHit = false
_G.BreakDelay = 0.05
_G.CollectRange = 150

local BANNER_URL = "https://files.catbox.moe/ecjoqd.jpg"
local BANNER_FILE = "Meknoyux_Banner.jpg"

-- DOWNLOAD BACKGROUND
local BannerAsset = "rbxassetid://0"
pcall(function()
    if getcustomasset and writefile then
        local ok, data = pcall(game.HttpGet, game, BANNER_URL)
        if ok and data and data ~= "" then
            writefile(BANNER_FILE, data)
            BannerAsset = getcustomasset(BANNER_FILE)
        end
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeknoyuxStealEggOneHit"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 400)
Main.Position = UDim2.new(0.5, -150, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

-- BACKGROUND IMAGE - CATBOX LU
local BG = Instance.new("ImageLabel", Main)
BG.Size = UDim2.new(1, 0, 0, 130)
BG.Position = UDim2.new(0, 0, 0, 0)
BG.BackgroundTransparency = 1
BG.Image = BannerAsset
BG.ScaleType = Enum.ScaleType.Crop
BG.ZIndex = 1
local BGCorner = Instance.new("UICorner", BG)
BGCorner.CornerRadius = UDim.new(0, 12)

-- GELAPIN DIKIT BIAR TEXT KELIATAN
local Dark = Instance.new("Frame", Main)
Dark.Size = UDim2.new(1, 0, 0, 130)
Dark.Position = UDim2.new(0, 0, 0, 0)
Dark.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Dark.BackgroundTransparency = 0.4
Dark.BorderSizePixel = 0
Dark.ZIndex = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "🌶️ MEKNOYU X LIMZ"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextStrokeTransparency = 0
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Title.ZIndex = 3

local Sub = Instance.new("TextLabel", Main)
Sub.Size = UDim2.new(1, 0, 0, 25)
Sub.Position = UDim2.new(0, 0, 0, 50)
Sub.BackgroundTransparency = 1
Sub.Text = "STEAL AN EGG - ONE HIT"
Sub.TextColor3 = Color3.fromRGB(255, 200, 0)
Sub.Font = Enum.Font.GothamBold
Sub.TextSize = 14
Sub.ZIndex = 3

local Sub2 = Instance.new("TextLabel", Main)
Sub2.Size = UDim2.new(1, 0, 0, 20)
Sub2.Position = UDim2.new(0, 0, 0, 75)
Sub2.BackgroundTransparency = 1
Sub2.Text = "NO KEY - FREE - ROMBAK"
Sub2.TextColor3 = Color3.fromRGB(0, 255, 100)
Sub2.Font = Enum.Font.GothamBold
Sub2.TextSize = 12
Sub2.ZIndex = 3

local SLLabel = Instance.new("TextLabel", Main)
SLLabel.Size = UDim2.new(1, 0, 0, 20)
SLLabel.Position = UDim2.new(0, 0, 0, 100)
SLLabel.BackgroundTransparency = 1
SLLabel.Text = "JOIN SL: whatsapp.com/channel/0029Vb931ZM9Bb5ttQxYtL0z"
SLLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SLLabel.Font = Enum.Font.Gotham
SLLabel.TextSize = 9
SLLabel.ZIndex = 3

local function MakeButton(text, y, color, callback)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0.85, 0, 0, 42)
    Btn.Position = UDim2.new(0.075, 0, 0, y)
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.BorderSizePixel = 0
    local C = Instance.new("UICorner", Btn)
    C.CornerRadius = UDim.new(0, 8)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local OneHitBtn = MakeButton("💥 ONE HIT : OFF", 145, Color3.fromRGB(80, 80, 80), function()
    _G.OneHit = not _G.OneHit
    OneHitBtn.Text = "💥 ONE HIT : " .. (_G.OneHit and "ON - 1x PUKUL PECAH!" or "OFF")
    OneHitBtn.BackgroundColor3 = _G.OneHit and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(80, 80, 80)
end)

local BreakBtn = MakeButton("🥚 Auto Break Egg : OFF", 195, Color3.fromRGB(80, 80, 80), function()
    _G.AutoBreak = not _G.AutoBreak
    BreakBtn.Text = "🥚 Auto Break Egg : " .. (_G.AutoBreak and "ON" or "OFF")
    BreakBtn.BackgroundColor3 = _G.AutoBreak and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(80, 80, 80)
end)

local CollectBtn = MakeButton("💎 Auto Collect Permata : OFF", 245, Color3.fromRGB(80, 80, 80), function()
    _G.AutoCollect = not _G.AutoCollect
    CollectBtn.Text = "💎 Auto Collect Permata : " .. (_G.AutoCollect and "ON" or "OFF")
    CollectBtn.BackgroundColor3 = _G.AutoCollect and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(80, 80, 80)
end)

local AllBtn = MakeButton("🔥 NYALAIN SEMUA + ONE HIT", 295, Color3.fromRGB(255, 60, 60), function()
    _G.OneHit = true
    _G.AutoBreak = true
    _G.AutoCollect = true
    OneHitBtn.Text = "💥 ONE HIT : ON - 1x PUKUL PECAH!"
    OneHitBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    BreakBtn.Text = "🥚 Auto Break Egg : ON"
    BreakBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    CollectBtn.Text = "💎 Auto Collect Permata : ON"
    CollectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
end)

local CloseBtn = MakeButton("❌ CLOSE", 345, Color3.fromRGB(40, 40, 40), function()
    ScreenGui:Destroy()
    _G.AutoBreak = false
    _G.AutoCollect = false
    _G.OneHit = false
end)

-- ONE HIT + AUTO BREAK LOGIC
task.spawn(function()
    while true do
        task.wait(_G.BreakDelay)
        if _G.AutoBreak or _G.OneHit then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("egg") and obj:IsA("BasePart") then
                        local times = _G.OneHit and 20 or 1
                        for i = 1, times do
                            for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                                if remote:IsA("RemoteEvent") then
                                    local n = remote.Name:lower()
                                    if n:find("hit") or n:find("break") or n:find("attack") or n:find("click") or n:find("damage") or n:find("egg") then
                                        pcall(function() remote:FireServer(obj) end)
                                        pcall(function() remote:FireServer(obj, 999999) end)
                                        pcall(function() remote:FireServer(obj, 999999999) end)
                                    end
                                end
                                if remote:IsA("RemoteFunction") then
                                    local n = remote.Name:lower()
                                    if n:find("hit") or n:find("break") or n:find("damage") then
                                        pcall(function() remote:InvokeServer(obj, 999999999) end)
                                    end
                                end
                            end
                            if obj:FindFirstChildOfClass("ClickDetector") then
                                fireclickdetector(obj:FindFirstChildOfClass("ClickDetector"))
                            end
                        end
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then for i = 1, 5 do tool:Activate() end end
                        break
                    end
                end
            end)
        end
    end
end)

-- AUTO COLLECT PERMATA
task.spawn(function()
    while true do
        task.wait(0.15)
        if _G.AutoCollect then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                for _, obj in pairs(workspace:GetDescendants()) do
                    local name = obj.Name:lower()
                    if (name:find("gem") or name:find("permata") or name:find("diamond") or name:find("coin") or name:find("money") or name:find("drop")) and obj:IsA("BasePart") then
                        if (obj.Position - hrp.Position).Magnitude < _G.CollectRange then
                            obj.CFrame = hrp.CFrame
                            if obj:FindFirstChildOfClass("TouchTransmitter") then
                                firetouchinterest(hrp, obj, 0)
                                task.wait()
                                firetouchinterest(hrp, obj, 1)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

print("MEKNOYU X LIMZ - STEAL AN EGG ONE HIT Loaded! Background Catbox OK!")
