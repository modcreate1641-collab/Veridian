-- [[ 🛠️ UI CONFIGURATION ]]
local UI_Settings = {
    ButtonSize = UDim2.new(0, 55, 0, 55), -- Uniform button size
    
    -- Responsive Anchor System
    ContainerAnchor = Vector2.new(1, 1),      -- Bottom-right anchor
    ContainerPos = UDim2.new(1, -15, 1, -15), -- Offset from screen edge
    ContainerSize = UDim2.new(0, 170, 0, 170),-- Container area size
    
    -- Action Button Positions (Arc layout)
    RunPos = UDim2.new(0.65, 0, 0, 0),     -- Top position
    SJumpPos = UDim2.new(0.15, 0, 0.15, 0),-- Top-left diagonal
    DashPos = UDim2.new(0, 0, 0.65, 0)     -- Left position
}

-- [[ CENTRAL SYSTEM - CONFIGURATION v6.1 (Veridian Edition) ]]
local Settings = {
    Creator = "EllenGroqAI",
    Version = "6.1",
    
    WalkSpeed = 16,
    SprintSpeed = 26, 
    DashVelocity = 50,
    DashDuration = 0.8,
    JumpHeight = 50,
    JumpForwardPower = 150,
    
    SprintDrain = 10.0,
    NormalJumpCost = 25.0,
    
    StartDashCD = 15,
    StartJumpCD = 25,
    
    MaxStatLevel = 200,
    MaxSkillLevel = 15,
    
    UltDuration = 120,
    UltCooldown = 400,
    
    PointGainInterval = 60,
    PointsPerInterval = 10,
    
    SacrificeStaminaReq = 1500,
    SacrificePointsGain = 100
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
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    loadedAnim = humanoid:LoadAnimation(animation)
    loadedAnim.Looped = true
end

if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)

-- Dynamic States
local capLevel, regenLevel, dashSkillLevel, jumpSkillLevel = 1, 1, 1, 1
local upgradePoints = 0
local maxStamina, currentStamina = 500, 500
local sacrificeActive, isSprinting = false, false
local dashOnCooldown, jumpOnCooldown = false, false
local dashTimeLeft, jumpTimeLeft = 0, 0
local ultActive, ultOnCooldown = false, false
local ultCooldownLeft, ultDurationLeft = 0, 0

-- [[ 🐾 โหลด VERIDIAN HUB LIBRARY ]]
local Success, VeridianLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/modcreate1641-collab/Veridian/refs/heads/main/Furryhub.lua"))()
end)
if not Success or not VeridianLib then return warn("Veridian Hub Failed to Load!") end

local Window = VeridianLib:CreateWindow("CENTRAL SYSTEM v6.1")

-- สร้างฟังก์ชันช่วยสร้างปุ่ม/ข้อความ
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

local Logs = {}

-- [[ TAB 1: UPGRADE CENTER ]]
Window:CreateTab("🔼 Upgrade", function(p)
    local layout = p:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    createUIBtn(p, "Upgrade Capacity (Max 200)", function() 
        if upgradePoints > 0 and capLevel < 200 then upgradePoints -= 1; capLevel += 1; maxStamina = 500 + ((capLevel - 1) * 50) end 
    end)
    createUIBtn(p, "Upgrade Regen (Max 200)", function() 
        if upgradePoints > 0 and regenLevel < 200 then upgradePoints -= 1; regenLevel += 1 end 
    end)
    createUIBtn(p, "Dash Mastery (Max 15)", function() 
        if upgradePoints > 0 and dashSkillLevel < 15 then upgradePoints -= 1; dashSkillLevel += 1 end 
    end)
    createUIBtn(p, "S-Jump Mastery (Max 15)", function() 
        if upgradePoints > 0 and jumpSkillLevel < 15 then upgradePoints -= 1; jumpSkillLevel += 1 end 
    end)
end)

-- [[ TAB 2: GOD STATUS ]]
Window:CreateTab("📊 Status", function(p)
    local layout = p:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    Logs.Point = createUILabel(p, "Upgrade Points: 0")
    Logs.Stam = createUILabel(p, "Stamina: 500 / 500")
    Logs.Cap = createUILabel(p, "Capacity Level: 1/200")
    Logs.Regen = createUILabel(p, "Regen Level: 1/200")
    Logs.Dash = createUILabel(p, "Dash Level: 1/15")
    Logs.Jump = createUILabel(p, "S-Jump Level: 1/15")
end)

-- [[ TAB 3: SANCTUARY ]]
Window:CreateTab("🔥 Sanctuary", function(p)
    local layout = p:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    createUIBtn(p, "PERFORM SACRIFICE (+100 Pts)", function() 
        if currentStamina >= Settings.SacrificeStaminaReq and not sacrificeActive then 
            currentStamina -= Settings.SacrificeStaminaReq; upgradePoints += Settings.SacrificePointsGain; sacrificeActive = true; playActionSound(SACRIFICE_SOUND)
            task.delay(10, function() sacrificeActive = false end) 
        end 
    end)

    Logs.Ult = createUILabel(p, "Ultimate: Locked")
    
    createUIBtn(p, "ACTIVATE ULTIMATE (NO CD)", function()
        local isUnlocked = (dashSkillLevel >= 15 and jumpSkillLevel >= 15 and regenLevel >= 50 and capLevel >= 72)
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

-- [[ SCREEN UI (ดึงค่าจากตัวแปรด้านบนสุด) ]]
local screenGui = Instance.new("ScreenGui", player.PlayerGui); screenGui.Name = "CentralVisuals"; screenGui.ResetOnSpawn = false

-- หลอดสตามิน่า (อยู่กลางล่าง)
local staminaback = Instance.new("Frame", screenGui); staminaback.Size = UDim2.new(0, 250, 0, 15); staminaback.Position = UDim2.new(0.5, -125, 0.9, 0); staminaback.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", staminaback).CornerRadius = UDim.new(1, 0)
local staminaFill = Instance.new("Frame", staminaback); staminaFill.Size = UDim2.new(1, 0, 1, 0); staminaFill.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
Instance.new("UICorner", staminaFill).CornerRadius = UDim.new(1, 0)

-- คอนเทนเนอร์ปุ่มแอคชั่น (เกาะมุมขวาล่างอัตโนมัติ)
local actionContainer = Instance.new("Frame", screenGui)
actionContainer.AnchorPoint = UI_Settings.ContainerAnchor
actionContainer.Position = UI_Settings.ContainerPos
actionContainer.Size = UI_Settings.ContainerSize
actionContainer.BackgroundTransparency = 1

local function createCircleBtn(parent, name, pos, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UI_Settings.ButtonSize -- ใช้ขนาดเท่ากันหมดจากที่ตั้งค่าไว้
    btn.Position = pos; btn.Text = name; btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    return btn
end

-- สร้างปุ่มตามตำแหน่งในวงโค้ง
local sprintBtn = createCircleBtn(actionContainer, "RUN", UI_Settings.RunPos, Color3.fromRGB(0, 120, 210))
local jumpBtn = createCircleBtn(actionContainer, "S-JUMP", UI_Settings.SJumpPos, Color3.fromRGB(40,40,45))
local dashBtn = createCircleBtn(actionContainer, "DASH", UI_Settings.DashPos, Color3.fromRGB(20,20,20))

-- [[ MOVEMENT LOGIC ]]
local function executeDash()
    if not ultActive and dashOnCooldown then return end
    local cost = 70 - ((dashSkillLevel - 1) * 2)
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
            local faceDir = hrp.CFrame.LookVector * Vector3.new(1, 0, 1)
            bv.Velocity = faceDir.Unit * Settings.DashVelocity
        end)
        task.wait(Settings.DashDuration); if bv then bv:Destroy() end
        if not ultActive then
            dashOnCooldown = true; dashTimeLeft = Settings.StartDashCD - ((dashSkillLevel - 1) * 0.8)
            task.spawn(function()
                while dashTimeLeft > 0 do dashTimeLeft -= 0.1; dashBtn.Text = string.format("%.1f", dashTimeLeft); task.wait(0.1) end
                dashBtn.Text = "DASH"; dashOnCooldown = false
            end)
        end
    end
end

local function executeSuperJump()
    if not ultActive and jumpOnCooldown then return end
    local cost = 120 - ((jumpSkillLevel - 1) * 3)
    if currentStamina >= cost then
        currentStamina -= cost; playActionSound(JUMP_SOUND)
        hrp.AssemblyLinearVelocity = Vector3.new(0, Settings.JumpHeight, 0) + (hrp.CFrame.LookVector * Settings.JumpForwardPower)
        if not ultActive then
            jumpOnCooldown = true; jumpTimeLeft = Settings.StartJumpCD - ((jumpSkillLevel - 1) * 1.2)
            task.spawn(function()
                while jumpTimeLeft > 0 do jumpTimeLeft -= 0.1; jumpBtn.Text = string.format("%.1f", jumpTimeLeft); task.wait(0.1) end
                jumpBtn.Text = "S-JUMP"; jumpOnCooldown = false
            end)
        end
    end
end

uis.JumpRequest:Connect(function()
    if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
        if currentStamina >= Settings.NormalJumpCost then
            currentStamina -= Settings.NormalJumpCost
        else
            humanoid.Jump = false
        end
    end
end)

-- [[ TICK LOOP (อัปเดต UI และสตามิน่า) ]]
runService.Heartbeat:Connect(function(dt)
    if not humanoid then return end
    if isSprinting and humanoid.MoveDirection.Magnitude > 0 and currentStamina > 0 then
        humanoid.WalkSpeed = Settings.SprintSpeed
        currentStamina = math.max(0, currentStamina - (Settings.SprintDrain * dt))
    else
        humanoid.WalkSpeed = Settings.WalkSpeed
        if currentStamina < maxStamina and not sacrificeActive then
            local regenAmt = 5 + ((regenLevel - 1) * 2)
            currentStamina = math.min(maxStamina, currentStamina + (regenAmt * dt))
        end
    end
    
    staminaFill.Size = UDim2.new(math.clamp(currentStamina/maxStamina, 0, 1), 0, 1, 0)
    
    if Logs.Point then
        Logs.Point.Text = "Upgrade Points: " .. math.floor(upgradePoints)
        Logs.Stam.Text = string.format("Stamina: %d / %d", currentStamina, maxStamina)
        Logs.Cap.Text = "Capacity Level: " .. capLevel .. "/200"
        Logs.Regen.Text = "Regen Level: " .. regenLevel .. "/200"
        Logs.Dash.Text = "Dash Level: " .. dashSkillLevel .. "/15"
        Logs.Jump.Text = "S-Jump Level: " .. jumpSkillLevel .. "/15"
        
        local isUnlocked = (dashSkillLevel >= 15 and jumpSkillLevel >= 15 and regenLevel >= 50 and capLevel >= 72)
        if ultActive then Logs.Ult.Text = "ULT ACTIVE: " .. math.ceil(ultDurationLeft) .. "s"
        elseif ultOnCooldown then Logs.Ult.Text = "ULT CD: " .. math.ceil(ultCooldownLeft) .. "s"
        elseif isUnlocked then Logs.Ult.Text = "Ultimate: READY"
        else Logs.Ult.Text = "Ultimate: LOCKED (Need max skills)" end
    end
end)

dashBtn.MouseButton1Click:Connect(executeDash); jumpBtn.MouseButton1Click:Connect(executeSuperJump)
sprintBtn.MouseButton1Down:Connect(function() isSprinting = true; sprintBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255) end)
sprintBtn.MouseButton1Up:Connect(function() isSprinting = false; sprintBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 210) end)
task.spawn(function() while true do task.wait(Settings.PointGainInterval); upgradePoints += Settings.PointsPerInterval end end)
