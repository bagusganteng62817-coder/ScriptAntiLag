-- ================================================
--      ANTI LAG SCRIPT ULTIMATE (FINAL FIX)
--      LocalScript - Masukkan ke StarterPlayerScripts
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ================================================
-- STATE & DATA STORAGE
-- ================================================
local settings = {
    plasticTexture  = false,
    noShadow        = false,
    noFog           = false,
    lowGraphics     = false,
    noDecals        = false,
    noParticles     = false,
    noPostFX        = false,
    noAccessories   = false,
}

local originalMaterials = {}
local originalCastShadow = {}
local originalDecals = {}
local originalPostFX = {}
local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd

local isUIOpen = false
local uiRows = {}

-- ================================================
-- COLOR THEME
-- ================================================
local Theme = {
    Accent = Color3.fromRGB(110, 80, 255),
    AccentLight = Color3.fromRGB(150, 120, 255),
    Background = Color3.fromRGB(15, 15, 25),
    RowBg = Color3.fromRGB(25, 25, 40),
    RowHover = Color3.fromRGB(35, 35, 55),
    TextMain = Color3.fromRGB(230, 230, 255),
    TextSub = Color3.fromRGB(130, 130, 180),
    ToggleOff = Color3.fromRGB(45, 45, 65),
    KnobOff = Color3.fromRGB(150, 150, 170),
}

-- ================================================
-- GUI SETUP
-- ================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiLagUI_V2"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ── TOGGLE BUTTON ──────────────
local toggleBtn = Instance.new("Frame")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
toggleBtn.BackgroundColor3 = Theme.Background
toggleBtn.BorderSizePixel = 0
toggleBtn.ZIndex = 10
toggleBtn.Parent = screenGui

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0.5, 0)
tbCorner.Parent = toggleBtn

local tbStroke = Instance.new("UIStroke")
tbStroke.Color = Theme.Accent
tbStroke.Thickness = 2
tbStroke.Parent = toggleBtn

local tbIcon = Instance.new("TextLabel")
tbIcon.Size = UDim2.new(1, 0, 1, 0)
tbIcon.BackgroundTransparency = 1
tbIcon.Text = "⚡"
tbIcon.TextScaled = true
tbIcon.Font = Enum.Font.GothamBold
tbIcon.TextColor3 = Theme.AccentLight
tbIcon.ZIndex = 11
tbIcon.Parent = toggleBtn

-- Animasi Pulse
task.spawn(function()
    while true do
        local t1 = TweenService:Create(tbStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.6})
        local t2 = TweenService:Create(tbIcon, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0.5})
        t1:Play(); t2:Play()
        t1.Completed:Wait()
        
        local t3 = TweenService:Create(tbStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0})
        local t4 = TweenService:Create(tbIcon, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0})
        t3:Play(); t4:Play()
        t3.Completed:Wait()
    end
end)

-- ── MAIN PANEL ───────────────────────────────────
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(0, 300, 0, 0)
mainPanel.Position = UDim2.new(0, 85, 0.5, 0)
mainPanel.BackgroundColor3 = Theme.Background
mainPanel.BorderSizePixel = 0
mainPanel.ClipsDescendants = true
mainPanel.Visible = false
mainPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 16)
panelCorner.Parent = mainPanel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(40, 40, 70)
panelStroke.Thickness = 1.5
panelStroke.Parent = mainPanel

-- ── HEADER ───────────────────────────────────────
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = mainPanel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0.5, 0)
headerFix.Position = UDim2.new(0, 0, 0.5, 0)
headerFix.BackgroundColor3 = header.BackgroundColor3
headerFix.BorderSizePixel = 0
headerFix.ZIndex = 2
headerFix.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 0, 30)
titleLabel.Position = UDim2.new(0, 18, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ANTI LAG"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 18
titleLabel.TextColor3 = Theme.AccentLight
titleLabel.ZIndex = 3
titleLabel.Parent = header

local subLabel = Instance.new("TextLabel")
subLabel.Size = UDim2.new(1, -50, 0, 16)
subLabel.Position = UDim2.new(0, 18, 0, 35)
subLabel.BackgroundTransparency = 1
subLabel.Text = "Performance Optimizer V2"
subLabel.TextXAlignment = Enum.TextXAlignment.Left
subLabel.Font = Enum.Font.Gotham
subLabel.TextSize = 11
subLabel.TextColor3 = Theme.TextSub
subLabel.ZIndex = 3
subLabel.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -45, 0, 15)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.white
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.ZIndex = 4
closeBtn.AutoButtonColor = true
closeBtn.Parent = header

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0.5, 0)
closeBtnCorner.Parent = closeBtn

-- ── SCROLL / CONTENT AREA ────────────────────────
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -75)
content.Position = UDim2.new(0, 10, 0, 65)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Theme.Accent
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.BorderSizePixel = 0
content.Parent = mainPanel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = content

-- ================================================
-- TOGGLE ROW FACTORY (FIXED STAGGER)
-- ================================================
local function createToggleRow(icon, label, desc, key, order)
    local row = Instance.new("Frame")
    row.Name = key
    row.Size = UDim2.new(1, 0, 0, 55)
    row.BackgroundColor3 = Theme.RowBg
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = content
    row.ClipsDescendants = true

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 10)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(40, 40, 65)
    rowStroke.Thickness = 1
    rowStroke.Parent = row

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.ZIndex = 5
    hitbox.Parent = row

    hitbox.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.2), {BackgroundColor3 = Theme.RowHover}):Play()
    end)
    hitbox.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.2), {BackgroundColor3 = Theme.RowBg}):Play()
    end)

    local iconBox = Instance.new("Frame")
    iconBox.Size = UDim2.new(0, 35, 0, 35)
    iconBox.Position = UDim2.new(0, 10, 0.5, -17.5)
    iconBox.BackgroundColor3 = Theme.Background
    iconBox.BorderSizePixel = 0
    iconBox.Parent = row

    local iconBoxCorner = Instance.new("UICorner")
    iconBoxCorner.CornerRadius = UDim.new(0, 8)
    iconBoxCorner.Parent = iconBox

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextScaled = true
    iconLabel.Font = Enum.Font.Gotham
    iconLabel.TextColor3 = Theme.AccentLight
    iconLabel.Parent = iconBox

    local mainTxt = Instance.new("TextLabel")
    mainTxt.Size = UDim2.new(1, -110, 0, 20)
    mainTxt.Position = UDim2.new(0, 55, 0, 10)
    mainTxt.BackgroundTransparency = 1
    mainTxt.Text = label
    mainTxt.TextXAlignment = Enum.TextXAlignment.Left
    mainTxt.Font = Enum.Font.GothamBold
    mainTxt.TextSize = 13
    mainTxt.TextColor3 = Theme.TextMain
    mainTxt.Parent = row

    local subTxt = Instance.new("TextLabel")
    subTxt.Size = UDim2.new(1, -110, 0, 14)
    subTxt.Position = UDim2.new(0, 55, 0, 30)
    subTxt.BackgroundTransparency = 1
    subTxt.Text = desc
    subTxt.TextXAlignment = Enum.TextXAlignment.Left
    subTxt.Font = Enum.Font.Gotham
    subTxt.TextSize = 10
    subTxt.TextColor3 = Theme.TextSub
    subTxt.Parent = row

    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 42, 0, 22)
    switchBg.Position = UDim2.new(1, -55, 0.5, -11)
    switchBg.BackgroundColor3 = Theme.ToggleOff
    switchBg.BorderSizePixel = 0
    switchBg.Parent = row

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Theme.KnobOff
    knob.BorderSizePixel = 0
    knob.Parent = switchBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local function updateVisual(on)
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        if on then
            TweenService:Create(switchBg, tweenInfo, {BackgroundColor3 = Theme.Accent}):Play()
            TweenService:Create(knob, tweenInfo, {Position = UDim2.new(0, 23, 0.5, -8), BackgroundColor3 = Color3.new(1,1,1)}):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.2), {Color = Theme.Accent}):Play()
        else
            TweenService:Create(switchBg, tweenInfo, {BackgroundColor3 = Theme.ToggleOff}):Play()
            TweenService:Create(knob, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Theme.KnobOff}):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 65)}):Play()
        end
    end

    hitbox.MouseButton1Click:Connect(function()
        settings[key] = not settings[key]
        updateVisual(settings[key])
        
        -- Dibungkus task.spawn agar UI tidak freeze saat memindai workspace
        task.spawn(function()
            if key == "plasticTexture" then applyPlastic(settings[key]) end
            if key == "noShadow" then applyShadow(settings[key]) end
            if key == "noFog" then applyFog(settings[key]) end
            if key == "lowGraphics" then applyGraphics(settings[key]) end
            if key == "noDecals" then applyDecals(settings[key]) end
            if key == "noParticles" then applyParticles(settings[key]) end
            if key == "noPostFX" then applyPostFX(settings[key]) end
            if key == "noAccessories" then applyAccessories(settings[key]) end
        end)
    end)

    table.insert(uiRows, row)
end

-- ================================================
-- ANTI LAG FUNCTIONS
-- ================================================

function applyPlastic(on)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if on then
                if not originalMaterials[obj] then originalMaterials[obj] = obj.Material end
                obj.Material = Enum.Material.SmoothPlastic
            else
                if originalMaterials[obj] then obj.Material = originalMaterials[obj]; originalMaterials[obj] = nil end
            end
        end
    end
end

function applyShadow(on)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if on then
                if originalCastShadow[obj] == nil then originalCastShadow[obj] = obj.CastShadow end
                obj.CastShadow = false
            else
                if originalCastShadow[obj] ~= nil then obj.CastShadow = originalCastShadow[obj]; originalCastShadow[obj] = nil end
            end
        end
    end
    Lighting.GlobalShadows = not on
end

function applyFog(on)
    if on then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 1000000
    else
        Lighting.FogEnd = originalFogEnd
        Lighting.FogStart = originalFogStart
    end
end

function applyGraphics(on)
    if on then
        game:GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    else
        game:GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.Automatic
    end
end

function applyDecals(on)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if on then
                originalDecals[obj] = obj.Transparency
                obj.Transparency = 1
            else
                if originalDecals[obj] then obj.Transparency = originalDecals[obj]; originalDecals[obj] = nil end
            end
        end
    end
end

function applyParticles(on)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = not on
        end
    end
end

function applyPostFX(on)
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") then
            if on then
                if originalPostFX[obj] == nil then originalPostFX[obj] = obj.Enabled end
                obj.Enabled = false
            else
                if originalPostFX[obj] ~= nil then obj.Enabled = originalPostFX[obj]; originalPostFX[obj] = nil end
            end
        end
    end
end

function applyAccessories(on)
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        if char then
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("Accessory") then
                    local handle = v:FindFirstChild("Handle")
                    if handle and handle:IsA("BasePart") then
                        if on then
                            handle.LocalTransparencyModifier = 1
                            for _, m in ipairs(handle:GetChildren()) do
                                if m:IsA("Decal") or m:IsA("Texture") or m:IsA("SurfaceGui") then
                                    m.Enabled = false
                                end
                            end
                        else
                            handle.LocalTransparencyModifier = 0
                            for _, m in ipairs(handle:GetChildren()) do
                                if m:IsA("Decal") or m:IsA("Texture") or m:IsA("SurfaceGui") then
                                    m.Enabled = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ================================================
-- BUILD TOGGLE ROWS
-- ================================================
createToggleRow("🎨", "Plastic Texture", "Semua part jadi SmoothPlastic", "plasticTexture", 1)
createToggleRow("🌑", "No Shadow", "Matikan bayangan & GlobalShadows", "noShadow", 2)
createToggleRow("🌫", "No Fog", "Hapus efek kabut di jarak jauh", "noFog", 3)
createToggleRow("📉", "Low Graphics", "Paksa grafik ke level 1", "lowGraphics", 4)
createToggleRow("🖼", "No Decals", "Sembunyikan tekstur dinding/lantai", "noDecals", 5)
createToggleRow("✨", "No Particles", "Matikan partikel & efek api", "noParticles", 6)
createToggleRow("🎞", "No Post-FX", "Matikan Bloom, Blur, SunRays", "noPostFX", 7)
createToggleRow("🧢", "No Accessories", "Hilangkan topi & rambut player", "noAccessories", 8)

-- ================================================
-- DRAG FUNCTION
-- ================================================
local function makeDraggable(dragHandle, frame)
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(header, mainPanel)

-- ================================================
-- OPEN / CLOSE UI & STAGGER ANIMATION (FIXED)
-- ================================================
local function setUIOpen(open)
    isUIOpen = open
    if open then
        mainPanel.Visible = true
        TweenService:Create(mainPanel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
            {Size = UDim2.new(0, 300, 0, 480)}):Play()
        
        -- Stagger Animation menggunakan AnchorPoint agar tidak bentrok dengan UIListLayout
        for i, row in ipairs(uiRows) do
            row.AnchorPoint = Vector2.new(-1.5, 0) -- Mulai dari luar layar kiri
            row.BackgroundTransparency = 1
            
            task.delay(i * 0.06, function()
                TweenService:Create(row, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
                    {AnchorPoint = Vector2.new(0, 0), BackgroundTransparency = 0}):Play()
            end)
        end
        tbIcon.Text = "✕"
    else
        TweenService:Create(mainPanel, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), 
            {Size = UDim2.new(0, 300, 0, 0)}):Play()
        task.delay(0.25, function() mainPanel.Visible = false end)
        tbIcon.Text = "⚡"
    end
end

closeBtn.MouseButton1Click:Connect(function() setUIOpen(false) end)

local tbDragging = false
local tbDragDelta = Vector2.new(0, 0)
local tbDragStart, tbStartPos

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tbDragging = true
        tbDragStart = input.Position
        tbStartPos = toggleBtn.Position
        tbDragDelta = Vector2.new(0, 0)
    end
end)

toggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tbDragging = false
        if tbDragDelta.Magnitude < 6 then
            setUIOpen(not isUIOpen)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if tbDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - tbDragStart
        tbDragDelta = Vector2.new(delta.X, delta.Y)
        toggleBtn.Position = UDim2.new(tbStartPos.X.Scale, tbStartPos.X.Offset + delta.X, tbStartPos.Y.Scale, tbStartPos.Y.Offset + delta.Y)
    end
end)

print("[AntiLag V2 Final] Script loaded successfully!")