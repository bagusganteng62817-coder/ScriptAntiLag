-- Anti Lag v2 | LocalScript
-- Fitur: Plastic, No Shadow, No Fog, No Decals, No Particles, Low Graphics,
--        No Atmosphere, No SunRays, No Bloom, No ColorCorrection, No Water

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Warna
local WHITE  = Color3.new(1,1,1)
local GRAY   = Color3.fromRGB(180,180,180)
local DARK1  = Color3.fromRGB(24,24,24)
local DARK2  = Color3.fromRGB(38,38,38)
local DARK3  = Color3.fromRGB(48,48,48)
local DARK4  = Color3.fromRGB(60,60,60)
local GREEN  = Color3.fromRGB(45,130,45)
local RED    = Color3.fromRGB(180,50,50)
local TXT    = Color3.fromRGB(215,215,215)
local HEADER = Color3.fromRGB(65,105,225)  -- biru royal

-- State
local state = {
    plastic=false, shadow=false, fog=false, decals=false, particles=false,
    graphics=false, atmosphere=false, sunrays=false, bloom=false,
    colorcorrection=false, water=false
}

-- Penyimpanan nilai asli
local origMat = {}
local origShadow = {}
local origDecal = {}
local origParticle = {}
local origEffect = {}    -- untuk atmosphere, sunrays, bloom, colorcorrection
local origWater = {}

-- Koneksi listener (untuk disconnect)
local connections = {}

-- ===================== FUNGSI FITUR =====================

-- Plastic Texture
local function applyPlastic(on)
    local function setPlastic(part)
        if part:IsA("BasePart") and part.Material ~= Enum.Material.SmoothPlastic then
            origMat[part] = part.Material
            pcall(function() part.Material = Enum.Material.SmoothPlastic end)
        end
    end
    local function restorePlastic(part)
        if origMat[part] then
            pcall(function() part.Material = origMat[part] end)
            origMat[part] = nil
        end
    end

    for _,v in ipairs(workspace:GetDescendants()) do
        if on then setPlastic(v) else restorePlastic(v) end
    end

    if on and not connections.plastic then
        connections.plastic = workspace.DescendantAdded:Connect(function(v)
            if state.plastic then setPlastic(v) end
        end)
    elseif not on and connections.plastic then
        connections.plastic:Disconnect()
        connections.plastic = nil
    end
end

-- Shadow
local function applyShadow(on)
    if on then Lighting.GlobalShadows = false else Lighting.GlobalShadows = true end
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if on then
                origShadow[v] = v.CastShadow
                v.CastShadow = false
            elseif origShadow[v] ~= nil then
                v.CastShadow = origShadow[v]
                origShadow[v] = nil
            end
        end
    end
end

-- Fog
local function applyFog(on)
    if on then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    else
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
    end
end

-- Decals & Textures
local function applyDecals(on)
    local function setDecal(obj)
        if (obj:IsA("Decal") or obj:IsA("Texture")) and obj.Transparency < 1 then
            origDecal[obj] = obj.Transparency
            obj.Transparency = 1
        end
    end
    local function restoreDecal(obj)
        if origDecal[obj] ~= nil then
            obj.Transparency = origDecal[obj]
            origDecal[obj] = nil
        end
    end

    for _,v in ipairs(workspace:GetDescendants()) do
        if on then setDecal(v) else restoreDecal(v) end
    end

    if on and not connections.decals then
        connections.decals = workspace.DescendantAdded:Connect(function(v)
            if state.decals and (v:IsA("Decal") or v:IsA("Texture")) then
                setDecal(v)
            end
        end)
    elseif not on and connections.decals then
        connections.decals:Disconnect()
        connections.decals = nil
    end
end

-- Particles (ParticleEmitter, Fire, Smoke, Sparkles)
local function applyParticles(on)
    local function setParticle(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            origParticle[obj] = obj.Enabled
            obj.Enabled = false
        end
    end
    local function restoreParticle(obj)
        if origParticle[obj] ~= nil then
            obj.Enabled = origParticle[obj]
            origParticle[obj] = nil
        end
    end

    for _,v in ipairs(workspace:GetDescendants()) do
        if on then setParticle(v) else restoreParticle(v) end
    end

    if on and not connections.particles then
        connections.particles = workspace.DescendantAdded:Connect(function(v)
            if state.particles then
                if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    setParticle(v)
                end
            end
        end)
    elseif not on and connections.particles then
        connections.particles:Disconnect()
        connections.particles = nil
    end
end

-- Graphics Level
local function applyGraphics(on)
    if on then
        pcall(function() settings().GraphicsQualityLevel = 1 end)
    else
        pcall(function() settings().GraphicsQualityLevel = 10 end)
    end
end

-- Efek Lighting (Atmosphere, SunRays, Bloom, ColorCorrection)
local function applyEffect(on, className)
    local function setEffect(obj)
        if obj:IsA(className) then
            origEffect[obj] = obj.Enabled
            obj.Enabled = false
        end
    end
    local function restoreEffect(obj)
        if origEffect[obj] ~= nil then
            obj.Enabled = origEffect[obj]
            origEffect[obj] = nil
        end
    end

    for _,v in ipairs(Lighting:GetDescendants()) do
        if on then setEffect(v) else restoreEffect(v) end
    end

    local key = className:lower()
    if on and not connections[key] then
        connections[key] = Lighting.DescendantAdded:Connect(function(v)
            if state[key] and v:IsA(className) then
                setEffect(v)
            end
        end)
    elseif not on and connections[key] then
        connections[key]:Disconnect()
        connections[key] = nil
    end
end

-- Water (bagian dengan Material.Water)
local function applyWater(on)
    local function setWater(part)
        if part:IsA("BasePart") and part.Material == Enum.Material.Water then
            origWater[part] = part.Transparency
            part.Transparency = 1
        end
    end
    local function restoreWater(part)
        if origWater[part] ~= nil then
            part.Transparency = origWater[part]
            origWater[part] = nil
        end
    end

    for _,v in ipairs(workspace:GetDescendants()) do
        if on then setWater(v) else restoreWater(v) end
    end

    if on and not connections.water then
        connections.water = workspace.DescendantAdded:Connect(function(v)
            if state.water and v:IsA("BasePart") and v.Material == Enum.Material.Water then
                setWater(v)
            end
        end)
    elseif not on and connections.water then
        connections.water:Disconnect()
        connections.water = nil
    end
end

-- ===================== UI =====================
local sg = Instance.new("ScreenGui")
sg.Name = "AntiLag"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999
sg.IgnoreGuiInset = true
sg.Parent = gui

-- Tombol buka
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 56, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0.5, -15)
openBtn.BackgroundColor3 = DARK2
openBtn.TextColor3 = WHITE
openBtn.Text = "[AL]"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.BorderSizePixel = 0
openBtn.ZIndex = 999
openBtn.Parent = sg
local openBtnCorner = Instance.new("UICorner")
openBtnCorner.CornerRadius = UDim.new(0, 8)
openBtnCorner.Parent = openBtn

-- Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 400)
frame.Position = UDim2.new(0, 80, 0.5, -200)
frame.BackgroundColor3 = DARK1
frame.BorderSizePixel = 0
frame.ZIndex = 10
frame.Parent = sg
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame
-- HAPUS baris "local shadow = Instance.new("Shadow")" karena tidak valid
-- Sebagai ganti, tambahkan outline tipis pakai UIStroke (opsional)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80,80,80)
stroke.Thickness = 1
stroke.Parent = frame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = HEADER
header.BorderSizePixel = 0
header.ZIndex = 11
header.Parent = frame
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ Anti Lag"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = WHITE
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 12
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0.5, -12)
closeBtn.BackgroundColor3 = RED
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = WHITE
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 13
closeBtn.Parent = header
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Konten (scrollable)
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, 0, 1, -36)
content.Position = UDim2.new(0, 0, 0, 36)
content.BackgroundTransparency = 1
content.ZIndex = 11
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = content

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 6)
pad.PaddingLeft = UDim.new(0, 6)
pad.PaddingRight = UDim.new(0, 6)
pad.Parent = content

-- Fungsi membuat baris toggle
local function addRow(label, key, fn)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = DARK3
    row.BorderSizePixel = 0
    row.ZIndex = 12
    row.Parent = content
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = TXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 54, 0, 24)
    btn.Position = UDim2.new(1, -60, 0.5, -12)
    btn.BackgroundColor3 = DARK4
    btn.Text = "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = GRAY
    btn.BorderSizePixel = 0
    btn.ZIndex = 13
    btn.Parent = row
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        if state[key] then
            btn.Text = "ON"
            btn.BackgroundColor3 = GREEN
            btn.TextColor3 = WHITE
        else
            btn.Text = "OFF"
            btn.BackgroundColor3 = DARK4
            btn.TextColor3 = GRAY
        end
        fn(state[key])
    end)
end

-- Daftar fitur
addRow("Plastic Texture", "plastic", applyPlastic)
addRow("No Shadow", "shadow", applyShadow)
addRow("No Fog", "fog", applyFog)
addRow("No Decals", "decals", applyDecals)
addRow("No Particles", "particles", applyParticles)
addRow("Low Graphics", "graphics", applyGraphics)
addRow("No Atmosphere", "atmosphere", function(on) applyEffect(on, "Atmosphere") end)
addRow("No SunRays", "sunrays", function(on) applyEffect(on, "SunRays") end)
addRow("No Bloom", "bloom", function(on) applyEffect(on, "Bloom") end)
addRow("No ColorCorrection", "colorcorrection", function(on) applyEffect(on, "ColorCorrection") end)
addRow("No Water", "water", applyWater)

-- ===================== DRAG / Toggle =====================
local function makeDraggable(handle, target)
    local drag, start, sPos = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            start = i.Position
            sPos = target.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            target.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
        end
    end)
end

makeDraggable(header, frame)

-- Drag + toggle openBtn
local obDrag, obStart, obSPos, obDelta = false, nil, nil, Vector2.new(0,0)
openBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        obDrag = true
        obStart = i.Position
        obSPos = openBtn.Position
        obDelta = Vector2.new(0,0)
    end
end)
openBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        obDrag = false
        if obDelta.Magnitude < 6 then
            local uiOpen = not frame.Visible
            frame.Visible = uiOpen
        end
    end
end)
UIS.InputChanged:Connect(function(i)
    if obDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - obStart
        obDelta = Vector2.new(d.X, d.Y)
        openBtn.Position = UDim2.new(obSPos.X.Scale, obSPos.X.Offset + d.X, obSPos.Y.Scale, obSPos.Y.Offset + d.Y)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

print("[AntiLag] v2 Loaded!")