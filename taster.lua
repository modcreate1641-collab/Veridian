local Veridianhub = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local CONFIG = {
    NavBtnColor = Color3.fromRGB(90, 132, 255),
    HoverColor = Color3.fromRGB(110, 152, 255),
    ClickColor = Color3.fromRGB(70, 112, 235),
    MainBgColor = Color3.fromRGB(45, 45, 50),
    NavPanelColor = Color3.fromRGB(45, 45, 50),
    SearchBgColor = Color3.fromRGB(76, 181, 191),
    DefaultFontSize = 12,
    KeybindEnabled = true,
    ToggleKey = Enum.KeyCode.K,
    BgFolder = "VeridianConfig"
}

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and CONFIG.KeybindEnabled then
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CONFIG.ToggleKey then
            ToggleWindow(not isWindowOpen)
        end
    end
end)

local baseFolder = CONFIG.BgFolder
local targetFolder = baseFolder .. "/BgAsset"
local iconFolder = baseFolder .. "/Icons"

-- [[ 1. ระบบเช็คและสร้างโฟลเดอร์ ]] --
if not isfolder(baseFolder) then makefolder(baseFolder) end
if not isfolder(targetFolder) then makefolder(targetFolder) end
if not isfolder(iconFolder) then makefolder(iconFolder) end

-- [[ 2. ประกาศตัวแปรพาร์ทไฟล์และ URL (แยกขาดจากกัน) ]] --

-- ฝั่ง Veridian (พื้นหลัง + โลโก้หลัก)
local bgName = targetFolder .. "/Cool background.png"
local bgUrl = "https://raw.githubusercontent.com/modcreate1641-collab/Veridian/refs/heads/main/Cool%20background.png"

local logoName = targetFolder .. "/furryLogo.png"
local logoUrl = "https://raw.githubusercontent.com/modcreate1641-collab/Veridian/refs/heads/main/Texture7.jpg"

-- ฝั่ง Fluffy (ไอคอน Signature ของมึง)
local settingName = iconFolder .. "/setting icon.png"
local settingUrl = "https://raw.githubusercontent.com/modcreate1641-collab/Fluffy/refs/heads/main/setting%20icon.png"

local scripthubName = iconFolder .. "/scripthub icon.jpeg"
local scripthubUrl = "https://raw.githubusercontent.com/modcreate1641-collab/Fluffy/refs/heads/main/scripthub%20icon.jpeg"

local scriptName = iconFolder .. "/script icon.png"
local scriptUrl = "https://raw.githubusercontent.com/modcreate1641-collab/Fluffy/refs/heads/main/script%20icon.png"

local furryName = iconFolder .. "/furry icon.png"
local furryUrl = "https://raw.githubusercontent.com/modcreate1641-collab/Fluffy/refs/heads/main/furry%20icon.png"

local aimName = iconFolder .. "/aim icon.png"
local aimUrl = "https://raw.githubusercontent.com/modcreate1641-collab/Fluffy/refs/heads/main/aim%20icon.png"

local destroyName = iconFolder .. "/destroy icon.png"
local destroyUrl = "https://raw.githubusercontent.com/modcreate1641-collab/Fluffy/refs/heads/main/d416ad99167d8cd588a83d0d377fca0028a269fd6b8310b5b31aa6acd6a1d04b.0.png"

local autoName = iconFolder .. "/auto.png"
local autoUrl = "https://raw.githubusercontent.com/modcreate1641-collab/Fluffy/refs/heads/main/auto.png"


-- [[ 3. ระบบดาวน์โหลดแบบทีละตัว (เน้นชัวร์ ไม่เน้นสั้น) ]] --

-- โหลด Background (ขนาดใหญ่ > 5000)
if not isfile(bgName) then
    local s, content = pcall(game.HttpGet, game, bgUrl)
    if s and #content > 5000 then writefile(bgName, content) end
end

-- โหลด Logo (ขนาดใหญ่ > 5000)
if not isfile(logoName) then
    local s, content = pcall(game.HttpGet, game, logoUrl)
    if s and #content > 5000 then writefile(logoName, content) end
end

-- โหลด Setting Icon (ไอคอนขนาดเล็ก > 0)
if not isfile(settingName) then
    local s, content = pcall(game.HttpGet, game, settingUrl)
    if s and #content > 0 then writefile(settingName, content) end
end

-- โหลด ScriptHub Icon (ไอคอนขนาดเล็ก > 0)
if not isfile(scripthubName) then
    local s, content = pcall(game.HttpGet, game, scripthubUrl)
    if s and #content > 0 then writefile(scripthubName, content) end
end

-- โหลด Script Icon (ไอคอนขนาดเล็ก > 0)
if not isfile(scriptName) then
    local s, content = pcall(game.HttpGet, game, scriptUrl)
    if s and #content > 0 then writefile(scriptName, content) end
end

-- โหลด Furry Icon (ไอคอนขนาดเล็ก > 0)
if not isfile(furryName) then
    local s, content = pcall(game.HttpGet, game, furryUrl)
    if s and #content > 0 then writefile(furryName, content) end
end

-- โหลด Aim Icon (ไอคอนขนาดเล็ก > 0)
if not isfile(aimName) then
    local s, content = pcall(game.HttpGet, game, aimUrl)
    if s and #content > 0 then writefile(aimName, content) end
end

-- โหลด Destroy Icon (ไอคอนขนาดเล็ก > 0)
if not isfile(destroyName) then
    local s, content = pcall(game.HttpGet, game, destroyUrl)
    if s and #content > 0 then writefile(destroyName, content) end
end

-- โหลด Auto Icon (ไอคอนขนาดเล็ก > 0)
if not isfile(autoName) then
    local s, content = pcall(game.HttpGet, game, autoUrl)
    if s and #content > 0 then writefile(autoName, content) end
end

local function CreateTween(instance, properties, time, style, direction)
    local info = TweenService:Create(instance, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), properties)
    info:Play()
    return info
end

function Veridianhub:CreateWindow(Config)
    -- [[ CONFIGURATION PARSING WITH FALLBACK PROTECTION ]] --
    local HubText = typeof(Config) == "table" and Config.Name or Config or "Veridian Hub"
    local HubTextSize = typeof(Config) == "table" and Config.TextSize or 14
    local HubFont = typeof(Config) == "table" and Config.Font or Enum.Font.GothamBold
    local HubColor = typeof(Config) == "table" and Config.TextColor or Color3.fromRGB(245, 245, 245)

    -- [[ ENVIRONMENT EXECUTOR GUI TARGET CHECK ]] --
    local Success, TargetGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    
    if not Success or not TargetGui then
        TargetGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    -- [[ MAIN GUI CONTAINER LAYER ]] --
    local ScreenGui = Instance.new("ScreenGui", TargetGui)
    ScreenGui.Name = "VeridianHub_Official_Full"
    ScreenGui.IgnoreGuiInset = true

    local MainFrame = Instance.new("CanvasGroup", ScreenGui)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 508, 0, 264)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = CONFIG.MainBgColor
MainFrame.ClipsDescendants = true
MainFrame.GroupTransparency = 0.3
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local BgImage = Instance.new("ImageLabel", MainFrame)
BgImage.Size = UDim2.new(1, 0, 1, 0)
BgImage.BackgroundTransparency = 1
BgImage.ZIndex = 0
BgImage.ScaleType = Enum.ScaleType.Crop
local BgCorner = Instance.new("UICorner", BgImage)
BgCorner.CornerRadius = UDim.new(0, 10)

local DarkOverlay = Instance.new("Frame", MainFrame)
DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
DarkOverlay.BackgroundColor3 = Color3.new(0,0,0)
DarkOverlay.BackgroundTransparency = 0.7
DarkOverlay.ZIndex = 1
DarkOverlay.Visible = false
Instance.new("UICorner", DarkOverlay).CornerRadius = UDim.new(0, 10)

local function ApplyAutoBackground(bgFileName)
    local getAsset = getcustomasset or getsynasset
    if not getAsset then return end

    pcall(function()
        local mainFolder = CONFIG.BgFolder
        local subFolder = mainFolder .. "/BgAsset"
        
        if isfolder and isfolder(subFolder) then
            local target = bgFileName
            
            if not target and isfile then
                local validExts = {".png", ".jpg", ".jpeg", ".webp", ".bmp", ".tga"}
                for _, f in pairs(listfiles(subFolder)) do
                    local ext = f:lower()
                    for _, valid in ipairs(validExts) do
                        if ext:sub(-#valid) == valid then
                            target = f:sub(#subFolder + 2)
                            break
                        end
                    end
                    if target then break end
                end
            end

            if target then
                local fullPath = subFolder .. "/" .. target
                if isfile and isfile(fullPath) then
                    BgImage.Image = getAsset(fullPath)
                    DarkOverlay.Visible = true
                    MainFrame.BackgroundTransparency = 1
                end
            end
        end
    end)
end

ApplyAutoBackground()

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.ZIndex = 5

local TS = game:GetService("TweenService")
local info = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

local rainbowConnection
local function startRainbow()
    if rainbowConnection then 
        rainbowConnection:Disconnect() 
    end
    
    rainbowConnection = RunService.RenderStepped:Connect(function()
        pcall(function()
            if UIStroke and UIStroke.Parent then
                local hue = (tick() * 0.05) % 1
                UIStroke.Color = Color3.fromHSV(hue, 1, 1)
            else
                if rainbowConnection then 
                    rainbowConnection:Disconnect() 
                    rainbowConnection = nil
                end
            end
        end)
    end)
end
task.spawn(startRainbow)

local function makeDraggable(gui, targetFrame)
    local dragging, dragInput, dragStart, startPos
    
    local function startDrag(input)
        ---[[ INTERCEPT DRAG IF GLOBAL LOCK IS ENABLED ]]---
        if _G.MainFrameLocked then return end
        
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not UserInputService:GetFocusedTextBox() then
            dragging = true
            dragStart = input.Position
            dragInput = input
            startPos = targetFrame and targetFrame.Position or gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end
    
    gui.InputBegan:Connect(startDrag)
    
    ---[[ PREVENT BUTTON SINKING AND PREVENT JUMPING TO ROBLOX TOP BAR ]]---
    for _, child in pairs(gui:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("ImageButton") then
            child.InputBegan:Connect(startDrag)
        end
    end
    
    gui.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            ---[[ BREAK DRAG IMMEDIATELY IF LOCK TOGGLED MIDWAY ]]---
            if _G.MainFrameLocked then 
                dragging = false 
                return 
            end
            
            local delta = input.Position - dragStart
            local target = targetFrame or gui
            CreateTween(target, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05, Enum.EasingStyle.Linear)
        end
    end)
end

local isWindowOpen = true
local currentSize = UDim2.new(0, 508, 0, 264)

local function ToggleWindow(state)
    isWindowOpen = state
    if state then
        MainFrame.Visible = true
        CreateTween(MainFrame, {Size = currentSize, GroupTransparency = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        currentSize = MainFrame.Size
        local shrinkW = math.max(200, currentSize.X.Offset - 58)
        local shrinkH = math.max(100, currentSize.Y.Offset - 64)
        local t = CreateTween(MainFrame, {Size = UDim2.new(0, shrinkW, 0, shrinkH), GroupTransparency = 1}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        t.Completed:Connect(function() if not isWindowOpen then MainFrame.Visible = false end end)
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and CONFIG.KeybindEnabled and input.KeyCode == CONFIG.ToggleKey then 
        ToggleWindow(not isWindowOpen) 
    end
end)

local ResizeBtn = Instance.new("TextButton", MainFrame)
ResizeBtn.Size = UDim2.new(0, 32, 0, 32)
ResizeBtn.Position = UDim2.new(1, -32, 1, -32)
ResizeBtn.BackgroundTransparency = 1
ResizeBtn.Text = "◢"
ResizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ResizeBtn.TextSize = 14
ResizeBtn.Font = Enum.Font.GothamBold
ResizeBtn.TextXAlignment = Enum.TextXAlignment.Right
ResizeBtn.TextYAlignment = Enum.TextYAlignment.Bottom
ResizeBtn.ZIndex = 99
ResizeBtn.Active = true

local isResizing = false
local resStartPos = nil
local resStartSize = nil
local dragConnection = nil

ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = true
        resStartPos = input.Position
        resStartSize = MainFrame.Size
        
        if dragConnection then 
            dragConnection:Disconnect() 
        end
        
        dragConnection = UserInputService.InputChanged:Connect(function(changedInput)
            if isResizing and (changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch) then
                local delta = changedInput.Position - resStartPos
                local newWidth = math.max(400, resStartSize.X.Offset + delta.X)
                local newHeight = math.max(250, resStartSize.Y.Offset + delta.Y)
                MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
                currentSize = MainFrame.Size
            end
        end)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = false
        if dragConnection then
            dragConnection:Disconnect()
            dragConnection = nil
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = false
    end
end)

-- Modern Sleek Toggle Button Setup (Pure On/Off Toggle)
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- =================== UI ELEMENTS CREATE ===================
local ToggleContainer = Instance.new("Frame", ScreenGui)
ToggleContainer.Size = UDim2.new(0, 140, 0, 36)
ToggleContainer.Position = UDim2.new(0, 335, 0, 25)
ToggleContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleContainer.BackgroundTransparency = 0.1
ToggleContainer.Active = true
ToggleContainer.ZIndex = 999

local ContainerCorner = Instance.new("UICorner", ToggleContainer)
ContainerCorner.CornerRadius = UDim.new(0, 10)

local ContainerStroke = Instance.new("UIStroke", ToggleContainer)
ContainerStroke.Thickness = 1.5
ContainerStroke.Color = CONFIG.NavBtnColor
ContainerStroke.Transparency = 0.4

local ToggleBtn = Instance.new("TextButton", ToggleContainer)
ToggleBtn.Name = "ToggleButton"
ToggleBtn.Size = UDim2.new(0, 95, 1, 0)
ToggleBtn.Position = UDim2.new(0, 0, 0, 0)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Text = "" -- ลบอีโมจิอุ้งเท้าออก เซตเป็นค่าว่างซะ
ToggleBtn.Active = true
ToggleBtn.ZIndex = 1000

-- ยัดไอคอนขนฟู (Furry Icon) ไว้ฝั่งซ้ายของปุ่ม
local ToggleIcon = Instance.new("ImageLabel", ToggleBtn)
ToggleIcon.Name = "ToggleIcon"
ToggleIcon.Size = UDim2.new(0, 18, 0, 18) -- ขนาด 18x18 กำลังน่ารักไม่แย่งซีนข้อความ
ToggleIcon.Position = UDim2.new(0, 10, 0.5, -9) -- ชิดซ้ายเว้นจากขอบเข้ามา 10 พิกเซล
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.Image = getcustomasset(CONFIG.BgFolder .. "/Icons/furry icon.png") -- ดึงไฟล์ไอคอนเฟี้ยวๆ มาแปะ
ToggleIcon.ZIndex = 1001

-- สร้าง TextLabel แยกต่างหากเพื่อจัดระเบียบตัวหนังสือ "On/Off"
local ToggleText = Instance.new("TextLabel", ToggleBtn)
ToggleText.Name = "ToggleText"
-- ขนาดให้กินพื้นที่ที่เหลือ โดยลบระยะของไอคอนออกไป
ToggleText.Size = UDim2.new(1, -35, 1, 0) 
ToggleText.Position = UDim2.new(0, 34, 0, 0) -- ขยับมาทางขวาเพื่อหลบให้ไอคอน
ToggleText.BackgroundTransparency = 1
ToggleText.Text = "On/Off"
ToggleText.TextColor3 = Color3.fromRGB(245, 245, 245)
ToggleText.Font = Enum.Font.GothamBold
ToggleText.TextSize = 12
ToggleText.TextXAlignment = Enum.TextXAlignment.Left -- จัดข้อความชิดซ้ายเรียงต่อจากไอคอนแบบเนียนๆ
ToggleText.ZIndex = 1001

-- เส้นคั่น (Divider) ของเดิมมึง เอามาวางหล่อๆ เหมือนเดิม
local Divider = Instance.new("Frame", ToggleContainer)
Divider.Size = UDim2.new(0, 1, 0, 20)
Divider.Position = UDim2.new(0, 96, 0.5, -10)
Divider.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
Divider.BackgroundTransparency = 0.7
Divider.ZIndex = 1000

local LockBtn = Instance.new("TextButton", ToggleContainer)
LockBtn.Size = UDim2.new(0, 43, 1, 0)
LockBtn.Position = UDim2.new(0, 97, 0, 0)
LockBtn.BackgroundTransparency = 1
LockBtn.Text = "🔓"
LockBtn.TextColor3 = Color3.fromRGB(100, 240, 100)
LockBtn.Font = Enum.Font.GothamBold
LockBtn.TextSize = 14
LockBtn.ZIndex = 1000

-- =================== GLOBAL LOCK STATE ===================
_G.MainFrameLocked = false

-- =================== CLEAN DRAG ENGINE (NO CONFLICTS) ===================
local function makeToggleDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    
    local function startDrag(input)
        ---[[ INTERCEPT DRAG IF GLOBAL LOCK IS ACTIVE ]]---
        if _G.MainFrameLocked then return end
        
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            dragInput = input
            startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end
    
    gui.InputBegan:Connect(startDrag)
    
    ---[[ PREVENT CHILD ELEMENTS FROM SINKING DRAG INPUT ]]---
    for _, child in pairs(gui:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("ImageButton") then
            child.InputBegan:Connect(startDrag)
        end
    end
    
    gui.InputChanged:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
            dragInput = input 
        end 
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            if _G.MainFrameLocked then dragging = false return end
            
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeToggleDraggable(ToggleContainer)

-- =================== BUTTONS LOGIC ===================
-- =================== BUTTONS LOGIC ===================
ToggleBtn.MouseButton1Down:Connect(function()
	TweenService:Create(ToggleContainer, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 135, 0, 32)}):Play()
end)

ToggleBtn.MouseButton1Up:Connect(function()
	TweenService:Create(ToggleContainer, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 140, 0, 36)}):Play()
end)

ToggleBtn.Activated:Connect(function()
	if typeof(ToggleWindow) == "function" then
		ToggleWindow(not isWindowOpen)
	elseif MainFrame then
		MainFrame.Visible = not MainFrame.Visible
	end
end)

LockBtn.Activated:Connect(function()
	_G.MainFrameLocked = not _G.MainFrameLocked
	
	if _G.MainFrameLocked then
		LockBtn.Text = "🔒"
		LockBtn.TextColor3 = Color3.fromRGB(240, 70, 70)
		TweenService:Create(ContainerStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Color = Color3.fromRGB(240, 70, 70), Transparency = 0.1}):Play()
	else
		LockBtn.Text = "🔓"
		LockBtn.TextColor3 = Color3.fromRGB(100, 240, 100)
		TweenService:Create(ContainerStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Color = CONFIG.NavBtnColor, Transparency = 0.4}):Play()
	end
end)

-- [[ SYSTEM HOVER ACTIONS WITH TWEEN SERVICE ]] --
ToggleBtn.MouseEnter:Connect(function() 
    TweenService:Create(ToggleContainer, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
    TweenService:Create(ContainerStroke, TweenInfo.new(0.2), {Transparency = 0, Thickness = 2}):Play()
end)

ToggleBtn.MouseLeave:Connect(function() 
    TweenService:Create(ToggleContainer, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 25)}):Play()
    TweenService:Create(ContainerStroke, TweenInfo.new(0.2), {Color = CONFIG.NavBtnColor, Transparency = 0.4, Thickness = 1.5}):Play()
end)

-- FIXED: Deleted the broken repetitive ToggleStroke hover loops that caused the Null Instance Error.

local destroyStage = 0
-- [[ ======================================================= ]] --
-- [[ MODERN FULL-WIDTH TOP NAVIGATION BAR ]] --
-- [[ ======================================================= ]] --
local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Name = "ModernTopNavigationBar"
    TopBar.Size = UDim2.new(1, -12, 0, 42)
    TopBar.Position = UDim2.new(0, 6, 0, 6)
    TopBar.BackgroundColor3 = CONFIG.NavPanelColor
    TopBar.BackgroundTransparency = 0.5
    TopBar.ZIndex = 10
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

    local defaultLogoFolder = (CONFIG and CONFIG.BgFolder and CONFIG.BgFolder .. "/Icons") or "VeridianConfig/Icons"
    local targetLogoFolder = (typeof(Config) == "table" and Config.foldertarget) or defaultLogoFolder

    if typeof(Config) == "table" and Config.createfolder and type(Config.createfolder) == "string" and Config.createfolder ~= "" then
        targetLogoFolder = targetLogoFolder .. "/" .. Config.createfolder
    end

    local targetFileName = (typeof(Config) == "table" and Config.createfile) or "logo.png"
    local finalLogoPath = targetLogoFolder .. "/" .. targetFileName

    local HubLogo = Instance.new("ImageLabel", TopBar)
    HubLogo.Name = "HubLogo"
    HubLogo.Size = UDim2.new(0, 32, 0, 32)
    HubLogo.Position = UDim2.new(0, 10, 0.5, -16)
    HubLogo.BackgroundTransparency = 1
    HubLogo.ZIndex = 11
    HubLogo.ScaleType = Enum.ScaleType.Crop
    HubLogo.Image = "" -- ปล่อยว่างไว้ก่อนเดี๋ยวโหลดใส่ให้

    Instance.new("UICorner", HubLogo).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", HubLogo).Color = Color3.fromRGB(60, 60, 70)

    -- ใช้ task.spawn เพื่อไม่ให้ UI ค้างตอนดึงรูปหรือสร้างโฟลเดอร์
    task.spawn(function()
        -- 1. ระบบสร้างโฟลเดอร์อัตโนมัติ (รองรับโครงสร้างซ้อนกันหลายชั้น)
        local currentPath = ""
        for folder in string.gmatch(targetLogoFolder, "[^/]+") do
            currentPath = currentPath == "" and folder or currentPath .. "/" .. folder
            pcall(function()
                if not isfolder(currentPath) then
                    makefolder(currentPath)
                end
            end)
        end

        -- 2. ดาวน์โหลดรูปภาพถ้ามีการตั้งค่า Logo เป็น URL และไฟล์ยังไม่มีในเครื่อง
        if typeof(Config) == "table" and Config.Logo and string.find(Config.Logo, "http") then
            if not isfile(finalLogoPath) then
                local success, imgData = pcall(game.HttpGet, game, Config.Logo)
                if success and imgData and #imgData > 0 and not string.find(imgData, "<!DOCTYPE") then
                    pcall(writefile, finalLogoPath, imgData)
                end
            end
        end

        -- 3. ระบบโหลดรูปเข้า HubLogo
        local getAsset = getcustomasset or getsynasset
        local computedImage = ""

        if isfile(finalLogoPath) then
            if getAsset then
                pcall(function() computedImage = getAsset(finalLogoPath) end)
            end
        else
            -- ระบบ Fallback กรณีโหลดพลาด
            local fallbackIcon = CONFIG and CONFIG.BgFolder and (CONFIG.BgFolder .. "/Icons/furry icon.png")
            if fallbackIcon and isfile(fallbackIcon) then
                if getAsset then
                    pcall(function() computedImage = getAsset(fallbackIcon) end)
                end
            end
        end

        if computedImage ~= "" then
            HubLogo.Image = computedImage
        end
    end)

    local TitleContainer = Instance.new("Frame", TopBar)  
    TitleContainer.Name = "TitleContainer"  
    TitleContainer.Size = UDim2.new(0, 200, 1, 0)  
    TitleContainer.Position = UDim2.new(0, 52, 0, 0)  
    TitleContainer.BackgroundTransparency = 1  
    TitleContainer.ZIndex = 11  

    local HubLabel = Instance.new("TextLabel", TitleContainer)  
    HubLabel.Name = "HubTitleLabel"  
    HubLabel.Size = UDim2.new(1, 0, 0, 22)  
    HubLabel.Position = UDim2.new(0, 0, 0, 4)  
    HubLabel.BackgroundTransparency = 1  
    HubLabel.Text = HubText  
    HubLabel.TextColor3 = HubColor  
    HubLabel.Font = HubFont  
    HubLabel.TextSize = HubTextSize  
    HubLabel.TextXAlignment = Enum.TextXAlignment.Left  
    HubLabel.ZIndex = 12  

    local rawDiscord = (typeof(Config) == "table" and (Config.discord or Config.Discord)) or "discord.gg/veridian"
    
    local ActiveDiscordLink = rawDiscord
    if not string.find(ActiveDiscordLink, "http") then
        ActiveDiscordLink = "https://" .. ActiveDiscordLink
    end

    local DisplayText = string.gsub(rawDiscord, "https://", "")
    DisplayText = string.gsub(DisplayText, "http://", "")

    local DiscordBtn = Instance.new("TextButton", TitleContainer)  
    DiscordBtn.Name = "DiscordCopyButton"  
    DiscordBtn.Size = UDim2.new(1, 0, 0, 14)  
    DiscordBtn.Position = UDim2.new(0, 0, 0, 24)  
    DiscordBtn.BackgroundTransparency = 1  
    
    DiscordBtn.Text = "🔗 " .. DisplayText  
    DiscordBtn.TextColor3 = Color3.fromRGB(150, 150, 170)  
    DiscordBtn.Font = Enum.Font.GothamSemibold  
    DiscordBtn.TextSize = 10  
    DiscordBtn.TextXAlignment = Enum.TextXAlignment.Left  
    DiscordBtn.ZIndex = 12  

    DiscordBtn.MouseEnter:Connect(function()  
        if DiscordBtn.Text:find("Copied") then return end  
        CreateTween(DiscordBtn, {TextColor3 = Color3.fromRGB(100, 170, 255)}, 0.2)  
    end)  

    DiscordBtn.MouseLeave:Connect(function()  
        if DiscordBtn.Text:find("Copied") then return end  
        CreateTween(DiscordBtn, {TextColor3 = Color3.fromRGB(150, 150, 170)}, 0.2)  
    end)  

    DiscordBtn.Activated:Connect(function()  
        pcall(function()  
            if setclipboard and ActiveDiscordLink and ActiveDiscordLink ~= "" then  
                
                setclipboard(ActiveDiscordLink)  
                
                DiscordBtn.Text = "✅ Copied!"  
                CreateTween(DiscordBtn, {TextColor3 = Color3.fromRGB(50, 200, 50)}, 0.1)  
                  
                task.delay(1.5, function()  

                    DiscordBtn.Text = "🔗 " .. DisplayText  
                    CreateTween(DiscordBtn, {TextColor3 = Color3.fromRGB(150, 150, 170)}, 0.2)  
                end)  
            end  
        end)  
    end)

    task.defer(function()
        if WindowAPI and WindowAPI.UpdateHubInfo then
            WindowAPI:UpdateHubInfo(Config)
        end
    end)

-- [[ DESTROY BUTTON & POPUP SYSTEM ]]
local ClosedBtn = Instance.new("TextButton", TopBar)
ClosedBtn.Name = "HubDestroyButton"
ClosedBtn.Size = UDim2.new(0, 80, 1, 0)
ClosedBtn.Position = UDim2.new(1, -80, 0, 0)
ClosedBtn.BackgroundColor3 = Color3.fromRGB(129, 129, 129)
ClosedBtn.BackgroundTransparency = 0.9
ClosedBtn.Text = ""
ClosedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClosedBtn.Font = Enum.Font.GothamBold
ClosedBtn.TextSize = 12
ClosedBtn.Active = true
ClosedBtn.ZIndex = 12 
Instance.new("UICorner", ClosedBtn)

local BtnIcon = Instance.new("ImageLabel", ClosedBtn)
BtnIcon.Name = "DestroyIcon"
BtnIcon.Size = UDim2.new(0, 20, 0, 20)
BtnIcon.Position = UDim2.new(0.5, -10, 0.5, -10)
BtnIcon.BackgroundTransparency = 1
BtnIcon.Image = getcustomasset(CONFIG.BgFolder .. "/Icons/destroy icon.png")
BtnIcon.ZIndex = 13

-- [[ POPUP UI SETUP ]]
local DestroyOverlay = Instance.new("Frame", MainFrame)
DestroyOverlay.Name = "DestroyOverlay"
DestroyOverlay.Size = UDim2.new(1, 0, 1, 0)
DestroyOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 5)
DestroyOverlay.BackgroundTransparency = 1
DestroyOverlay.Visible = false
DestroyOverlay.ZIndex = 900
Instance.new("UICorner", DestroyOverlay).CornerRadius = UDim.new(0, 10)

local ConfirmBox = Instance.new("Frame", DestroyOverlay)
ConfirmBox.Name = "ConfirmBox"
ConfirmBox.AnchorPoint = Vector2.new(0.5, 0.5)
ConfirmBox.Size = UDim2.new(0, 0, 0, 0)
ConfirmBox.Position = UDim2.new(0.5, 0, 0.5, 0)
ConfirmBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ConfirmBox.ClipsDescendants = true
ConfirmBox.ZIndex = 901
Instance.new("UICorner", ConfirmBox).CornerRadius = UDim.new(0, 8)

local ConfirmStroke = Instance.new("UIStroke", ConfirmBox)
ConfirmStroke.Color = Color3.fromRGB(200, 50, 50)
ConfirmStroke.Thickness = 1.5
ConfirmStroke.Transparency = 1

local WarningTitle = Instance.new("TextLabel", ConfirmBox)
WarningTitle.Size = UDim2.new(1, 0, 0, 30)
WarningTitle.Position = UDim2.new(0, 0, 0, 15)
WarningTitle.BackgroundTransparency = 1
WarningTitle.Text = "WARNING"
WarningTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
WarningTitle.Font = Enum.Font.GothamBlack
WarningTitle.TextSize = 18
WarningTitle.ZIndex = 902

local WarningDesc = Instance.new("TextLabel", ConfirmBox)
WarningDesc.Size = UDim2.new(1, -20, 0, 40)
WarningDesc.Position = UDim2.new(0, 10, 0, 45)
WarningDesc.BackgroundTransparency = 1
WarningDesc.Text = "Are you sure you want to close this hub?"
WarningDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
WarningDesc.Font = Enum.Font.GothamSemibold
WarningDesc.TextSize = 13
WarningDesc.TextWrapped = true
WarningDesc.ZIndex = 902

local ActionBtn = Instance.new("TextButton", ConfirmBox)
ActionBtn.Size = UDim2.new(0, 110, 0, 32)
ActionBtn.Position = UDim2.new(0.5, 10, 1, -45)
ActionBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
ActionBtn.Text = "YES (1/2)"
ActionBtn.TextColor3 = Color3.new(1, 1, 1)
ActionBtn.Font = Enum.Font.GothamBold
ActionBtn.TextSize = 13
ActionBtn.ZIndex = 902
Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 6)

local CancelBtn = Instance.new("TextButton", ConfirmBox)
CancelBtn.Size = UDim2.new(0, 110, 0, 32)
CancelBtn.Position = UDim2.new(0.5, -120, 1, -45)
CancelBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
CancelBtn.Text = "CANCEL"
CancelBtn.TextColor3 = Color3.new(1, 1, 1)
CancelBtn.Font = Enum.Font.GothamBold
CancelBtn.TextSize = 13
CancelBtn.ZIndex = 902
Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 6)

-- [[ LOGIC ]]
local destroyStage = 0
local timeoutTask = nil

local function resetDestroySequence()
    destroyStage = 0
    if timeoutTask then 
        task.cancel(timeoutTask) 
        timeoutTask = nil 
    end
    
    CreateTween(ConfirmBox, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    CreateTween(DestroyOverlay, {BackgroundTransparency = 1}, 0.3)
    CreateTween(ConfirmStroke, {Transparency = 1}, 0.2)
    
    task.delay(0.3, function()
        DestroyOverlay.Visible = false
        WarningTitle.Text = "WARNING"
        WarningTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
        WarningDesc.Text = "Are you sure you want to close this hub?"
        ActionBtn.Text = "YES (1/2)"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end)
end

ClosedBtn.MouseEnter:Connect(function() CreateTween(ClosedBtn, {BackgroundColor3 = Color3.fromRGB(180, 50, 50)}, 0.2) end)
ClosedBtn.MouseLeave:Connect(function() CreateTween(ClosedBtn, {BackgroundColor3 = Color3.fromRGB(129, 129, 129)}, 0.2) end)

ClosedBtn.Activated:Connect(function()
    if destroyStage == 0 then
        destroyStage = 1
        DestroyOverlay.Visible = true
        CreateTween(DestroyOverlay, {BackgroundTransparency = 0.5}, 0.3)
        CreateTween(ConfirmBox, {Size = UDim2.new(0, 270, 0, 140)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        CreateTween(ConfirmStroke, {Transparency = 0}, 0.4)
        
        timeoutTask = task.delay(4, function()
            if destroyStage > 0 then resetDestroySequence() end
        end)
    end
end)

ActionBtn.Activated:Connect(function()
    if destroyStage == 1 then
        destroyStage = 2
        if timeoutTask then task.cancel(timeoutTask) end
        
        WarningTitle.Text = "LAST WARNING!"
        WarningTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
        WarningDesc.Text = "This action cannot be undone. DESTROY HUB?"
        ActionBtn.Text = "DESTROY"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
        
        CreateTween(ConfirmBox, {Rotation = 4}, 0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out).Completed:Connect(function()
            CreateTween(ConfirmBox, {Rotation = -4}, 0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut).Completed:Connect(function()
                CreateTween(ConfirmBox, {Rotation = 0}, 0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
            end)
        end)
        
        timeoutTask = task.delay(3, function()
            if destroyStage > 0 then resetDestroySequence() end
        end)
        
    elseif destroyStage == 2 then
        if ScreenGui then ScreenGui:Destroy() end
    end
end)

CancelBtn.Activated:Connect(resetDestroySequence)

local TopSettingBtn = Instance.new("TextButton", TopBar)
TopSettingBtn.Name = "TopSettingsNavigationButton"
TopSettingBtn.Size = UDim2.new(0, 60, 1, 0)
TopSettingBtn.Position = UDim2.new(1, -146, 0, 0)
TopSettingBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
TopSettingBtn.BackgroundTransparency = 0.9
TopSettingBtn.Text = "" -- ลบอีโมจิส้นตีนนั่นออกไป เซตเป็นค่าว่างซะ
TopSettingBtn.Active = true
TopSettingBtn.ZIndex = 12 

local SettingBtnCorner = Instance.new("UICorner", TopSettingBtn)
SettingBtnCorner.CornerRadius = UDim.new(0, 8)

-- ยัดไอคอนตั้งค่าเข้าไปข้างใน และปรับให้ใหญ่ขึ้นตามคำขอ (24x24 พิกเซล)
local SettingIcon = Instance.new("ImageLabel", TopSettingBtn)
SettingIcon.Name = "SettingIcon"
SettingIcon.Size = UDim2.new(0, 24, 0, 24) -- ขยายขนาดให้ใหญ่สะใจขึ้น
SettingIcon.Position = UDim2.new(0.5, -12, 0.5, -12) -- สูตรคำนวณจัดกึ่งกลางเป๊ะ (ขนาดหารสองแล้วติดลบ)
SettingIcon.BackgroundTransparency = 1
SettingIcon.Image = getcustomasset(CONFIG.BgFolder .. "/Icons/setting icon.png") -- ดึงไฟล์ไอคอนตั้งค่ามาใช้
SettingIcon.ZIndex = 13

-- [[ SETTINGS BUTTON HOVER INTERACTION LOOPS ]] --
TopSettingBtn.MouseEnter:Connect(function() 
    CreateTween(TopSettingBtn, {BackgroundColor3 = Color3.fromRGB(120, 120, 140)}, 0.2) 
end)

TopSettingBtn.MouseLeave:Connect(function() 
    CreateTween(TopSettingBtn, {BackgroundColor3 = Color3.fromRGB(100, 100, 120)}, 0.2) 
end)

-- [[ ======================================================= ]] --
-- [[ FURRY CONFIG AND ASSET CACHE MANAGEMENT ]] --
-- [[ ======================================================= ]] --
local CONFIG = CONFIG or {}
CONFIG.SearchBgColor = Color3.fromRGB(20, 20, 25)
CONFIG.NavPanelColor = Color3.fromRGB(30, 30, 35)

local function GetLocalAsset(fileName, url)
    local getAsset = getcustomasset or getsynasset
    if not getAsset then return url end
    
    local folderName = CONFIG.BgFolder
    local subFolder = "Icons"
    local fullPath = folderName .. "/" .. subFolder .. "/" .. fileName
    
    if isfile and not isfile(fullPath) then
        pcall(function()
            writefile(fullPath, game:HttpGet(url))
        end)
    end
    
    return getAsset(fullPath)
end

local CachedSearchIcon = GetLocalAsset("search_icon.png", "https://raw.githubusercontent.com/modcreate1641-collab/Veridian/refs/heads/main/18458939117.png")

-- [[ ======================================================= ]] --
-- [[ BASE UI ELEMENTS AND DRAG INFRASTRUCTURE ]] --
-- [[ ======================================================= ]] --
makeDraggable(MainFrame)

local NavSidePanel = Instance.new("Frame", MainFrame)
NavSidePanel.Name = "NavSidePanel" -- ใส่ชื่อไว้หน่อยเวลาเช็คใน UpdateTheme จะได้ชัวร์
NavSidePanel.Size = UDim2.new(0, 110, 1, -55)
NavSidePanel.Position = UDim2.new(0, 3, 0, 55)
NavSidePanel.BackgroundColor3 = CONFIG.NavPanelColor
NavSidePanel.BackgroundTransparency = 0 -- ค่าเริ่มต้นตอนเปิด
NavSidePanel.ZIndex = 2
Instance.new("UICorner", NavSidePanel)

local NavArea = Instance.new("ScrollingFrame", NavSidePanel)
NavArea.Size = UDim2.new(1, -4, 1, -4)
NavArea.Position = UDim2.new(0, 2, 0, 2)
NavArea.BackgroundTransparency = 1
NavArea.ZIndex = 3
NavArea.ScrollBarThickness = 0
NavArea.CanvasSize = UDim2.new(0, 0, 0, 0)
NavArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
NavArea.ClipsDescendants = true

local NavLayout = Instance.new("UIListLayout", NavArea)
NavLayout.Padding = UDim.new(0, 5)
NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    NavArea.CanvasSize = UDim2.new(0, 0, 0, NavLayout.AbsoluteContentSize.Y)
end)


local PageArea = Instance.new("Frame", MainFrame)
PageArea.Size = UDim2.new(1, -115, 1, -55)
PageArea.Position = UDim2.new(0, 110, 0, 55)
PageArea.BackgroundTransparency = 1
PageArea.ZIndex = 3

-- [[ ======================================================= ]] --
-- [[ MODERN TOGGLEABLE SEARCH ENGINE CREATION ]] --
-- [[ ======================================================= ]] --
local SearchBtn = Instance.new("ImageButton", TopBar)
SearchBtn.Name = "SearchTriggerButton"
SearchBtn.Size = UDim2.new(0, 26, 0, 26)
SearchBtn.Position = UDim2.new(1, -185, 0.5, -13)
SearchBtn.BackgroundTransparency = 1
SearchBtn.Image = CachedSearchIcon
SearchBtn.ZIndex = 15

local SearchContainer = Instance.new("Frame", MainFrame)
SearchContainer.Name = "DropdownSearchPanel"
SearchContainer.Size = UDim2.new(1, -125, 0, 36)
SearchContainer.Position = UDim2.new(0, 115, 0, 15) -- Hidden behind/inside topbar at start
SearchContainer.BackgroundColor3 = CONFIG.SearchBgColor
SearchContainer.BackgroundTransparency = 1
SearchContainer.Visible = false
SearchContainer.ZIndex = 100 -- Places search securely above all standard page tabs

local ContainerCorner = Instance.new("UICorner", SearchContainer)
ContainerCorner.CornerRadius = UDim.new(0, 8)

local SearchStroke = Instance.new("UIStroke", SearchContainer)
SearchStroke.Thickness = 1.5
SearchStroke.Color = Color3.fromRGB(0, 170, 255)
SearchStroke.Transparency = 1

local SearchBox = Instance.new("TextBox", SearchContainer)
SearchBox.Size = UDim2.new(1, -20, 1, 0)
SearchBox.Position = UDim2.new(0, 10, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "Search features..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.new(1, 1, 1)
SearchBox.PlaceholderColor3 = Color3.fromRGB(160, 160, 160)
SearchBox.Font = Enum.Font.GothamSemibold
SearchBox.TextSize = 13
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ZIndex = 101

-- [[ ======================================================= ]] --
-- [[ SEARCH BOX TWEEN INTERACTIONS & HOVER ANIMS ]] --
-- [[ ======================================================= ]] --
SearchBox.Focused:Connect(function() 
    CreateTween(SearchStroke, {Color = Color3.fromRGB(96, 201, 211), Transparency = 0.1}, 0.2) 
end)

SearchBox.FocusLost:Connect(function() 
    CreateTween(SearchStroke, {Color = Color3.fromRGB(0, 170, 255), Transparency = 0.4}, 0.2) 
end)

SearchBtn.MouseEnter:Connect(function()
    CreateTween(SearchBtn, {ImageTransparency = 0.3}, 0.2)
end)

SearchBtn.MouseLeave:Connect(function()
    CreateTween(SearchBtn, {ImageTransparency = 0}, 0.2)
end)

-- [[ ======================================================= ]] --
-- [[ SEARCH TOGGLE MECHANISM (1-CLICK ACTIVATE/DEACTIVATE) ]] --
-- [[ ======================================================= ]] --
local isSearchActive = false

local function TriggerSearchInterface(state)
    isSearchActive = state
    if isSearchActive then
        SearchContainer.Visible = true
        -- Slide down slightly below the TopBar and overlay everything cleanly
        CreateTween(SearchContainer, {Position = UDim2.new(0, 115, 0, 60), BackgroundTransparency = 0.1}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        CreateTween(SearchStroke, {Transparency = 0.4}, 0.3)
        SearchBox:CaptureFocus()
    else
        SearchBox:ReleaseFocus()
        local ShrinkTween = CreateTween(SearchContainer, {Position = UDim2.new(0, 115, 0, 15), BackgroundTransparency = 1}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        CreateTween(SearchStroke, {Transparency = 1}, 0.25)
        
        ShrinkTween.Completed:Connect(function()
            if not isSearchActive then
                SearchContainer.Visible = false
            end
        end)
    end
end

SearchBtn.Activated:Connect(function()
    TriggerSearchInterface(not isSearchActive)
end)

-- [[ ======================================================= ]] --
-- [[ REALTIME TEXT FILTERING ENGINE ]] --
-- [[ ======================================================= ]] --
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local input = SearchBox.Text:lower()
    for _, tabFrame in pairs(PageArea:GetChildren()) do
        if tabFrame:IsA("ScrollingFrame") and tabFrame.Visible then
            for _, item in pairs(tabFrame:GetChildren()) do
                if item:IsA("Frame") or item:IsA("TextButton") or item:IsA("TextLabel") then
                    local toSearch = ""
                    if item:IsA("TextButton") or item:IsA("TextLabel") then 
                        toSearch = item.Text:lower()
                    elseif item:FindFirstChild("Title") then 
                        toSearch = item.Title.Text:lower()
                    elseif item:FindFirstChild("MainBtn") then 
                        toSearch = item.MainBtn.Text:lower() 
                    end
                    
                    if toSearch ~= "" then 
                        local match = toSearch:find(input) ~= nil
                        if match then
                            if not item.Visible then
                                item.Visible = true
                                item.BackgroundTransparency = 1
                                CreateTween(item, {BackgroundTransparency = 0}, 0.2)
                            end
                        else
                            item.Visible = false
                        end
                    end
                end
            end
        end
    end
end)

    local WindowAPI = {}

function WindowAPI:UpdateHubInfo(cfg)
    if type(cfg) ~= "table" then return end

    if cfg.Name and HubLabel then    
        HubLabel.Text = cfg.Name    
    end    

    local discordLink = cfg.discord or cfg.Discord
    if discordLink then    
        ActiveDiscordLink = discordLink 
        if DiscordBtn then
            DiscordBtn.Text = "🔗 " .. discordLink    
        end
    end

    if cfg.Logo and cfg.Logo ~= "" and HubLogo then
        local targetFolder = cfg.foldertarget or "VeridianConfig/Icons"
        
        if cfg.createfolder and type(cfg.createfolder) == "string" and cfg.createfolder ~= "" then
            targetFolder = targetFolder .. "/" .. cfg.createfolder
        end

        local fileName = cfg.createfile
        if not fileName or fileName == "" then
            local cleanHubName = (cfg.Name or "default"):gsub("[%s%p]", ""):lower()
            fileName = cleanHubName .. "_logo.png"
        end
        
        local logoPath = targetFolder .. "/" .. fileName

        task.spawn(function()    
            local currentPath = ""
            for folder in string.gmatch(targetFolder, "[^/]+") do
                currentPath = currentPath == "" and folder or currentPath .. "/" .. folder
                pcall(function()
                    if not isfolder(currentPath) then
                        makefolder(currentPath)
                    end
                end)
            end

            if string.find(cfg.Logo, "http") and not isfile(logoPath) then    
                local success, imgData = pcall(game.HttpGet, game, cfg.Logo)    
                if success and imgData and #imgData > 0 and not string.find(imgData, "<!DOCTYPE") then    
                    pcall(writefile, logoPath, imgData)
                end    
            end    

            if isfile(logoPath) then    
                local getAsset = getcustomasset or getsynasset    
                if getAsset then    
                    pcall(function()
                        HubLogo.Image = getAsset(logoPath)
                    end)
                end    
            end    
        end)    
    end
end


function WindowAPI:UpdateTheme(newColor)
    -- [[ 1. Color Processing (Deepening Effect) ]]
    local BaseDark = Color3.fromRGB(15, 15, 20)
    local MutedColor = newColor:lerp(BaseDark, 0.7) 
    local DeepOverlay = MutedColor:lerp(BaseDark, 0.8)
    local HighlightColor = MutedColor:lerp(Color3.new(1, 1, 1), 0.3) 
    
    local GlobalTransparency = 0.5 

    CONFIG.NavBtnColor = MutedColor
    CONFIG.HoverColor = MutedColor:lerp(Color3.new(1, 1, 1), 0.15)
    CONFIG.SearchBgColor = DeepOverlay 
    CONFIG.NavPanelColor = DeepOverlay:lerp(BaseDark, 0.2) 

    -- [[ 2. Top Bar, Global Controls & Side Panel ]]
    if TopBar then 
        CreateTween(TopBar, {
            BackgroundColor3 = CONFIG.NavPanelColor,
            BackgroundTransparency = GlobalTransparency
        }, 0.5) 
    end
    
    if HubLabel then CreateTween(HubLabel, {TextColor3 = Color3.new(1, 1, 1)}, 0.3) end
    if ToggleBtn then CreateTween(ToggleBtn, {BackgroundColor3 = MutedColor}, 0.3) end
    
    if SearchBox then 
        CreateTween(SearchBox, {
            BackgroundColor3 = DeepOverlay, 
            TextColor3 = Color3.new(0.9, 0.9, 0.9)
        }, 0.5) 
    end
    
    if TopSettingBtn then CreateTween(TopSettingBtn, {TextColor3 = HighlightColor}, 0.3) end
    if UIStroke then CreateTween(UIStroke, {Color = MutedColor}, 0.3) end

    if NavSidePanel then 
        CreateTween(NavSidePanel, {
            BackgroundColor3 = CONFIG.NavPanelColor,
            BackgroundTransparency = GlobalTransparency
        }, 0.5)
    end

    -- [[ 3. Navigation Buttons (Left Panel) ]]
    for _, btn in pairs(NavArea:GetChildren()) do
        if btn:IsA("TextButton") then
            CreateTween(btn, {
                BackgroundColor3 = MutedColor,
                BackgroundTransparency = GlobalTransparency,
                TextColor3 = Color3.fromRGB(220, 220, 220)
            }, 0.5)
            
            local st = btn:FindFirstChildOfClass("UIStroke")
            if st then CreateTween(st, {Color = HighlightColor:lerp(BaseDark, 0.5)}, 0.3) end
        end
    end

    -- [[ 4. Tab Content Deep-Sync (The "Global Overwrite") ]]
    for _, tab in pairs(PageArea:GetChildren()) do
        if tab:IsA("ScrollingFrame") or tab:IsA("Frame") then
            for _, item in pairs(tab:GetChildren()) do
                if item:IsA("TextButton") then
                    if not item:FindFirstChild("IsToggle") then 
                        CreateTween(item, {
                            BackgroundColor3 = DeepOverlay:lerp(MutedColor, 0.2),
                            BackgroundTransparency = GlobalTransparency
                        }, 0.5)
                    end
                elseif item:IsA("Frame") then
                    CreateTween(item, {
                        BackgroundColor3 = DeepOverlay,
                        BackgroundTransparency = GlobalTransparency
                    }, 0.5)
                    
                    local fill = item:FindFirstChild("Fill", true) 
                    if fill then CreateTween(fill, {BackgroundColor3 = MutedColor}, 0.3) end
                elseif item:IsA("TextLabel") then
                    CreateTween(item, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.5)
                end
            end
        end
    end
    
    -- [[ 5. Visual Polish (Darkened Canvas) ]]
    if MainFrame then
        CreateTween(MainFrame, {GroupColor3 = Color3.fromRGB(230, 230, 245)}, 0.5)
    end
end

function WindowAPI:CreateTab(name, target, isAuto)
    local TabPage = Instance.new("ScrollingFrame", PageArea)
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.Position = UDim2.new(0, 20, 0, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.ScrollBarThickness = 2 
    TabPage.AutomaticCanvasSize = "Y"
    TabPage.ZIndex = 11
    
    local ListLayout = Instance.new("UIListLayout", TabPage)
    ListLayout.Padding = UDim.new(0, 12) 
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding", TabPage)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 8)

    local b = Instance.new("TextButton", NavArea)
    b.Size = UDim2.new(0, 105, 0, 36)
    b.BackgroundColor3 = CONFIG.NavBtnColor or Color3.fromRGB(35, 35, 40)
    b.BackgroundTransparency = 0.3
    b.Text = name
    b.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    b.Font = Enum.Font.GothamBold
    b.TextSize = CONFIG.DefaultFontSize or 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
    b.ZIndex = 12
    
    local bStroke = Instance.new("UIStroke", b)
    bStroke.Color = Color3.new(1, 1, 1)
    bStroke.Transparency = 0.85
    
    b.MouseEnter:Connect(function() 
        CreateTween(b, {BackgroundTransparency = 0, TextColor3 = Color3.new(1, 1, 1)}) 
        CreateTween(bStroke, {Transparency = 0.5})
    end)
    b.MouseLeave:Connect(function() 
        CreateTween(b, {BackgroundTransparency = 0.3, TextColor3 = Color3.new(0.9, 0.9, 0.9)}) 
        CreateTween(bStroke, {Transparency = 0.85})
    end)

    local TabAPI = {}
    
    -- [ ADAPTER LAYER FOR RAYFIELD ]
    
    function TabAPI:CreateLabel(cfg)
        local labelText = type(cfg) == "table" and (cfg.Text or cfg.Name or "Label") or cfg

        local frame = Instance.new("Frame", TabPage)
        frame.Size = UDim2.new(0.96, 0, 0, 34)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        frame.BackgroundTransparency = 0.5
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
        frame.ZIndex = 14
        
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.9

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -16, 1, 0)
        lbl.Position = UDim2.new(0, 16, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(200, 200, 205)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextXAlignment = "Left"
        lbl.ZIndex = 15
        
        return {
            Set = function(_, newText) lbl.Text = newText end
        }
    end
    
    function TabAPI:CreateButton(cfg)
        local btn = Instance.new("TextButton", TabPage)
        btn.Size = UDim2.new(0.96, 0, 0, 42)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        btn.BackgroundTransparency = 0.5
        btn.Text = "  " .. (cfg.Name or "Button")
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextXAlignment = "Left"
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
        btn.ZIndex = 15
        
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = CONFIG.NavBtnColor or Color3.fromRGB(100, 100, 110)
        stroke.Transparency = 0.8
        
        btn.MouseEnter:Connect(function() 
            CreateTween(btn, {BackgroundTransparency = 0.3}) 
            CreateTween(stroke, {Transparency = 0.4})
        end)
        btn.MouseLeave:Connect(function() 
            CreateTween(btn, {BackgroundTransparency = 0.5}) 
            CreateTween(stroke, {Transparency = 0.8})
        end)
        btn.MouseButton1Down:Connect(function() CreateTween(btn, {Size = UDim2.new(0.94, 0, 0, 40)}) end)
        btn.MouseButton1Up:Connect(function() CreateTween(btn, {Size = UDim2.new(0.96, 0, 0, 42)}) end)
        btn.MouseButton1Click:Connect(function() pcall(cfg.Callback) end)
        
        return {Callback = cfg.Callback}
    end
    
    function TabAPI:CreateToggle(cfg)
        local s = cfg.CurrentValue
        if s == nil then s = cfg.Default or false end
        
        local ColorOn = CONFIG.NavBtnColor or Color3.fromRGB(46, 204, 113)
        local ColorOff = Color3.fromRGB(60, 60, 65)

        local btn = Instance.new("TextButton", TabPage)
        btn.Size = UDim2.new(0.96, 0, 0, 44)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        btn.BackgroundTransparency = 0.5
        btn.Text = ""
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
        btn.ZIndex = 15
        
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.9

        local title = Instance.new("TextLabel", btn)
        title.Size = UDim2.new(1, -64, 1, 0)
        title.Position = UDim2.new(0, 16, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = cfg.Name or "Toggle"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 13
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 16

        local switchBg = Instance.new("Frame", btn)
        switchBg.Size = UDim2.new(0, 38, 0, 20)
        switchBg.Position = UDim2.new(1, -50, 0.5, -10)
        switchBg.BackgroundColor3 = s and ColorOn or ColorOff
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
        switchBg.ZIndex = 16

        local knob = Instance.new("Frame", switchBg)
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = s and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        knob.ZIndex = 17

        btn.MouseEnter:Connect(function() CreateTween(stroke, {Transparency = 0.5}) end)
        btn.MouseLeave:Connect(function() CreateTween(stroke, {Transparency = 0.9}) end)

        local function toggle(Value)
            if Value == nil then s = not s else s = Value end
            CreateTween(switchBg, {BackgroundColor3 = s and ColorOn or ColorOff}, 0.2)
            CreateTween(knob, {Position = s and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            pcall(cfg.Callback, s)
        end

        btn.MouseButton1Click:Connect(function() toggle() end)
        return {
            Set = function(_, Value) toggle(Value) end,
            CurrentValue = s
        }
    end

    function TabAPI:CreateSlider(cfg)
        local dragging = false
        
        local min = cfg.Range and cfg.Range[1] or cfg.Min or 0
        local max = cfg.Range and cfg.Range[2] or cfg.Max or 100
        local val = cfg.CurrentValue or cfg.Default or min
        local suffix = cfg.Suffix or ""
        
        local sf = Instance.new("Frame", TabPage)
        sf.Size = UDim2.new(0.96, 0, 0, 56)
        sf.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        sf.BackgroundTransparency = 0.5
        Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 12)
        sf.ZIndex = 15
        sf.Active = true
        
        local stroke = Instance.new("UIStroke", sf)
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.9
        
        local t = Instance.new("TextLabel", sf)
        t.Size = UDim2.new(1, -24, 0, 24)
        t.Position = UDim2.new(0, 16, 0, 6)
        t.BackgroundTransparency = 1
        t.Text = (cfg.Name or "Slider") .. " : " .. val .. suffix
        t.TextColor3 = Color3.new(1, 1, 1)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 13
        t.TextXAlignment = "Left"
        t.ZIndex = 16
        
        local bar = Instance.new("Frame", sf)
        bar.Size = UDim2.new(0.92, 0, 0, 6)
        bar.Position = UDim2.new(0.04, 0, 0, 38)
        bar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        bar.ClipsDescendants = true
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        bar.ZIndex = 16
        bar.Active = true
        
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = CONFIG.NavBtnColor or Color3.fromRGB(52, 152, 219)
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        fill.ZIndex = 17
        
        sf.MouseEnter:Connect(function() CreateTween(stroke, {Transparency = 0.5}) end)
        sf.MouseLeave:Connect(function() CreateTween(stroke, {Transparency = 0.9}) end)

        local function updateSlider(customVal)
            if customVal then
                val = math.clamp(customVal, min, max)
                local p = (val - min) / (max - min)
                CreateTween(fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.1)
            else
                local p = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                CreateTween(fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.1)
                val = math.floor(min + (p * (max - min)))
            end
            t.Text = (cfg.Name or "Slider") .. " : " .. val .. suffix
            pcall(cfg.Callback, val)
        end

        bar.InputBegan:Connect(function(i) 
            if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then dragging = true end 
        end)
        UserInputService.InputEnded:Connect(function(i) 
            if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then dragging = false end 
        end)
        RunService.RenderStepped:Connect(function() if dragging then updateSlider() end end)
        
        return {Set = function(_, Value) updateSlider(Value) end}
    end

    function TabAPI:CreateDropdown(cfg)
        local open = false
        local options = cfg.Options or {}
        local optionsCount = #options
        local itemHeight = 32
        local maxDisplayItems = 4
        local closedSize = UDim2.new(0.96, 0, 0, 42)
        local openedSize = UDim2.new(0.96, 0, 0, 42 + math.min(optionsCount * itemHeight, maxDisplayItems * itemHeight))

        local df = Instance.new("Frame", TabPage)
        df.Size = closedSize
        df.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        df.BackgroundTransparency = 0.5
        df.ClipsDescendants = true
        df.ZIndex = 15
        Instance.new("UICorner", df).CornerRadius = UDim.new(0, 12)

        local stroke = Instance.new("UIStroke", df)
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.9

        local mb = Instance.new("TextButton", df)
        mb.Size = UDim2.new(1, 0, 0, 42)
        mb.BackgroundTransparency = 1
        
        local initialVal = cfg.CurrentValue or cfg.Default or ""
        mb.Text = "  " .. (cfg.Name or "Dropdown") .. (initialVal ~= "" and (" : " .. tostring(initialVal)) or "")
        mb.TextColor3 = Color3.new(1, 1, 1)
        mb.Font = Enum.Font.GothamBold
        mb.TextSize = 13
        mb.TextXAlignment = Enum.TextXAlignment.Left
        mb.ZIndex = 16

        local Arrow = Instance.new("TextLabel", mb)
        Arrow.Size = UDim2.new(0, 40, 0, 42)
        Arrow.Position = UDim2.new(1, -40, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "▼"
        Arrow.TextColor3 = Color3.fromRGB(180, 180, 185)
        Arrow.TextSize = 10
        Arrow.ZIndex = 17

        local DropScroll = Instance.new("ScrollingFrame", df)
        DropScroll.Size = UDim2.new(1, -8, 1, -46)
        DropScroll.Position = UDim2.new(0, 4, 0, 44)
        DropScroll.BackgroundTransparency = 1
        DropScroll.ScrollBarThickness = 2
        DropScroll.ScrollBarImageColor3 = CONFIG.NavBtnColor or Color3.new(1,1,1)
        DropScroll.CanvasSize = UDim2.new(0, 0, 0, optionsCount * itemHeight)
        DropScroll.ZIndex = 16
        DropScroll.Visible = false

        local DropList = Instance.new("UIListLayout", DropScroll)
        DropList.Padding = UDim.new(0, 4)
        DropList.SortOrder = Enum.SortOrder.LayoutOrder

        df.MouseEnter:Connect(function() CreateTween(stroke, {Transparency = 0.5}) end)
        df.MouseLeave:Connect(function() CreateTween(stroke, {Transparency = 0.9}) end)

        local function toggleDropdown()
            open = not open
            CreateTween(df, {Size = open and openedSize or closedSize}, 0.25, Enum.EasingStyle.Quart)
            CreateTween(Arrow, {Rotation = open and 180 or 0}, 0.25)
            if open then DropScroll.Visible = true else task.delay(0.2, function() if not open then DropScroll.Visible = false end end) end
        end

        mb.MouseButton1Click:Connect(toggleDropdown)

        local function createOptions()
            for _, child in pairs(DropScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for i, opt in pairs(options) do
                local o = Instance.new("TextButton", DropScroll)
                o.Size = UDim2.new(1, -8, 0, 28)
                o.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                o.BackgroundTransparency = 0.3
                o.Text = tostring(opt)
                o.TextColor3 = Color3.fromRGB(200, 200, 205)
                o.Font = Enum.Font.GothamSemibold
                o.TextSize = 12
                o.ZIndex = 17
                Instance.new("UICorner", o).CornerRadius = UDim.new(0, 8)

                o.MouseEnter:Connect(function() CreateTween(o, {BackgroundTransparency = 0, TextColor3 = Color3.new(1, 1, 1)}, 0.1) end)
                o.MouseLeave:Connect(function() CreateTween(o, {BackgroundTransparency = 0.3, TextColor3 = Color3.fromRGB(200, 200, 205)}, 0.1) end)

                o.MouseButton1Click:Connect(function()
                    mb.Text = "  " .. (cfg.Name or "Dropdown") .. " : " .. tostring(opt)
                    toggleDropdown()
                    pcall(cfg.Callback, opt)
                end)
            end
        end
        createOptions()

        return {
            Refresh = function(_, newOptions, _) 
                options = newOptions or {}
                optionsCount = #options
                DropScroll.CanvasSize = UDim2.new(0, 0, 0, optionsCount * itemHeight)
                openedSize = UDim2.new(0.96, 0, 0, 42 + math.min(optionsCount * itemHeight, maxDisplayItems * itemHeight))
                createOptions()
            end,
            Set = function(_, Value)
                mb.Text = "  " .. (cfg.Name or "Dropdown") .. " : " .. tostring(Value)
                pcall(cfg.Callback, Value)
            end
        }
    end

    local function OpenTab()
        if SearchBox then SearchBox.Text = "" end
        for _, v in pairs(PageArea:GetChildren()) do 
            if v.Visible then 
                CreateTween(v, {BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0)}, 0.15).Completed:Connect(function() v.Visible = false end) 
            end
        end
        TabPage.Visible = true
        CreateTween(TabPage, {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Sine)
        
        if not TabPage:FindFirstChild("HasRan") then
            if type(target) == "function" then target(TabPage, TabAPI)
            elseif type(target) == "string" and target:find("http") then
                local lb = Instance.new("TextButton", TabPage)
                lb.Size = UDim2.new(0.96, 0, 0, 42)
                lb.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                lb.Text = " Load String: " .. name
                lb.TextColor3 = Color3.new(1, 1, 1)
                lb.Font = Enum.Font.GothamBold
                Instance.new("UICorner", lb).CornerRadius = UDim.new(0, 12)
                lb.ZIndex = 15
                lb.MouseButton1Click:Connect(function() pcall(function() loadstring(game:HttpGet(target))() end) end)
            end
            Instance.new("BoolValue", TabPage).Name = "HasRan"
        end
    end
    
    b.MouseButton1Click:Connect(OpenTab)
    if isAuto then OpenTab() end
    
    return TabAPI 
end

    local SettingPage = Instance.new("ScrollingFrame", PageArea)
    SettingPage.Size = UDim2.new(1, 0, 1, 0)
    SettingPage.Position = UDim2.new(0, 20, 0, 0)
    SettingPage.BackgroundTransparency = 1
    SettingPage.Visible = false
    SettingPage.ScrollBarThickness = 3
    SettingPage.AutomaticCanvasSize = "Y"
    SettingPage.ZIndex = 11
    
    CONFIG.SaveFileName = "DefaultConfig"
    CONFIG.ConfigFolderName = "Configs" 
    CONFIG.AutoLoad = false

    local HttpService = game:GetService("HttpService")

    -- ฟังก์ชันช่วยจัดการ Path ไฟล์ให้เป๊ะเสมอ
    local function GetConfigPath(fileName, folderName)
        local folder = (folderName == "" or not folderName) and CONFIG.ConfigFolderName or folderName
        local file = (fileName == "" or not fileName) and CONFIG.SaveFileName or fileName
        if not file:match("%.json$") then file = file .. ".json" end
        return CONFIG.BgFolder .. "/" .. folder .. "/" .. file
    end

    local function CheckFolders(folderName)
        local folder = (folderName == "" or not folderName) and CONFIG.ConfigFolderName or folderName
        local targetFolder = CONFIG.BgFolder .. "/" .. folder

        if not isfolder(CONFIG.BgFolder) then makefolder(CONFIG.BgFolder) end
        if not isfolder(targetFolder) then makefolder(targetFolder) end
    end

    -- ปรับปรุงให้รับค่าชื่อไฟล์และโฟลเดอร์ได้ (ถ้าไม่ใส่จะใช้ค่าเริ่มต้น)
    local function SaveConfiguration(fileName, folderName)
        CheckFolders(folderName)
        local path = GetConfigPath(fileName, folderName)
        
        local dataToSave = {
            AutoLoad = CONFIG.AutoLoad,
            KeybindEnabled = CONFIG.KeybindEnabled,
            ToggleKey = CONFIG.ToggleKey.Name
        }
        
        local success, err = pcall(function()
            writefile(path, HttpService:JSONEncode(dataToSave))
        end)
        
        if success then
            -- อัพเดทค่าปัจจุบันเมื่อเซฟสำเร็จ
            if fileName and fileName ~= "" then CONFIG.SaveFileName = fileName end
            if folderName and folderName ~= "" then CONFIG.ConfigFolderName = folderName end
            print("Saved: " .. path)
            return true
        else
            warn("Save Error: " .. tostring(err))
            return false
        end
    end

    -- ปรับปรุงให้รับค่าชื่อไฟล์และโฟลเดอร์ได้
    local function LoadConfiguration(fileName, folderName)
        local path = GetConfigPath(fileName, folderName)
        if isfile(path) then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(path))
            end)
            
            if success and type(data) == "table" then
                CONFIG.AutoLoad = data.AutoLoad or false
                if data.ToggleKey then
                    CONFIG.ToggleKey = Enum.KeyCode[data.ToggleKey]
                end
                CONFIG.KeybindEnabled = data.KeybindEnabled or false
                
                print("Loaded: " .. path)
                return true
            end
        end
        warn("Config file not found: " .. path)
        return false
    end

    local function RenderSettings()
        SettingPage:ClearAllChildren()
        local UIListLayout = Instance.new("UIListLayout", SettingPage)
        UIListLayout.Padding = UDim.new(0, 5)
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local l = Instance.new("TextLabel", SettingPage)
        l.Size = UDim2.new(1, 0, 0, 30)
        l.Text = "Control Panel"
        l.BackgroundTransparency = 1
        l.TextColor3 = Color3.new(1, 1, 1)
        l.Font = Enum.Font.GothamBold
        l.TextSize = CONFIG.DefaultFontSize
        l.ZIndex = 15

        local ColorOn = Color3.fromRGB(46, 204, 113)
        local ColorOff = Color3.fromRGB(80, 80, 85)

        local kb = Instance.new("TextButton", SettingPage)
        kb.Size = UDim2.new(0.95, 0, 0, 40)
        kb.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        kb.Text = ""
        kb.AutoButtonColor = false
        Instance.new("UICorner", kb)
        kb.ZIndex = 15

        local title = Instance.new("TextLabel", kb)
        title.Size = UDim2.new(1, -60, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "Keybind (" .. CONFIG.ToggleKey.Name .. ")"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = Enum.Font.GothamBold
        title.TextSize = CONFIG.DefaultFontSize
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 16

        local switchBg = Instance.new("TextButton", kb)
        switchBg.Size = UDim2.new(0, 40, 0, 20)
        switchBg.Position = UDim2.new(1, -50, 0.5, -10)
        switchBg.BackgroundColor3 = CONFIG.KeybindEnabled and ColorOn or ColorOff
        switchBg.Text = ""
        switchBg.AutoButtonColor = false
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
        switchBg.ZIndex = 16

        local knob = Instance.new("Frame", switchBg)
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = CONFIG.KeybindEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        knob.ZIndex = 17

        switchBg.MouseButton1Click:Connect(function()
            CONFIG.KeybindEnabled = not CONFIG.KeybindEnabled
            CreateTween(switchBg, {BackgroundColor3 = CONFIG.KeybindEnabled and ColorOn or ColorOff}, 0.2)
            CreateTween(knob, {Position = CONFIG.KeybindEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)

        local bindConnection = nil
        local isListening = false

        kb.MouseButton1Click:Connect(function()
            if isListening then return end
            isListening = true
            title.Text = "Press any key..."

            if bindConnection then
                bindConnection:Disconnect()
                bindConnection = nil
            end

            bindConnection = UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.Escape then
                        CONFIG.ToggleKey = input.KeyCode
                        title.Text = "Keybind (" .. input.KeyCode.Name .. ")"
                    else
                        title.Text = "Keybind (" .. CONFIG.ToggleKey.Name .. ")"
                    end
                    
                    isListening = false
                    if bindConnection then
                        bindConnection:Disconnect()
                        bindConnection = nil
                    end
                end
            end)
        end)

        local extThemes = {["Default"] = CONFIG.NavBtnColor}
        local urls = {"https://raw.githubusercontent.com/modcreate1641-collab/Veridian/refs/heads/main/theme.json"}

        task.spawn(function()
            for _, u in ipairs(urls) do
                pcall(function()
                    local d = game:HttpGet(u)
                    if d then
                        local decoded = HttpService:JSONDecode(d)
                        if type(decoded) == "table" then
                            for k, v in pairs(decoded) do 
                                extThemes[k] = Color3.fromRGB(v[1], v[2], v[3]) 
                            end
                            
                            local themePath = CONFIG.BgFolder .. "/Theme/theme.json"
                            if writefile and isfile and not isfile(themePath) then
                                writefile(themePath, d)
                            end
                        end
                    end
                end)
            end
        end)

        local function BuildDrop(name, getOpts, cb)
            local open = false
            local itemHeight = 32
            local maxDisplayItems = 2.5
            local closedSize = UDim2.new(0.95, 0, 0, 35)
            
            local df = Instance.new("Frame", SettingPage)
            df.Name = "SettingDrop_" .. name
            df.Size = closedSize
            df.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            df.ClipsDescendants = true
            df.ZIndex = 20
            Instance.new("UICorner", df)
            
            local mb = Instance.new("TextButton", df)
            mb.Name = "MainBtn"
            mb.Size = UDim2.new(1, 0, 0, 35)
            mb.BackgroundTransparency = 1
            mb.Text = "  " .. name
            mb.TextColor3 = Color3.new(1, 1, 1)
            mb.Font = Enum.Font.GothamBold
            mb.TextSize = CONFIG.DefaultFontSize
            mb.TextXAlignment = Enum.TextXAlignment.Left
            mb.ZIndex = 21
            
            local Arrow = Instance.new("TextLabel", mb)
            Arrow.Name = "Arrow"
            Arrow.Size = UDim2.new(0, 35, 0, 35)
            Arrow.Position = UDim2.new(1, -35, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
            Arrow.TextSize = 10
            Arrow.ZIndex = 22

            local DropScroll = Instance.new("ScrollingFrame", df)
            DropScroll.Name = "DropScroll"
            DropScroll.Size = UDim2.new(1, -4, 1, -40)
            DropScroll.Position = UDim2.new(0, 2, 0, 38)
            DropScroll.BackgroundTransparency = 1
            DropScroll.ScrollBarThickness = 2
            DropScroll.ScrollBarImageColor3 = CONFIG.NavBtnColor
            DropScroll.ZIndex = 21
            DropScroll.Visible = false
            DropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

            local list = Instance.new("UIListLayout", DropScroll)
            list.Padding = UDim.new(0, 2)
            list.SortOrder = Enum.SortOrder.LayoutOrder

            local function RefreshOptions()
                for _, child in pairs(DropScroll:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                
                local opts = getOpts()
                DropScroll.CanvasSize = UDim2.new(0, 0, 0, #opts * itemHeight)
                
                for _, o in ipairs(opts) do
                    local btn = Instance.new("TextButton", DropScroll)
                    btn.Size = UDim2.new(1, -6, 0, 30)
                    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                    btn.Text = o
                    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    btn.Font = Enum.Font.GothamBold
                    btn.TextSize = CONFIG.DefaultFontSize
                    btn.ZIndex = 22
                    Instance.new("UICorner", btn)
                    
                    btn.MouseButton1Click:Connect(function()
                        open = false
                        CreateTween(df, {Size = closedSize}, 0.3, Enum.EasingStyle.Quart)
                        CreateTween(Arrow, {Rotation = 0}, 0.3)
                        DropScroll.Visible = false
                        mb.Text = "  " .. name .. " : " .. o
                        cb(o)
                    end)
                end
                return #opts
            end
            
            mb.MouseButton1Click:Connect(function()
                open = not open
                local currentOptsCount = RefreshOptions()
                
                local displayCount = math.min(currentOptsCount, maxDisplayItems)
                local targetHeight = open and (35 + (displayCount * itemHeight) + 10) or 35
                local targetSize = UDim2.new(0.95, 0, 0, targetHeight)
                
                CreateTween(df, {Size = targetSize}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                CreateTween(Arrow, {Rotation = open and 180 or 0}, 0.3, Enum.EasingStyle.Back)
                
                if open then
                    DropScroll.Visible = true
                else
                    task.delay(0.2, function() if not open then DropScroll.Visible = false end end)
                end
            end)
        end

        BuildDrop("Theme", function()
            local t = {}
            for k, _ in pairs(extThemes) do table.insert(t, k) end
            table.sort(t)
            return t
        end, function(s)
            local c = extThemes[s]
            if c then
                WindowAPI:UpdateTheme(c)
            end
        end)

        BuildDrop("Background", function()
            local t = {"None"}
            local targetFolder = CONFIG.BgFolder .. "/BgAsset"
            if isfolder and isfolder(targetFolder) then
                local validExts = {".png", ".jpg", ".jpeg", ".webp", ".bmp", ".tga"}
                for _, f in pairs(listfiles(targetFolder)) do
                    local n = f:sub(#targetFolder + 2)
                    local ext = n:lower()
                    for _, valid in ipairs(validExts) do
                        if ext:sub(-#valid) == valid then
                            table.insert(t, n)
                            break
                        end
                    end
                end
            end
            return t
        end, function(s)
            if s == "None" then 
                if BgImage then BgImage.Image = "" end
                if DarkOverlay then DarkOverlay.Visible = false end
                if MainFrame then MainFrame.BackgroundTransparency = 0 end
            else 
                pcall(function() ApplyAutoBackground(s) end)
            end
        end)

        ----------------------------------------------------------------
        -- ⚡ PREMIUM MOBILE-FRIENDLY CONFIGURATION UI (FIXED 100%) ⚡
        ----------------------------------------------------------------
        local configTitle = Instance.new("TextLabel", SettingPage)
        configTitle.Size = UDim2.new(1, 0, 0, 35)
        configTitle.Text = "⚡ Advanced Configuration"
        configTitle.BackgroundTransparency = 1
        configTitle.TextColor3 = Color3.fromRGB(255, 180, 50) 
        configTitle.Font = Enum.Font.GothamBlack
        configTitle.TextSize = 15
        configTitle.ZIndex = 15

        -- // 1. แถบใส่ชื่อโฟลเดอร์ (Folder Name)
        local FolderBoxFrame = Instance.new("Frame", SettingPage)
        FolderBoxFrame.Size = UDim2.new(0.95, 0, 0, 42)
        FolderBoxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        FolderBoxFrame.ZIndex = 10 
        FolderBoxFrame.Active = true -- ป้องกันนิ้วทะลุ
        Instance.new("UICorner", FolderBoxFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", FolderBoxFrame).Color = Color3.fromRGB(50, 50, 55)

        local FolderIcon = Instance.new("TextLabel", FolderBoxFrame)
        FolderIcon.Size = UDim2.new(0, 40, 1, 0)
        FolderIcon.BackgroundTransparency = 1
        FolderIcon.Text = "📁"
        FolderIcon.TextSize = 18
        FolderIcon.ZIndex = 11

        local FolderInput = Instance.new("TextBox", FolderBoxFrame)
        FolderInput.Size = UDim2.new(1, -50, 1, 0)
        FolderInput.Position = UDim2.new(0, 40, 0, 0)
        FolderInput.BackgroundTransparency = 1
        FolderInput.Text = CONFIG.ConfigFolderName or "Configs"
        FolderInput.PlaceholderText = "ชื่อโฟลเดอร์ (Folder)..."
        FolderInput.TextColor3 = Color3.new(1, 1, 1)
        FolderInput.Font = Enum.Font.GothamSemibold
        FolderInput.TextSize = 14
        FolderInput.ClearTextOnFocus = false
        FolderInput.TextXAlignment = Enum.TextXAlignment.Left
        FolderInput.ZIndex = 11

        -- [!] สำคัญมาก: ระบบดักตอนพิมพ์เสร็จ ไม่งั้นมันไม่จำค่า!
        FolderInput.FocusLost:Connect(function()
            if FolderInput.Text == "" then FolderInput.Text = "Configs" end
            CONFIG.ConfigFolderName = FolderInput.Text
        end)

        -- // 2. แถบใส่ชื่อไฟล์ (File Name)
        local FileBoxFrame = Instance.new("Frame", SettingPage)
        FileBoxFrame.Size = UDim2.new(0.95, 0, 0, 42)
        FileBoxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        FileBoxFrame.ZIndex = 10 
        FileBoxFrame.Active = true -- ป้องกันนิ้วทะลุ
        Instance.new("UICorner", FileBoxFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", FileBoxFrame).Color = Color3.fromRGB(50, 50, 55)

        local FileIcon = Instance.new("TextLabel", FileBoxFrame)
        FileIcon.Size = UDim2.new(0, 40, 1, 0)
        FileIcon.BackgroundTransparency = 1
        FileIcon.Text = "📄"
        FileIcon.TextSize = 18
        FileIcon.ZIndex = 11

        local FileNameInput = Instance.new("TextBox", FileBoxFrame)
        FileNameInput.Size = UDim2.new(1, -50, 1, 0)
        FileNameInput.Position = UDim2.new(0, 40, 0, 0)
        FileNameInput.BackgroundTransparency = 1
        FileNameInput.Text = CONFIG.SaveFileName or "DefaultConfig"
        FileNameInput.PlaceholderText = "ตั้งชื่อไฟล์เซฟ (File)..."
        FileNameInput.TextColor3 = Color3.new(1, 1, 1)
        FileNameInput.Font = Enum.Font.GothamSemibold
        FileNameInput.TextSize = 14
        FileNameInput.ClearTextOnFocus = false
        FileNameInput.TextXAlignment = Enum.TextXAlignment.Left
        FileNameInput.ZIndex = 11

        -- [!] สำคัญมาก: ระบบดักตอนพิมพ์เสร็จ
        FileNameInput.FocusLost:Connect(function()
            if FileNameInput.Text == "" then FileNameInput.Text = "DefaultConfig" end
            CONFIG.SaveFileName = FileNameInput.Text
        end)

        -- // 3. Dropdown เลือกไฟล์เซฟ (File Selector)
        local DropOpen = false
        local DropFrame = Instance.new("Frame", SettingPage)
        DropFrame.Size = UDim2.new(0.95, 0, 0, 42)
        DropFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        DropFrame.ClipsDescendants = true
        DropFrame.ZIndex = 100 -- [!] อัด Z-Index ให้ทะลุเพดาน บังปุ่มอื่นมิดเวลาเปิด!
        DropFrame.Active = true 
        Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", DropFrame).Color = Color3.fromRGB(60, 60, 65)

        local DropBtn = Instance.new("TextButton", DropFrame)
        DropBtn.Size = UDim2.new(1, 0, 0, 42)
        DropBtn.BackgroundTransparency = 1
        DropBtn.Text = "   ▼  Select Existing Config..."
        DropBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        DropBtn.Font = Enum.Font.GothamBold
        DropBtn.TextSize = 13
        DropBtn.TextXAlignment = Enum.TextXAlignment.Left
        DropBtn.ZIndex = 101

        local RefreshListBtn = Instance.new("TextButton", DropBtn)
        RefreshListBtn.Size = UDim2.new(0, 40, 0, 42)
        RefreshListBtn.Position = UDim2.new(1, -40, 0, 0)
        RefreshListBtn.BackgroundTransparency = 1
        RefreshListBtn.Text = "🔄"
        RefreshListBtn.TextSize = 16
        RefreshListBtn.ZIndex = 102

        local ConfigScroll = Instance.new("ScrollingFrame", DropFrame)
        ConfigScroll.Size = UDim2.new(1, -8, 1, -46)
        ConfigScroll.Position = UDim2.new(0, 4, 0, 42)
        ConfigScroll.BackgroundTransparency = 1
        ConfigScroll.ScrollBarThickness = 3
        ConfigScroll.Visible = false
        ConfigScroll.ZIndex = 101 -- ให้สูงกว่าพื้น DropFrame

        local ConfigListLayout = Instance.new("UIListLayout", ConfigScroll)
        ConfigListLayout.Padding = UDim.new(0, 4)
        ConfigListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local function GetCurrentFolderPath()
            local fName = FolderInput.Text
            if fName == "" then fName = "Configs" end
            return CONFIG.BgFolder .. "/" .. fName
        end

        local function RefreshFileList()
            for _, child in pairs(ConfigScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end

            local targetFolder = GetCurrentFolderPath()
            if not isfolder(targetFolder) then return end

            local ySize = 0
            local success, files = pcall(function() return listfiles(targetFolder) end)
            
            if success and files then
                for _, file in pairs(files) do
                    local nameOnly = file:match("([^/\\]+)%.json$")
                    if nameOnly then
                        local btn = Instance.new("TextButton", ConfigScroll)
                        btn.Size = UDim2.new(1, -4, 0, 32)
                        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                        btn.Text = "  📄 " .. nameOnly
                        btn.TextColor3 = Color3.new(1, 1, 1)
                        btn.Font = Enum.Font.GothamSemibold
                        btn.TextSize = 13
                        btn.TextXAlignment = Enum.TextXAlignment.Left
                        btn.ZIndex = 102
                        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

                        btn.MouseButton1Click:Connect(function()
                            FileNameInput.Text = nameOnly
                            CONFIG.SaveFileName = nameOnly
                            DropBtn.Text = "   ▼  Selected: " .. nameOnly
                            DropOpen = false
                            CreateTween(DropFrame, {Size = UDim2.new(0.95, 0, 0, 42)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                            task.delay(0.2, function() ConfigScroll.Visible = false end)
                        end)
                        ySize = ySize + 36
                    end
                end
            end
            ConfigScroll.CanvasSize = UDim2.new(0, 0, 0, ySize)
        end

        DropBtn.MouseButton1Click:Connect(function()
            DropOpen = not DropOpen
            if DropOpen then
                RefreshFileList()
                CreateTween(DropFrame, {Size = UDim2.new(0.95, 0, 0, 180)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                ConfigScroll.Visible = true
            else
                CreateTween(DropFrame, {Size = UDim2.new(0.95, 0, 0, 42)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                task.delay(0.2, function() ConfigScroll.Visible = false end)
            end
        end)

        RefreshListBtn.MouseButton1Click:Connect(function()
            RefreshFileList()
            if not DropOpen then
                DropOpen = true
                CreateTween(DropFrame, {Size = UDim2.new(0.95, 0, 0, 180)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                ConfigScroll.Visible = true
            end
        end)

        -- // 4. ปุ่ม Action
        local ActionRow1 = Instance.new("Frame", SettingPage)
        ActionRow1.Size = UDim2.new(0.95, 0, 0, 40)
        ActionRow1.BackgroundTransparency = 1
        ActionRow1.ZIndex = 10 
        ActionRow1.Active = true
        
        local SaveBtn = Instance.new("TextButton", ActionRow1)
        SaveBtn.Size = UDim2.new(0.48, 0, 1, 0)
        SaveBtn.Position = UDim2.new(0, 0, 0, 0)
        SaveBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        SaveBtn.Text = "💾 SAVE"
        SaveBtn.TextColor3 = Color3.new(0, 0, 0)
        SaveBtn.Font = Enum.Font.GothamBold
        SaveBtn.TextSize = 14
        SaveBtn.ZIndex = 11
        Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)

        local LoadBtn = Instance.new("TextButton", ActionRow1)
        LoadBtn.Size = UDim2.new(0.48, 0, 1, 0)
        LoadBtn.Position = UDim2.new(1, 0, 0, 0)
        LoadBtn.AnchorPoint = Vector2.new(1, 0)
        LoadBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
        LoadBtn.Text = "📂 LOAD"
        LoadBtn.TextColor3 = Color3.new(0, 0, 0)
        LoadBtn.Font = Enum.Font.GothamBold
        LoadBtn.TextSize = 14
        LoadBtn.ZIndex = 11
        Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 6)

        local ActionRow2 = Instance.new("Frame", SettingPage)
        ActionRow2.Size = UDim2.new(0.95, 0, 0, 40)
        ActionRow2.BackgroundTransparency = 1
        ActionRow2.ZIndex = 10 
        ActionRow2.Active = true

        local DeleteBtn = Instance.new("TextButton", ActionRow2)
        DeleteBtn.Size = UDim2.new(1, 0, 1, 0)
        DeleteBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        DeleteBtn.Text = "🗑️ DELETE CONFIG"
        DeleteBtn.TextColor3 = Color3.new(1, 1, 1)
        DeleteBtn.Font = Enum.Font.GothamBold
        DeleteBtn.TextSize = 14
        DeleteBtn.ZIndex = 11
        Instance.new("UICorner", DeleteBtn).CornerRadius = UDim.new(0, 6)

        SaveBtn.MouseButton1Click:Connect(function()
            local success = SaveConfiguration(FileNameInput.Text, FolderInput.Text)
            if success then
                SaveBtn.Text = "✅ SAVED!"
                if RefreshFileList then RefreshFileList() end
            else
                SaveBtn.Text = "❌ ERROR"
            end
            task.delay(1, function() SaveBtn.Text = "💾 SAVE" end)
        end)

        LoadBtn.MouseButton1Click:Connect(function()
            local success = LoadConfiguration(FileNameInput.Text, FolderInput.Text)
            if success then
                -- อัปเดต Toggle Keybind UI ถ้ามี
                if switchBg and knob then
                    CreateTween(switchBg, {BackgroundColor3 = CONFIG.KeybindEnabled and ColorOn or ColorOff}, 0.2)
                    CreateTween(knob, {Position = CONFIG.KeybindEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
                end
                if title then title.Text = "Keybind (" .. CONFIG.ToggleKey.Name .. ")" end

                -- อัปเดต Toggle AutoLoad UI 
                local autoSwitchBg = SettingPage:FindFirstChild("AutoLoadSwitchBg", true)
                local autoKnob = SettingPage:FindFirstChild("AutoLoadKnob", true)
                if autoSwitchBg and autoKnob then
                    CreateTween(autoSwitchBg, {BackgroundColor3 = CONFIG.AutoLoad and ColorOn or ColorOff}, 0.2)
                    CreateTween(autoKnob, {Position = CONFIG.AutoLoad and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
                end
                LoadBtn.Text = "✅ LOADED!"
            else
                LoadBtn.Text = "⚠️ NOT FOUND"
            end
            task.delay(1, function() LoadBtn.Text = "📂 LOAD" end)
        end)

        DeleteBtn.MouseButton1Click:Connect(function()
            local fName = (FolderInput.Text == "") and "Configs" or FolderInput.Text
            local file = (FileNameInput.Text == "") and CONFIG.SaveFileName or FileNameInput.Text
            if not file:match("%.json$") then file = file .. ".json" end
            local filePath = CONFIG.BgFolder .. "/" .. fName .. "/" .. file

            if isfile(filePath) then
                local success = pcall(function() delfile(filePath) end)
                if success then
                    DeleteBtn.Text = "💀 DELETED!"
                    FileNameInput.Text = "" 
                    CONFIG.SaveFileName = "DefaultConfig"
                    DropBtn.Text = "   ▼  Select Existing Config..."
                    if RefreshFileList then RefreshFileList() end
                end
            else
                DeleteBtn.Text = "⚠️ NOT FOUND"
            end
            task.delay(1.5, function() DeleteBtn.Text = "🗑️ DELETE CONFIG" end)
        end)

        -- // 5. Toggle Auto Load
        local autoLoadFrame = Instance.new("TextButton", SettingPage)
        autoLoadFrame.Size = UDim2.new(0.95, 0, 0, 48) 
        autoLoadFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        autoLoadFrame.Text = ""
        autoLoadFrame.AutoButtonColor = false
        autoLoadFrame.ZIndex = 10
        autoLoadFrame.Active = true
        Instance.new("UICorner", autoLoadFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", autoLoadFrame).Color = Color3.fromRGB(60, 60, 65)

        local autoLoadTitle = Instance.new("TextLabel", autoLoadFrame)
        autoLoadTitle.Size = UDim2.new(1, -70, 1, 0)
        autoLoadTitle.Position = UDim2.new(0, 15, 0, 0)
        autoLoadTitle.BackgroundTransparency = 1
        autoLoadTitle.Text = "Auto Load Config"
        autoLoadTitle.TextColor3 = Color3.new(1, 1, 1)
        autoLoadTitle.Font = Enum.Font.GothamBold
        autoLoadTitle.TextSize = 14
        autoLoadTitle.TextXAlignment = Enum.TextXAlignment.Left
        autoLoadTitle.ZIndex = 11

        local autoSwitchBg = Instance.new("TextButton", autoLoadFrame)
        autoSwitchBg.Name = "AutoLoadSwitchBg"
        autoSwitchBg.Size = UDim2.new(0, 40, 0, 22)
        autoSwitchBg.Position = UDim2.new(1, -50, 0.5, -11)
        autoSwitchBg.BackgroundColor3 = CONFIG.AutoLoad and ColorOn or ColorOff
        autoSwitchBg.Text = ""
        autoSwitchBg.AutoButtonColor = false
        autoSwitchBg.ZIndex = 11
        Instance.new("UICorner", autoSwitchBg).CornerRadius = UDim.new(1, 0)

        local autoKnob = Instance.new("Frame", autoSwitchBg)
        autoKnob.Name = "AutoLoadKnob"
        autoKnob.Size = UDim2.new(0, 18, 0, 18)
        autoKnob.Position = CONFIG.AutoLoad and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        autoKnob.BackgroundColor3 = Color3.new(1, 1, 1)
        autoKnob.ZIndex = 12
        Instance.new("UICorner", autoKnob).CornerRadius = UDim.new(1, 0)

        autoSwitchBg.MouseButton1Click:Connect(function()
            CONFIG.AutoLoad = not CONFIG.AutoLoad
            CreateTween(autoSwitchBg, {BackgroundColor3 = CONFIG.AutoLoad and ColorOn or ColorOff}, 0.2)
            CreateTween(autoKnob, {Position = CONFIG.AutoLoad and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)
    end -- [ปิด RenderSettings]

    RenderSettings()
    
    TopSettingBtn.MouseButton1Click:Connect(function() 
        for _, v in pairs(PageArea:GetChildren()) do 
            if v:IsA("ScrollingFrame") or v:IsA("Frame") then
                if v.Visible then 
                    CreateTween(v, {Position = UDim2.new(0, 20, 0, 0)}, 0.2).Completed:Connect(function() v.Visible = false end) 
                end
            end
        end
        SettingPage.Visible = true
        CreateTween(SettingPage, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Sine)
    end)

    task.spawn(function()
        local path = CONFIG.BgFolder .. "/Configs/" .. CONFIG.SaveFileName .. ".json"
        if isfile(path) then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(path))
            end)
            if success and data and data.AutoLoad then
                LoadConfiguration(CONFIG.SaveFileName)
            end
        end
    end)

    return WindowAPI 
end 

return Veridianhub