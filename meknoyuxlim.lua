local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local parentGui = pcall(function() return CoreGui.Name end) and CoreGui or player:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("BreakStealEggCatboxUI") then
    parentGui:FindFirstChild("BreakStealEggCatboxUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BreakStealEggCatboxUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui

-- ==========================================
-- HELPER DRAG (PC & MOBILE TOUCH)
-- ==========================================
local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ==========================================
-- 1. FRAME UTAMA (16x10 -> 480 x 300)
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 300)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 14, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(205, 80, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- ==========================================
-- 2. HIASAN CAT BOX
-- ==========================================
local TopCatDecor = Instance.new("TextLabel")
TopCatDecor.Name = "TopCatDecor"
TopCatDecor.Size = UDim2.new(1, -16, 0, 18)
TopCatDecor.Position = UDim2.new(0, 8, 0, 2)
TopCatDecor.BackgroundTransparency = 1
TopCatDecor.Text = "╔══════════════[ /ᐠ｡ꞈ｡ᐟ\\ 🥚 ]══════════════╗"
TopCatDecor.TextColor3 = Color3.fromRGB(240, 115, 255)
TopCatDecor.Font = Enum.Font.Code
TopCatDecor.TextSize = 13
TopCatDecor.TextScaled = true
TopCatDecor.Parent = MainFrame

local BottomCatDecor = Instance.new("TextLabel")
BottomCatDecor.Name = "BottomCatDecor"
BottomCatDecor.Size = UDim2.new(1, -16, 0, 18)
BottomCatDecor.Position = UDim2.new(0, 8, 1, -20)
BottomCatDecor.BackgroundTransparency = 1
BottomCatDecor.Text = "╚══════════════[  =^._.^= ∫ 🐾 ]══════════════╝"
BottomCatDecor.TextColor3 = Color3.fromRGB(240, 115, 255)
BottomCatDecor.Font = Enum.Font.Code
BottomCatDecor.TextSize = 13
BottomCatDecor.TextScaled = true
BottomCatDecor.Parent = MainFrame

-- ==========================================
-- 3. TOP BAR & TOMBOL X CLOSE
-- ==========================================
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, -20, 0, 34)
TopBar.Position = UDim2.new(0, 10, 0, 20)
TopBar.BackgroundColor3 = Color3.fromRGB(27, 22, 43)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 6)
TopBarCorner.Parent = TopBar

makeDraggable(MainFrame, TopBar)
makeDraggable(MainFrame, MainFrame)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "✦ BREAK & STEAL EGG • CATBOX UI ✦"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(225, 55, 90)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- ==========================================
-- 4. MINI BUTTON BULAT (BISA DI-DRAG)
-- ==========================================
local MiniButton = Instance.new("TextButton")
MiniButton.Name = "MiniButton"
MiniButton.Size = UDim2.new(0, 50, 0, 50)
MiniButton.Position = UDim2.new(0.1, 0, 0.2, 0)
MiniButton.BackgroundColor3 = Color3.fromRGB(26, 20, 44)
MiniButton.Text = "/ᐠ.ꞈ.ᐟ\\"
MiniButton.TextColor3 = Color3.fromRGB(240, 115, 255)
MiniButton.Font = Enum.Font.Code
MiniButton.TextSize = 13
MiniButton.Visible = false
MiniButton.Active = true
MiniButton.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(1, 0)
MiniCorner.Parent = MiniButton

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(205, 80, 255)
MiniStroke.Thickness = 2
MiniStroke.Parent = MiniButton

makeDraggable(MiniButton)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniButton.Visible = true
end)

MiniButton.MouseButton1Click:Connect(function()
    MiniButton.Visible = false
    MainFrame.Visible = true
end)

-- ==========================================
-- 5. AREA KONTEN KIRI (SCROLL ATAS-BAWAH)
-- ==========================================
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(0, 325, 0, 215)
ContentScroll.Position = UDim2.new(0, 10, 0, 60)
ContentScroll.BackgroundColor3 = Color3.fromRGB(22, 18, 36)
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 5
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(205, 80, 255)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentScroll

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 7)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentScroll

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 8)
ContentPadding.PaddingBottom = UDim.new(0, 8)
ContentPadding.PaddingLeft = UDim.new(0, 8)
ContentPadding.PaddingRight = UDim.new(0, 10)
ContentPadding.Parent = ContentScroll

-- ==========================================
-- 6. PANEL TABS KANAN (SCROLL ATAS-BAWAH)
-- ==========================================
local TabsScroll = Instance.new("ScrollingFrame")
TabsScroll.Name = "TabsScroll"
TabsScroll.Size = UDim2.new(0, 125, 0, 215)
TabsScroll.Position = UDim2.new(1, -135, 0, 60)
TabsScroll.BackgroundColor3 = Color3.fromRGB(26, 21, 42)
TabsScroll.BorderSizePixel = 0
TabsScroll.ScrollBarThickness = 4
TabsScroll.ScrollBarImageColor3 = Color3.fromRGB(240, 115, 255)
TabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabsScroll.Parent = MainFrame

local TabsCorner = Instance.new("UICorner")
TabsCorner.CornerRadius = UDim.new(0, 8)
TabsCorner.Parent = TabsScroll

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.Padding = UDim.new(0, 6)
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Parent = TabsScroll

local TabsPadding = Instance.new("UIPadding")
TabsPadding.PaddingTop = UDim.new(0, 8)
TabsPadding.PaddingBottom = UDim.new(0, 8)
TabsPadding.PaddingLeft = UDim.new(0, 6)
TabsPadding.PaddingRight = UDim.new(0, 8)
TabsPadding.Parent = TabsScroll

-- ==========================================
-- 7. LOGIKA FITUR (ANTI-AFK, FPS BOOST, FARM, DLL)
-- ==========================================
local State = {
    AntiAFK = false,
    AutoTapBreak = false,
    AutoCollectNear = false,
    InfJump = false,
    NoClip = false,
}

local toggleStates = {} -- Menyimpan status ON/OFF per nama fitur agar tidak reset saat pindah tab

-- Anti-AFK otomatis mencegah kick saat idle
player.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Auto Tap / Swing tool yang sedang dipegang
task.spawn(function()
    while true do
        task.wait(0.15)
        if State.AutoTapBreak then
            local char = player.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() tool:Activate() end)
            end
        end
    end
end)

-- Auto tarik / sentuh part atau egg di sekitar karakter (untuk item yang pakai touch/proximity)
task.spawn(function()
    while true do
        task.wait(0.25)
        if State.AutoCollectNear then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "egg") or string.find(string.lower(obj.Name), "drop") or string.find(string.lower(obj.Name), "reward")) then
                        if (obj.Position - root.Position).Magnitude <= 35 then
                            pcall(function()
                                firetouchinterest(root, obj, 0)
                                firetouchinterest(root, obj, 1)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfJump then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if State.NoClip and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local function applyFPSBoost()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("BlurEffect") then
            effect.Enabled = false
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = false
        end
    end
end

local function triggerAllPrompts()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local part = prompt.Parent
            if part and part:IsA("BasePart") and (part.Position - root.Position).Magnitude <= 40 then
                pcall(function() fireproximityprompt(prompt) end)
            end
        end
    end
end

local function findNearestTarget(keyword)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local closestPart, closestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), string.lower(keyword)) then
            local dist = (obj.Position - root.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPart = obj
            end
        end
    end
    if closestPart then
        root.CFrame = closestPart.CFrame + Vector3.new(0, 4, 0)
    end
end

-- ==========================================
-- 8. DAFTAR TAB & FITUR BREAK AND STEAL AN EGG
-- ==========================================
local TabData = {
    ["Main"] = {
        {Type = "Toggle", Name = "Anti-AFK (Anti Kick)", Key = "AntiAFK"},
        {Type = "Toggle", Name = "Auto Swing / Break Tool", Key = "AutoTapBreak"},
        {Type = "Toggle", Name = "Auto Collect Egg/Drop", Key = "AutoCollectNear"},
        {Type = "Button", Name = "Instant Interact (Prompt)", Func = triggerAllPrompts},
        {Type = "Button", Name = "FPS Boost (Anti Lag)", Func = applyFPSBoost},
    },
    ["Egg & Event"] = {
        {Type = "Button", Name = "TP ke Egg Terdekat", Func = function() findNearestTarget("egg") end},
        {Type = "Button", Name = "TP ke Event / Drop", Func = function() findNearestTarget("event") end},
        {Type = "Button", Name = "TP ke Base / Safe Zone", Func = function() findNearestTarget("base") end},
        {Type = "Button", Name = "Refresh Server / Rejoin", Func = function()
            TeleportService:Teleport(game.PlaceId, player)
        end},
    },
    ["Player"] = {
        {Type = "Button", Name = "Speed Boost (WalkSpeed 36)", Func = function()
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 36 end
        end},
        {Type = "Button", Name = "Normal Speed (WalkSpeed 16)", Func = function()
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end},
        {Type = "Toggle", Name = "Infinite Jump", Key = "InfJump"},
        {Type = "Toggle", Name = "NoClip (Tembus)", Key = "NoClip"},
        {Type = "Button", Name = "Respawn Karakter", Func = function()
            if player.Character then player.Character:BreakJoints() end
        end},
    },
    ["Server"] = {
        {Type = "Button", Name = "Server Hop (Cari Server Baru)", Func = function()
            TeleportService:Teleport(game.PlaceId, player)
        end},
        {Type = "Button", Name = "Fullbright (Terang)", Func = function()
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
        end},
        {Type = "Button", Name = "Hapus Kabut (No Fog)", Func = function()
            Lighting.FogEnd = 100000
        end},
    },
    ["Update Info"] = {
        {Type = "Button", Name = "╔══[ CATBOX EDITION ]══╗", Func = function() end},
        {Type = "Button", Name = "Anti-AFK + FPS Boost Ready", Func = function() end},
        {Type = "Button", Name = "Rasio 16x10 • Drag & Scroll", Func = function() end},
    }
}

local TabOrder = {"Main", "Egg & Event", "Player", "Server", "Update Info"}
local TabButtons = {}

local function loadTabContent(tabName)
    for _, child in ipairs(ContentScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    ContentScroll.CanvasPosition = Vector2.new(0, 0)

    local items = TabData[tabName] or {}
    for _, item in ipairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 13
        btn.Parent = ContentScroll

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(125, 65, 180)
        stroke.Thickness = 1
        stroke.Parent = btn

        if item.Type == "Toggle" and item.Key then
            local function refreshToggleVisual()
                local active = State[item.Key]
                btn.BackgroundColor3 = active and Color3.fromRGB(145, 45, 215) or Color3.fromRGB(34, 28, 54)
                btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 215, 235)
                btn.Text = string.format("  │ 🐾 %s [%s]", item.Name, active and "ON" or "OFF")
            end

            refreshToggleVisual()
            toggleStates[item.Key] = refreshToggleVisual

            btn.MouseButton1Click:Connect(function()
                State[item.Key] = not State[item.Key]
                refreshToggleVisual()
            end)
        else
            btn.BackgroundColor3 = Color3.fromRGB(34, 28, 54)
            btn.TextColor3 = Color3.fromRGB(240, 240, 250)
            btn.Text = "  │ 🐾 " .. item.Name

            btn.MouseButton1Click:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(205, 80, 255)
                task.wait(0.12)
                btn.BackgroundColor3 = Color3.fromRGB(34, 28, 54)
                if item.Func then
                    item.Func()
                end
            end)
        end
    end
end

for _, tabName in ipairs(TabOrder) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabName .. "Tab"
    tabBtn.Size = UDim2.new(1, 0, 0, 34)
    tabBtn.BackgroundColor3 = Color3.fromRGB(36, 30, 58)
    tabBtn.Text = "┌ " .. tabName .. " ┐"
    tabBtn.TextColor3 = Color3.fromRGB(205, 195, 225)
    tabBtn.Font = Enum.Font.Code
    tabBtn.TextSize = 12
    tabBtn.Parent = TabsScroll

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 6)
    tCorner.Parent = tabBtn

    TabButtons[tabName] = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
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

TabButtons["Main"].BackgroundColor3 = Color3.fromRGB(180, 65, 245)
TabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
loadTabContent("Main")