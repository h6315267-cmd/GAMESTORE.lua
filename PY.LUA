-- [[ MEKNOYUXLIMZ - 100 KEY UNLIMITED + WRITEFILE ]] --
local plr = game.Players.LocalPlayer

local ValidKeys = {
    ["MEKNOYUXLIMZ-83B8-3BO1"] = true, ["MEKNOYUXLIMZ-QJLN-KRSH"] = true,
    ["MEKNOYUXLIMZ-X357-1XAD"] = true, ["MEKNOYUXLIMZ-FPLO-RF8I"] = true,
    ["MEKNOYUXLIMZ-F8FT-MOQ1"] = true, ["MEKNOYUXLIMZ-Y6FK-MWMS"] = true,
    ["MEKNOYUXLIMZ-SXVH-RA0O"] = true, ["MEKNOYUXLIMZ-0496-DAGC"] = true,
    ["MEKNOYUXLIMZ-IWVB-6FUH"] = true, ["MEKNOYUXLIMZ-FSIL-SFJB"] = true,
    ["MEKNOYUXLIMZ-ZANI-ISP0"] = true, ["MEKNOYUXLIMZ-66WF-TP82"] = true,
    ["MEKNOYUXLIMZ-HEDW-6NUB"] = true, ["MEKNOYUXLIMZ-ZFCT-Y9FY"] = true,
    ["MEKNOYUXLIMZ-OTY4-MLZZ"] = true, ["MEKNOYUXLIMZ-672G-6NXM"] = true,
    ["MEKNOYUXLIMZ-S3BZ-A0M0"] = true, ["MEKNOYUXLIMZ-X5NF-AK5C"] = true,
    ["MEKNOYUXLIMZ-TP8R-MOA1"] = true, ["MEKNOYUXLIMZ-DRZK-8QMO"] = true,
    ["MEKNOYUXLIMZ-WJ26-QHZN"] = true, ["MEKNOYUXLIMZ-8FGI-774A"] = true,
    ["MEKNOYUXLIMZ-N6VN-RVN8"] = true, ["MEKNOYUXLIMZ-SPNY-POSX"] = true,
    ["MEKNOYUXLIMZ-8ZDR-IOI6"] = true, ["MEKNOYUXLIMZ-Q3GH-8XR1"] = true,
    ["MEKNOYUXLIMZ-HLD3-C04T"] = true, ["MEKNOYUXLIMZ-ZOQQ-D66Q"] = true,
    ["MEKNOYUXLIMZ-REO7-V7FT"] = true, ["MEKNOYUXLIMZ-FY8T-DAX1"] = true,
    ["MEKNOYUXLIMZ-N26A-K68H"] = true, ["MEKNOYUXLIMZ-AJS0-1J8M"] = true,
    ["MEKNOYUXLIMZ-SQJD-EJWP"] = true, ["MEKNOYUXLIMZ-5J1H-S5Z6"] = true,
    ["MEKNOYUXLIMZ-IHIO-UMN9"] = true, ["MEKNOYUXLIMZ-5XU6-RTLP"] = true,
    ["MEKNOYUXLIMZ-S6G3-E6UB"] = true, ["MEKNOYUXLIMZ-VIJY-P8TN"] = true,
    ["MEKNOYUXLIMZ-W23C-MR5Y"] = true, ["MEKNOYUXLIMZ-VMYT-4NFC"] = true,
    ["MEKNOYUXLIMZ-4N3O-5VQN"] = true, ["MEKNOYUXLIMZ-85O5-LWXC"] = true,
    ["MEKNOYUXLIMZ-L7TD-27ST"] = true, ["MEKNOYUXLIMZ-N9YZ-K286"] = true,
    ["MEKNOYUXLIMZ-UKJ8-1TNN"] = true, ["MEKNOYUXLIMZ-PEV2-9GVR"] = true,
    ["MEKNOYUXLIMZ-J6HB-UUJS"] = true, ["MEKNOYUXLIMZ-YWCA-Q56C"] = true,
    ["MEKNOYUXLIMZ-I1UN-F2WN"] = true, ["MEKNOYUXLIMZ-LPT7-KYZZ"] = true,
    ["MEKNOYUXLIMZ-TBYA-PPYB"] = true, ["MEKNOYUXLIMZ-MDFW-9KZC"] = true,
    ["MEKNOYUXLIMZ-3PA4-D4NC"] = true, ["MEKNOYUXLIMZ-9CEZ-0FTO"] = true,
    ["MEKNOYUXLIMZ-9VND-MVUW"] = true, ["MEKNOYUXLIMZ-VGLW-O7VB"] = true,
    ["MEKNOYUXLIMZ-WUW0-ZN53"] = true, ["MEKNOYUXLIMZ-SQOT-4A7L"] = true,
    ["MEKNOYUXLIMZ-NR6J-HN8X"] = true, ["MEKNOYUXLIMZ-7PO5-B1UI"] = true,
    ["MEKNOYUXLIMZ-LTBN-3XZ6"] = true, ["MEKNOYUXLIMZ-XI8B-HA0M"] = true,
    ["MEKNOYUXLIMZ-MWR2-K1PQ"] = true, ["MEKNOYUXLIMZ-5A81-BBGL"] = true,
    ["MEKNOYUXLIMZ-S55Y-4O59"] = true, ["MEKNOYUXLIMZ-GA9K-LVG4"] = true,
    ["MEKNOYUXLIMZ-M1CY-5IZ3"] = true, ["MEKNOYUXLIMZ-DNVX-1BXS"] = true,
    ["MEKNOYUXLIMZ-07LE-QOOZ"] = true, ["MEKNOYUXLIMZ-5VAK-SB5F"] = true,
    ["MEKNOYUXLIMZ-9DCL-A0FT"] = true, ["MEKNOYUXLIMZ-203H-0HCX"] = true,
    ["MEKNOYUXLIMZ-ORC5-PMW4"] = true, ["MEKNOYUXLIMZ-ACY9-KJD9"] = true,
    ["MEKNOYUXLIMZ-B59U-0P0D"] = true, ["MEKNOYUXLIMZ-HZF6-GK0H"] = true,
    ["MEKNOYUXLIMZ-FXU9-K4EC"] = true, ["MEKNOYUXLIMZ-BMDQ-8ZBB"] = true,
    ["MEKNOYUXLIMZ-9SD0-FVZD"] = true, ["MEKNOYUXLIMZ-5Y2E-3PP0"] = true,
    ["MEKNOYUXLIMZ-AJ0F-GLFD"] = true, ["MEKNOYUXLIMZ-QQV7-WS6M"] = true,
    ["MEKNOYUXLIMZ-95D6-46WM"] = true, ["MEKNOYUXLIMZ-HYQP-1MG6"] = true,
    ["MEKNOYUXLIMZ-K900-2GTC"] = true, ["MEKNOYUXLIMZ-UFT4-FBE7"] = true,
    ["MEKNOYUXLIMZ-0O6D-66N6"] = true, ["MEKNOYUXLIMZ-YLVN-PC69"] = true,
    ["MEKNOYUXLIMZ-IPOC-O6CT"] = true, ["MEKNOYUXLIMZ-E1YV-7RPI"] = true,
    ["MEKNOYUXLIMZ-U248-HXYN"] = true, ["MEKNOYUXLIMZ-WXP4-0ASZ"] = true,
    ["MEKNOYUXLIMZ-QQVS-GMCR"] = true, ["MEKNOYUXLIMZ-QE0D-QSEZ"] = true,
    ["MEKNOYUXLIMZ-3AHZ-TKTD"] = true, ["MEKNOYUXLIMZ-8YCY-KRED"] = true,
    ["MEKNOYUXLIMZ-67ME-W85L"] = true, ["MEKNOYUXLIMZ-L4ZG-HELC"] = true,
    ["MEKNOYUXLIMZ-UYJA-5A04"] = true, ["MEKNOYUXLIMZ-0W5O-X1H8"] = true,
}

local KEY_FILE = "MeknoyuXLimz_Key.txt"

-- 1. CEK APAKAH UDAH PERNAH SAVE KEY
local savedKey = nil
if isfile and isfile(KEY_FILE) then
    local ok, content = pcall(function() return readfile(KEY_FILE) end)
    if ok and content then
        savedKey = string.gsub(content, "%s+", "")
        if ValidKeys[savedKey] then
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="MEKNOYUXLIMZ", Text="Key ke-save! Auto Login...", Duration=3})
            task.wait(0.5)
            mainEngineLoad()
            return
        end
    end
end

-- 2. KALO BELUM ADA, MUNCULIN GUI KEY
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "MeknoyuXLimzKey"
KeyGui.ResetOnSpawn = false
KeyGui.Parent = (gethui and gethui()) or plr:WaitForChild("PlayerGui")
local F = Instance.new("Frame", KeyGui)
F.Size = UDim2.new(0,340,0,190) F.Position = UDim2.new(0.5,-170,0.5,-95)
F.BackgroundColor3 = Color3.fromRGB(20,20,30) F.Active = true F.Draggable = true
Instance.new("UICorner", F).CornerRadius = UDim.new(0,12)
local st = Instance.new("UIStroke", F) st.Color = Color3.fromRGB(255,0,128) st.Thickness = 2
local T = Instance.new("TextLabel", F)
T.Size = UDim2.new(1,0,0,35) T.Position = UDim2.new(0,0,0,10)
T.Text = "🔑 MEKNOYUXLIMZ - KEY" T.TextColor3 = Color3.fromRGB(255,255,255)
T.Font = Enum.Font.GothamBold T.TextSize = 14 T.BackgroundTransparency = 1
local S = Instance.new("TextLabel", F)
S.Size = UDim2.new(1,-20,0,20) S.Position = UDim2.new(0,10,0,42)
S.Text = "Ambil Key di Saluran! Unlimited!" S.TextColor3 = Color3.fromRGB(0,255,150)
S.Font = Enum.Font.Gotham S.TextSize = 11 S.BackgroundTransparency = 1
local Box = Instance.new("TextBox", F)
Box.Size = UDim2.new(1,-20,0,40) Box.Position = UDim2.new(0,10,0,68)
Box.PlaceholderText = "Paste Key dari Saluran..." Box.Text = ""
Box.BackgroundColor3 = Color3.fromRGB(35,35,45) Box.TextColor3 = Color3.fromRGB(255,255,255)
Box.Font = Enum.Font.Code Box.TextSize = 11
Instance.new("UICorner", Box).CornerRadius = UDim.new(0,8)
local CheckBtn = Instance.new("TextButton", F)
CheckBtn.Size = UDim2.new(1,-20,0,35) CheckBtn.Position = UDim2.new(0,10,0,118)
CheckBtn.Text = "✅ CHECK KEY & MASUK" CheckBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
CheckBtn.TextColor3 = Color3.fromRGB(255,255,255) CheckBtn.Font = Enum.Font.GothamBold CheckBtn.TextSize = 12
Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0,8)
local Status = Instance.new("TextLabel", F)
Status.Size = UDim2.new(1,-20,0,16) Status.Position = UDim2.new(0,10,0,160)
Status.Text = "Key ke-save otomatis • Gak perlu isi lagi besok" Status.TextColor3 = Color3.fromRGB(150,150,150)
Status.Font = Enum.Font.Gotham Status.TextSize = 9 Status.BackgroundTransparency = 1
CheckBtn.MouseButton1Click:Connect(function()
    local k = string.gsub(Box.Text, "%s+", "")
    if ValidKeys[k] then
        -- SIMPEN KEY PAKE WRITEFILE - INI INTINYA
        if writefile then
            pcall(function() writefile(KEY_FILE, k) end)
        end
        Status.Text = "✅ KEY VALID! Key ke-save! Loading..." Status.TextColor3 = Color3.fromRGB(0,255,150)
        task.wait(0.5) KeyGui:Destroy() mainEngineLoad()
    else
        Status.Text = "❌ KEY SALAH! Cek Saluran!" Status.TextColor3 = Color3.fromRGB(255,50,50)
        Box.Text = ""
    end
end)
-- Lanjut mainEngineLoad() Hub lu di bawah...
