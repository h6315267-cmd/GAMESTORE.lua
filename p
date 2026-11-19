-- [[ MEKNOYU X LIMZ V4 - RENDER OFF - FPS BOOST ]]
-- [[ NO KEY - FREE ]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

_G.On = false
_G.RenderOff = false

local MyRemote = nil
pcall(function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if n:find("hit") or n:find("break") or n:find("egg") or n:find("attack") then
                MyRemote = v
                break
            end
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeknoyuxV4"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 160)
Main.Position = UDim2.new(0.5, -110, 0.5, -80)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
local C = Instance.new("UICorner", Main)
C.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "MEKNOYU X LIMZ V4"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13

local Sub = Instance.new("TextLabel", Main)
Sub.Size = UDim2.new(1, 0, 0, 18)
Sub.Position = UDim2.new(0, 0, 0, 25)
Sub.BackgroundTransparency = 1
Sub.Text = "RENDER OFF • FPS BOOST • ANTI BAN"
Sub.TextColor3 = Color3.fromRGB(255, 255, 255)
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 9

local FpsLabel = Instance.new("TextLabel", Main)
FpsLabel.Size = UDim2.new(1, 0, 0, 18)
FpsLabel.Position = UDim2.new(0, 0, 0, 43)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Text = "FPS: --"
FpsLabel.TextColor3 = Color3.fromRGB(255,255,255)
FpsLabel.Font = Enum.Font.Gotham
FpsLabel.TextSize = 10

local function Btn(text, y, color, cb)
    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(0.9, 0, 0, 32)
    B.Position = UDim2.new(0.05, 0, 0, y)
    B.BackgroundColor3 = color
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255,255,255)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 11
    B.BorderSizePixel = 0
    local CC = Instance.new("UICorner", B)
    CC.CornerRadius = UDim.new(0, 6)
    B.MouseButton1Click:Connect(cb)
    return B
end

local StartBtn = Btn("▶ START ONE HIT", 66, Color3.fromRGB(0, 170, 0), function()
    _G.On = not _G.On
    StartBtn.Text = _G.On and "⏸ STOP" or "▶ START ONE HIT"
    StartBtn.BackgroundColor3 = _G.On and Color3.fromRGB(200,0,0) or Color3.fromRGB(0,170,0)
end)

local RenderBtn = Btn("👁 RENDER : ON", 104, Color3.fromRGB(255, 150, 0), function()
    _G.RenderOff = not _G.RenderOff
    if _G.RenderOff then
        RunService:Set3dRenderingEnabled(false)
        RenderBtn.Text = "👁 RENDER : OFF - FPS BOOST!"
        RenderBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        pcall(function()
            settings().Rendering.QualityLevel = 1
            game:GetService("Lighting").GlobalShadows = false
        end)
    else
        RunService:Set3dRenderingEnabled(true)
        RenderBtn.Text = "👁 RENDER : ON"
        RenderBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    end
end)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.5)
        pcall(function()
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            if _G.RenderOff then
                FpsLabel.Text = "FPS: BOOST ON - RENDER OFF"
            else
                FpsLabel.Text = "FPS: " .. fps .. " - RENDER ON"
            end
        end)
    end
end)

local LastEgg = nil
local LastTime = 0
RunService.Heartbeat:Connect(function()
    if not _G.On then return end
    if tick() - LastTime < 0.5 then return end
    LastTime = tick()
    pcall(function()
        if not LastEgg or not LastEgg.Parent then
            for _, obj in pairs(workspace:GetChildren()) do
                if obj.Name:lower():find("egg") then
                    if obj:IsA("Model") then
                        LastEgg = obj:FindFirstChildOfClass("BasePart") or obj.PrimaryPart
                    elseif obj:IsA("BasePart") then
                        LastEgg = obj
                    end
                    if LastEgg then break end
                end
            end
        end
        if LastEgg and MyRemote then
            MyRemote:FireServer(LastEgg)
        end
    end)
end)

print("MEKNOYU V4 RENDER OFF Loaded!")
