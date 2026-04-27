-- [[ 🛠️ UI CONFIGURATION ]]
local UI_Settings = {
    ButtonSize = UDim2.new(0, 55, 0, 55),
    ContainerAnchor = Vector2.new(1, 1),
    ContainerPos = UDim2.new(1, -15, 1, -15),
    ContainerSize = UDim2.new(0, 170, 0, 170),
    RunPos = UDim2.new(0.65, 0, 0, 0),
    SJumpPos = UDim2.new(0.15, 0, 0.15, 0),
    DashPos = UDim2.new(0, 0, 0.65, 0)
}

-- [[ CENTRAL SYSTEM - CONFIGURATION v6.2 (Balanced Edition) ]]
local Settings = {
    Creator = "EllenGroqAI",
    Version = "6.2",
    
    WalkSpeed = 16,
    SprintSpeed = 26, 
    DashVelocity = 55, -- บัฟความแรงนิดนึงเพราะเวลน้อยลง
    DashDuration = 0.8,
    JumpHeight = 55,
    JumpForwardPower = 160,
    
    SprintDrain = 12.0,
    NormalJumpCost = 20.0,
    
    StartDashCD = 12, -- ปรับคูลดาวน์เริ่มต้นให้ไวขึ้น
    StartJumpCD = 20,
    
    MaxStatLevel = 60,  -- 📌 ปรับเหลือ 60 ตามสั่ง!
    MaxSkillLevel = 15,
    
    UltDuration = 90, -- ปรับเวลาอัลติให้กระชับขึ้น
    UltCooldown = 300,
    
    PointGainInterval = 45, -- ให้แต้มไวขึ้นหน่อย (จาก 60 เป็น 45)
    PointsPerInterval = 5,
    
    SacrificeStaminaReq = 1200, -- ลด Stamina ที่ต้องใช้สังเวยลงให้เหมาะกับเวล 60
    SacrificePointsGain = 50
}

local DASH_SOUND = "rbxassetid://2428506580"
local JUMP_SOUND = "rbxassetid://12222200"
local ULT_SOUND = "rbxassetid://156747284"
local SACRIFICE_SOUND = "rbxassetid://156747284"

local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local character, humanoid, hrp, loadedAnim
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://46196309"

local function playActionSound(id)
    pcall(function()
        if not hrp then return end
        local s = Instance.new("Sound")
        s.SoundId = id; s.Volume = 2; s.Parent = hrp; s:Play()
        game:GetService("Debris"):AddItem(s, 2)
    end)
end

local function setupCharacter(char)
    if not char then return end
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    loadedAnim = humanoid:LoadAnimation(animation)
    loadedAnim.Looped = true
end

if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)

-- Dynamic States (Start with 10 points so you can test the buttons!)
local capLevel, regenLevel, dashSkillLevel, jumpSkillLevel = 1, 1, 1, 1
local upgradePoints = 10 -- 📌 แถมให้ 10 แต้มเอาไว้กดเทสต์ปุ่มตอนเริ่ม!
local maxStamina, currentStamina = 500, 500
local sacrificeActive, isSprinting = false, false
local dashOnCooldown, jumpOnCooldown = false, false
local dashTimeLeft, jumpTimeLeft = 0, 0
local ultActive, ultOnCooldown = false, false
local ultCooldownLeft, ultDurationLeft = 0, 0

-- [[ 🐾 LOAD VERIDIAN HUB ]]
local Success, VeridianLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/modcreate1641-collab/Veridian/refs/heads/main/Furryhub.lua"))()
end)
if not Success or not VeridianLib then return warn("Veridian Hub Failed to Load!") end

local Window = VeridianLib:CreateWindow("CENTRAL v6.2 [60 CAP]")

-- Helper Functions
local function createUIBtn(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 45); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.Text = text; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createUILabel(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(0.95, 0, 0, 35); lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Color3.new(0.8, 0.8, 0.8); lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 14
    return lbl
end

local DynamicUI = {}

-- [[ TAB 1: UPGRADE CENTER ]]
Window:CreateTab("🔼 Upgrade", function(p)
    local layout = p:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    DynamicUI.TopPoint = createUILabel(p, "Upgrade Points: " .. upgradePoints)
    
    -- แก้ Logic การกดให้เช็ก Level 60
    DynamicUI.BtnCap = createUIBtn(p, "Upgrade Capacity", function() 
        if upgradePoints > 0 and capLevel < Settings.MaxStatLevel then 
            upgradePoints -= 1; capLevel += 1; maxStamina = 500 + ((capLevel - 1) * 75) -- ปรับสูตรเพิ่มสตามิน่าให้เยอะขึ้นในเวลน้อยๆ
        end 
    end)
    
    DynamicUI.BtnRegen = createUIBtn(p, "Upgrade Regen", function() 
        if upgradePoints > 0 and regenLevel < Settings.MaxStatLevel then 
            upgradePoints -= 1; regenLevel += 1 
        end 
    end)
    
    DynamicUI.BtnDash = createUIBtn(p, "Dash Mastery", function() 
        if upgradePoints > 0 and dashSkillLevel < Settings.MaxSkillLevel then 
            upgradePoints -= 1; dashSkillLevel += 1 
        end 
    end)
    
    DynamicUI.BtnJump = createUIBtn(p, "S-Jump Mastery", function() 
        if upgradePoints > 0 and jumpSkillLevel < Settings.MaxSkillLevel then 
            upgradePoints -= 1; jumpSkillLevel += 1 
        end 
    end)
end)

-- [[ TAB 2: GOD STATUS ]]
Window:CreateTab("📊 Status", function(p)
    local layout = p:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    DynamicUI.Stam = createUILabel(p, "Stamina: 500 / 500")
    DynamicUI.Dash = createUILabel(p, "Dash Level: 1/15")
    DynamicUI.Jump = createUILabel(p, "S-Jump Level: 1/15")
    DynamicUI.Ult = createUILabel(p, "Ultimate: Locked")
end)

-- [[ TAB 3: SANCTUARY ]]
Window:CreateTab("🔥 Sanctuary", function(p)
    local layout = p:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    createUIBtn(p, "PERFORM SACRIFICE (+"..Settings.SacrificePointsGain.." Pts)", function() 
        if currentStamina >= Settings.SacrificeStaminaReq and not sacrificeActive then 
            currentStamina -= Settings.SacrificeStaminaReq; upgradePoints += Settings.SacrificePointsGain; sacrificeActive = true; playActionSound(SACRIFICE_SOUND)
            task.delay(5, function() sacrificeActive = false end) 
        end 
    end)

    createUIBtn(p, "ACTIVATE ULTIMATE", function()
        -- 📌 ปรับเงื่อนไขปลด Ultimate ให้สอดคล้องกับเลเวล 60
        local isUnlocked = (dashSkillLevel >= 15 and jumpSkillLevel >= 15 and regenLevel >= 60 and capLevel >= 60)
        if isUnlocked and not ultOnCooldown and not ultActive then
            ultActive = true; ultDurationLeft = Settings.UltDuration; playActionSound(ULT_SOUND)
            task.spawn(function()
                while ultDurationLeft > 0 do ultDurationLeft -= 1; task.wait(1) end
                ultActive = false; ultOnCooldown = true; ultCooldownLeft = Settings.UltCooldown
                while ultCooldownLeft > 0 do ultCooldownLeft -= 1; task.wait(1) end
                ultOnCooldown = false
            end)
        end
    end)
end)

-- [[ SCREEN UI ]]
local screenGui = Instance.new("ScreenGui", player.PlayerGui); screenGui.Name = "CentralVisuals"; screenGui.ResetOnSpawn = false
local staminaback = Instance.new("Frame", screenGui); staminaback.Size = UDim2.new(0, 250, 0, 15); staminaback.Position = UDim2.new(0.5, -125, 0.9, 0); staminaback.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", staminaback).CornerRadius = UDim.new(1, 0)
local staminaFill = Instance.new("Frame", staminaback); staminaFill.Size = UDim2.new(1, 0, 1, 0); staminaFill.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
Instance.new("UICorner", staminaFill).CornerRadius = UDim.new(1, 0)

local actionContainer = Instance.new("Frame", screenGui)
actionContainer.AnchorPoint = UI_Settings.ContainerAnchor; actionContainer.Position = UI_Settings.ContainerPos
actionContainer.Size = UI_Settings.ContainerSize; actionContainer.BackgroundTransparency = 1

local function createCircleBtn(parent, name, pos, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UI_Settings.ButtonSize; btn.Position = pos; btn.Text = name; btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    return btn
end

local sprintBtn = createCircleBtn(actionContainer, "RUN", UI_Settings.RunPos, Color3.fromRGB(0, 120, 210))
local jumpBtn = createCircleBtn(actionContainer, "S-JUMP", UI_Settings.SJumpPos, Color3.fromRGB(40,40,45))
local dashBtn = createCircleBtn(actionContainer, "DASH", UI_Settings.DashPos, Color3.fromRGB(20,20,20))

-- [[ MOVEMENT LOGIC ]]
local function executeDash()
    if not ultActive and dashOnCooldown then return end
    local cost = 60 - ((dashSkillLevel - 1) * 2)
    if currentStamina >= cost then
        currentStamina -= cost; playActionSound(DASH_SOUND)
        if loadedAnim then loadedAnim:Play() end
        local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(1e6, 1e6, 1e6) 
        local dashStartTime = tick()
        local steerConnection
        steerConnection = runService.RenderStepped:Connect(function()
            local elapsed = tick() - dashStartTime
            if elapsed >= Settings.DashDuration or not bv.Parent then
                steerConnection:Disconnect(); if loadedAnim then loadedAnim:Stop() end
                return
            end
            bv.Velocity = hrp.CFrame.LookVector * Settings.DashVelocity
        end)
        task.wait(Settings.DashDuration); if bv then bv:Destroy() end
        if not ultActive then
            dashOnCooldown = true; dashTimeLeft = Settings.StartDashCD - ((dashSkillLevel - 1) * 0.5)
            task.spawn(function()
                while dashTimeLeft > 0 do dashTimeLeft -= 0.1; dashBtn.Text = string.format("%.1f", dashTimeLeft); task.wait(0.1) end
                dashBtn.Text = "DASH"; dashOnCooldown = false
            end)
        end
    end
end

local function executeSuperJump()
    if not ultActive and jumpOnCooldown then return end
    local cost = 100 - ((jumpSkillLevel - 1) * 3)
    if currentStamina >= cost then
        currentStamina -= cost; playActionSound(JUMP_SOUND)
        hrp.AssemblyLinearVelocity = Vector3.new(0, Settings.JumpHeight, 0) + (hrp.CFrame.LookVector * Settings.JumpForwardPower)
        if not ultActive then
            jumpOnCooldown = true; jumpTimeLeft = Settings.StartJumpCD - ((jumpSkillLevel - 1) * 0.8)
            task.spawn(function()
                while jumpTimeLeft > 0 do jumpTimeLeft -= 0.1; jumpBtn.Text = string.format("%.1f", jumpTimeLeft); task.wait(0.1) end
                jumpBtn.Text = "S-JUMP"; jumpOnCooldown = false
            end)
        end
    end
end

-- [[ TICK LOOP ]]
runService.Heartbeat:Connect(function(dt)
    if not humanoid then return end
    if isSprinting and humanoid.MoveDirection.Magnitude > 0 and currentStamina > 0 then
        humanoid.WalkSpeed = Settings.SprintSpeed
        currentStamina = math.max(0, currentStamina - (Settings.SprintDrain * dt))
    else
        humanoid.WalkSpeed = Settings.WalkSpeed
        if currentStamina < maxStamina and not sacrificeActive then
            local regenAmt = 8 + ((regenLevel - 1) * 3) -- ปรับอัตรา Regen ให้แรงขึ้นเพราะเวลตันน้อย
            currentStamina = math.min(maxStamina, currentStamina + (regenAmt * dt))
        end
    end
    
    staminaFill.Size = UDim2.new(math.clamp(currentStamina/maxStamina, 0, 1), 0, 1, 0)
    
    -- 📌 อัปเดต UI (แก้เรื่องกดไม่ได้ โดยการเช็กค่าจากปุ่มโดยตรง)
    if DynamicUI.TopPoint then
        DynamicUI.TopPoint.Text = "Upgrade Points: " .. math.floor(upgradePoints)
        DynamicUI.BtnCap.Text = string.format("Upgrade Capacity (Lv.%d/60)", capLevel)
        DynamicUI.BtnRegen.Text = string.format("Upgrade Regen (Lv.%d/60)", regenLevel)
        DynamicUI.BtnDash.Text = string.format("Dash Mastery (Lv.%d/15)", dashSkillLevel)
        DynamicUI.BtnJump.Text = string.format("S-Jump Mastery (Lv.%d/15)", jumpSkillLevel)
        
        DynamicUI.Stam.Text = string.format("Stamina: %d / %d", currentStamina, maxStamina)
        DynamicUI.Dash.Text = "Dash Skill: Lv." .. dashSkillLevel
        DynamicUI.Jump.Text = "S-Jump Skill: Lv." .. jumpSkillLevel
        
        local isUnlocked = (dashSkillLevel >= 15 and jumpSkillLevel >= 15 and regenLevel >= 60 and capLevel >= 60)
        if ultActive then DynamicUI.Ult.Text = "ULT ACTIVE: " .. math.ceil(ultDurationLeft) .. "s"
        elseif ultOnCooldown then DynamicUI.Ult.Text = "ULT CD: " .. math.ceil(ultCooldownLeft) .. "s"
        elseif isUnlocked then DynamicUI.Ult.Text = "Ultimate: READY"
        else DynamicUI.Ult.Text = "Ultimate: LOCKED (Need Max Stats)" end
    end
end)

dashBtn.MouseButton1Click:Connect(executeDash); jumpBtn.MouseButton1Click:Connect(executeSuperJump)
sprintBtn.MouseButton1Down:Connect(function() isSprinting = true; sprintBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255) end)
sprintBtn.MouseButton1Up:Connect(function() isSprinting = false; sprintBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 210) end)
task.spawn(function() while true do task.wait(Settings.PointGainInterval); upgradePoints += Settings.PointsPerInterval end end)
