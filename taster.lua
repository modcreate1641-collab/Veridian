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
TopBar.Size = UDim2.new(1, -12, 0, 42) -- Spans fully from left to right with slight padding
TopBar.Position = UDim2.new(0, 6, 0, 6) -- Clean offset from the main frame borders
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Solid sleek dark base
TopBar.BackgroundTransparency = 0.3 -- Adjust this value whenever you want it semi-transparent
TopBar.ZIndex = 10

local TopBarCorner = Instance.new("UICorner", TopBar)
TopBarCorner.CornerRadius = UDim.new(0, 8) -- Smooth rounded edges for top bar setup

-- [[ ======================================================= ]] --
-- [[ HUB TITLE LABEL SETUP (CLEAN TEXT-ONLY STYLE) ]] --
-- [[ ======================================================= ]] --
local HubLabel = Instance.new("TextLabel", TopBar)
HubLabel.Name = "HubTitleLabel"
HubLabel.Size = UDim2.new(0, 150, 1, 0)
HubLabel.Position = UDim2.new(0, 12, 0, 0) -- Clean indentation from the left edge
HubLabel.BackgroundTransparency = 1 -- Removed the ugly green block background
HubLabel.Text = HubName or "Veridian Hub"
HubLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
HubLabel.Font = Enum.Font.GothamBold
HubLabel.TextSize = 14
HubLabel.TextXAlignment = Enum.TextXAlignment.Left
HubLabel.TextYAlignment = Enum.TextYAlignment.Center
HubLabel.ZIndex = 11

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
NavSidePanel.Size = UDim2.new(0, 105, 1, -55)
NavSidePanel.Position = UDim2.new(0, 3, 0, 55)
NavSidePanel.BackgroundColor3 = CONFIG.NavPanelColor
NavSidePanel.BackgroundTransparency = 0.5 -- ค่าเริ่มต้นตอนเปิด
NavSidePanel.ZIndex = 2
Instance.new("UICorner", NavSidePanel)

local EditorTriggerBtn = Instance.new("TextButton", NavSidePanel)
EditorTriggerBtn.Name = "EditorOpenTriggerButton"EditorTriggerBtn.Size = UDim2.new(1, -8, 0, 55)
EditorTriggerBtn.Position = UDim2.new(0, 4, 1, -49)
EditorTriggerBtn.BackgroundColor3 = CONFIG.NavBtnColor
EditorTriggerBtn.Text = "CODE EDITOR"
EditorTriggerBtn.TextColor3 = Color3.new(1, 1, 1)
EditorTriggerBtn.Font = Enum.Font.GothamBold
EditorTriggerBtn.TextSize = 11
EditorTriggerBtn.ZIndex = 5
Instance.new("UICorner", EditorTriggerBtn)

local InGameEditorFrame = Instance.new("Frame", MainFrame)
InGameEditorFrame.Name = "VeridianCoreCodeEditor"
InGameEditorFrame.Size = UDim2.new(1, -125, 1, -65)
InGameEditorFrame.Position = UDim2.new(0, 115, 0, 55)
InGameEditorFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
InGameEditorFrame.Visible = false
InGameEditorFrame.ZIndex = 50
Instance.new("UICorner", InGameEditorFrame)

local EditorStroke = Instance.new("UIStroke", InGameEditorFrame)
EditorStroke.Thickness = 1.5
EditorStroke.Color = CONFIG.NavBtnColor
EditorStroke.ZIndex = 51

local EditorTopBar = Instance.new("Frame", InGameEditorFrame)
EditorTopBar.Size = UDim2.new(1, 0, 0, 32)
EditorTopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
EditorTopBar.ZIndex = 52
Instance.new("UICorner", EditorTopBar)

local LocalSearchBox = Instance.new("TextBox", EditorTopBar)
LocalSearchBox.Size = UDim2.new(0, 180, 1, -6)
LocalSearchBox.Position = UDim2.new(0, 8, 0, 3)
LocalSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
LocalSearchBox.PlaceholderText = "Find line (Press Enter)"
LocalSearchBox.Text = ""
LocalSearchBox.TextColor3 = Color3.new(1, 1, 1)
LocalSearchBox.Font = Enum.Font.GothamSemibold
LocalSearchBox.TextSize = 12
LocalSearchBox.TextXAlignment = Enum.TextXAlignment.Left
LocalSearchBox.ZIndex = 53
Instance.new("UICorner", LocalSearchBox)

local CodeTextBox = Instance.new("TextBox", InGameEditorFrame)
CodeTextBox.Size = UDim2.new(1, -16, 1, -44)
CodeTextBox.Position = UDim2.new(0, 8, 0, 38)
CodeTextBox.BackgroundTransparency = 1
CodeTextBox.ClearTextOnFocus = false
CodeTextBox.MultiLine = true
CodeTextBox.Text = "hello world"
CodeTextBox.TextColor3 = Color3.fromRGB(220, 220, 225)
CodeTextBox.Font = Enum.Font.Code
CodeTextBox.TextSize = 13
CodeTextBox.TextXAlignment = Enum.TextXAlignment.Left
CodeTextBox.TextYAlignment = Enum.TextYAlignment.Top
CodeTextBox.ZIndex = 53

EditorTriggerBtn.Activated:Connect(function()
    local targetState = not InGameEditorFrame.Visible
    InGameEditorFrame.Visible = targetState
    pcall(function()
        if PageArea then
            PageArea.Visible = not targetState
        end
    end)
end)

LocalSearchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local searchPattern = LocalSearchBox.Text:lower()
        if searchPattern == "" then 
            CodeTextBox.CursorPosition = 1
            CodeTextBox.SelectionStart = 1
            return 
        end
        local textSource = CodeTextBox.Text:lower()
        local startIdx = textSource:find(searchPattern, 1, true)
        if startIdx then
            CodeTextBox:CaptureFocus()
            CodeTextBox.CursorPosition = startIdx + #searchPattern
            CodeTextBox.SelectionStart = startIdx
        end
    end
end)

pcall(function()
    local RawUpdateTheme = WindowAPI.UpdateTheme
    WindowAPI.UpdateTheme = function(self, newColor)
        pcall(RawUpdateTheme, self, newColor)
        if EditorStroke then EditorStroke.Color = newColor end
        if EditorTriggerBtn then EditorTriggerBtn.BackgroundColor3 = newColor end
    end
end)

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
    -- โครงสร้างเดิมเป๊ะ แค่เสริมหล่อให้ TabPage
    local TabPage = Instance.new("ScrollingFrame", PageArea)
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.Position = UDim2.new(0, 20, 0, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.ScrollBarThickness = 2 -- ทำให้เส้นบางลง ดูแพงขึ้น
    TabPage.AutomaticCanvasSize = "Y"
    TabPage.ZIndex = 11
    Instance.new("UIListLayout", TabPage).Padding = UDim.new(0, 8)
    
    -- ยัด Padding ให้หน้าตาไม่เบียดขอบ
    local padding = Instance.new("UIPadding", TabPage)
    padding.PaddingTop = UDim.new(0, 4)

    local b = Instance.new("TextButton", NavArea)
    b.Size = UDim2.new(0, 97, 0, 34)
    b.BackgroundColor3 = CONFIG.NavBtnColor
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = CONFIG.DefaultFontSize
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.ZIndex = 12
    
    -- เส้นขอบปุ่มเมนูด้านซ้ายเพิ่มมิติ
    local bStroke = Instance.new("UIStroke", b)
    bStroke.Color = Color3.new(1, 1, 1)
    bStroke.Transparency = 0.8
    
    b.MouseEnter:Connect(function() 
        CreateTween(b, {BackgroundColor3 = CONFIG.HoverColor}) 
        CreateTween(bStroke, {Transparency = 0.4})
    end)
    b.MouseLeave:Connect(function() 
        CreateTween(b, {BackgroundColor3 = CONFIG.NavBtnColor}) 
        CreateTween(bStroke, {Transparency = 0.8})
    end)

    b.MouseButton1Click:Connect(function()
        for _, v in pairs(PageArea:GetChildren()) do
            if v:IsA("ScrollingFrame") or v:IsA("Frame") then v.Visible = false end
        end
        TabPage.Visible = true
    end)
    
    local TabAPI = {}
    
    function TabAPI:CreateLabel(text)
        -- อัปเกรด Label ให้มีพื้นหลังกล่องดำจางๆ ดูเป็นสัดส่วน (สไตล์โปรแกรมขาย)
        local frame = Instance.new("Frame", TabPage)
        frame.Size = UDim2.new(0.95, 0, 0, 28)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        frame.BackgroundTransparency = 0.6
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
        frame.ZIndex = 14
        
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = CONFIG.NavBtnColor or Color3.fromRGB(100, 100, 110)
        stroke.Transparency = 0.7

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -12, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.new(0.95, 0.95, 0.95)
        lbl.Font = "GothamBold"
        lbl.TextXAlignment = "Left"
        lbl.ZIndex = 15
    end
    
    function TabAPI:CreateButton(cfg)
        local btn = Instance.new("TextButton", TabPage)
        btn.Size = UDim2.new(0.95, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50) -- สีฐานให้เข้มขึ้นนิดนึง
        btn.Text = "⚡ " .. cfg.Name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = "GothamBold"
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        btn.ZIndex = 15
        btn.Active = true
        
        -- เพิ่มขอบเรืองแสงเวลากด/ชี้
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = CONFIG.NavBtnColor or Color3.new(1, 1, 1)
        stroke.Transparency = 0.7
        
        btn.MouseEnter:Connect(function() 
            CreateTween(btn, {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}) 
            CreateTween(stroke, {Transparency = 0.2})
        end)
        btn.MouseLeave:Connect(function() 
            CreateTween(btn, {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}) 
            CreateTween(stroke, {Transparency = 0.7})
        end)
        btn.MouseButton1Down:Connect(function() CreateTween(btn, {Size = UDim2.new(0.92, 0, 0, 33)}) end)
        btn.MouseButton1Up:Connect(function() CreateTween(btn, {Size = UDim2.new(0.95, 0, 0, 35)}) end)
        btn.MouseButton1Click:Connect(function() pcall(cfg.Callback) end)
    end
    
    function TabAPI:CreateToggle(cfg)
        local s = cfg.Default or false
        local ColorOn = Color3.fromRGB(46, 204, 113)
        local ColorOff = Color3.fromRGB(80, 80, 85)

        local btn = Instance.new("TextButton", TabPage)
        btn.Size = UDim2.new(0.95, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        btn.Text = ""
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        btn.ZIndex = 15
        
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = CONFIG.NavBtnColor or Color3.fromRGB(100, 100, 110)
        stroke.Transparency = 0.7

        local title = Instance.new("TextLabel", btn)
        title.Size = UDim2.new(1, -60, 1, 0)
        title.Position = UDim2.new(0, 12, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = cfg.Name
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 16

        local switchBg = Instance.new("Frame", btn)
        switchBg.Size = UDim2.new(0, 40, 0, 20)
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

        btn.MouseEnter:Connect(function() CreateTween(stroke, {Transparency = 0.2}) end)
        btn.MouseLeave:Connect(function() CreateTween(stroke, {Transparency = 0.7}) end)

        btn.MouseButton1Click:Connect(function()
            s = not s
            CreateTween(switchBg, {BackgroundColor3 = s and ColorOn or ColorOff}, 0.2)
            CreateTween(knob, {Position = s and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            pcall(cfg.Callback, s)
        end)
    end

    function TabAPI:CreateSlider(cfg)
        local dragging = false; local min, max = cfg.Min or 0, cfg.Max or 100; local val = cfg.Default or min
        local sf = Instance.new("Frame", TabPage)
        sf.Size = UDim2.new(0.95, 0, 0, 50)
        sf.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 5)
        sf.ZIndex = 15
        sf.Active = true
        
        local stroke = Instance.new("UIStroke", sf)
        stroke.Color = CONFIG.NavBtnColor or Color3.fromRGB(100, 100, 110)
        stroke.Transparency = 0.7
        
        local t = Instance.new("TextLabel", sf)
        t.Name = "Title"
        t.Size = UDim2.new(1, -20, 0, 20)
        t.Position = UDim2.new(0, 12, 0, 5)
        t.BackgroundTransparency = 1
        t.Text = cfg.Name .. " : " .. val
        t.TextColor3 = Color3.new(1,1,1)
        t.Font = "GothamBold"
        t.TextXAlignment = "Left"
        t.ZIndex = 16
        
        local bar = Instance.new("Frame", sf)
        bar.Size = UDim2.new(0.9, 0, 0, 6) -- ลดความหนาเส้นบาร์ให้ดูคมๆ
        bar.Position = UDim2.new(0.05, 0, 0, 34)
        bar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        Instance.new("UICorner", bar)
        bar.ZIndex = 16
        bar.Active = true
        
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((val-min)/(max-min),0,1,0)
        fill.BackgroundColor3 = CONFIG.NavBtnColor
        Instance.new("UICorner", fill)
        fill.ZIndex = 17
        
        sf.MouseEnter:Connect(function() CreateTween(stroke, {Transparency = 0.2}) end)
        sf.MouseLeave:Connect(function() CreateTween(stroke, {Transparency = 0.7}) end)

        local function up()
            local p = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            CreateTween(fill, {Size = UDim2.new(p,0,1,0)}, 0.1)
            val = math.floor(min + (p*(max-min)))
            t.Text = cfg.Name .. " : " .. val
            pcall(cfg.Callback, val)
        end
        bar.InputBegan:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then dragging = true end end)
        UserInputService.InputEnded:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then dragging = false end end)
        RunService.RenderStepped:Connect(function() if dragging then up() end end)
    end

    function TabAPI:CreateDropdown(cfg)
        local open = false
        local optionsCount = #cfg.Options
        local itemHeight = 32
        local maxDisplayItems = 2.5
        local closedSize = UDim2.new(0.95, 0, 0, 35)
        local openedSize = UDim2.new(0.95, 0, 0, 35 + math.min(optionsCount * itemHeight, maxDisplayItems * itemHeight))

        local df = Instance.new("Frame", TabPage)
        df.Name = "DropdownContainer"
        df.Size = closedSize
        df.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        df.ClipsDescendants = true
        df.ZIndex = 15
        Instance.new("UICorner", df).CornerRadius = UDim.new(0, 5)

        local stroke = Instance.new("UIStroke", df)
        stroke.Color = CONFIG.NavBtnColor or Color3.fromRGB(100, 100, 110)
        stroke.Transparency = 0.7

        local mb = Instance.new("TextButton", df)
        mb.Name = "MainBtn"
        mb.Size = UDim2.new(1, 0, 0, 35)
        mb.BackgroundTransparency = 1
        mb.Text = "  " .. cfg.Name
        mb.TextColor3 = Color3.new(1, 1, 1)
        mb.Font = Enum.Font.GothamBold
        mb.TextXAlignment = Enum.TextXAlignment.Left
        mb.ZIndex = 16

        local Arrow = Instance.new("TextLabel", mb)
        Arrow.Name = "Arrow"
        Arrow.Size = UDim2.new(0, 35, 0, 35)
        Arrow.Position = UDim2.new(1, -35, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "▼"
        Arrow.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        Arrow.TextSize = 12
        Arrow.ZIndex = 17

        local DropScroll = Instance.new("ScrollingFrame", df)
        DropScroll.Name = "DropScroll"
        DropScroll.Size = UDim2.new(1, -4, 1, -40)
        DropScroll.Position = UDim2.new(0, 2, 0, 38)
        DropScroll.BackgroundTransparency = 1
        DropScroll.ScrollBarThickness = 2
        DropScroll.ScrollBarImageColor3 = CONFIG.NavBtnColor or Color3.new(1,1,1)
        DropScroll.CanvasSize = UDim2.new(0, 0, 0, optionsCount * itemHeight)
        DropScroll.ZIndex = 16
        DropScroll.Visible = false

        local ListLayout = Instance.new("UIListLayout", DropScroll)
        ListLayout.Padding = UDim.new(0, 2)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

        df.MouseEnter:Connect(function() CreateTween(stroke, {Transparency = 0.2}) end)
        df.MouseLeave:Connect(function() CreateTween(stroke, {Transparency = 0.7}) end)

        mb.MouseButton1Click:Connect(function()
            open = not open
            local targetSize = open and openedSize or closedSize
            CreateTween(df, {Size = targetSize}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local arrowRot = open and 180 or 0
            CreateTween(Arrow, {Rotation = arrowRot}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            if open then
                DropScroll.Visible = true
            else
                task.delay(0.2, function() if not open then DropScroll.Visible = false end end)
            end
        end)

        for i, opt in pairs(cfg.Options) do
            local o = Instance.new("TextButton", DropScroll)
            o.Name = "Option_" .. opt
            o.Size = UDim2.new(1, -6, 0, 30)
            o.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            o.Text = opt
            o.TextColor3 = Color3.fromRGB(200, 200, 200)
            o.Font = Enum.Font.GothamSemibold
            o.ZIndex = 17
            Instance.new("UICorner", o).CornerRadius = UDim.new(0, 4)

            o.MouseEnter:Connect(function() CreateTween(o, {BackgroundColor3 = Color3.fromRGB(55, 55, 60)}, 0.2) end)
            o.MouseLeave:Connect(function() CreateTween(o, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}, 0.2) end)

            o.MouseButton1Click:Connect(function()
                mb.Text = "  " .. cfg.Name .. " : " .. opt
                open = false
                CreateTween(df, {Size = closedSize}, 0.3, Enum.EasingStyle.Quart)
                CreateTween(Arrow, {Rotation = 0}, 0.3)
                DropScroll.Visible = false
                pcall(cfg.Callback, opt)
            end)
        end
    end

    local function OpenTab()
        if SearchBox then SearchBox.Text = "" end
        for _, v in pairs(PageArea:GetChildren()) do 
            if v.Visible then CreateTween(v, {BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0)}, 0.2).Completed:Connect(function() v.Visible = false end) end
        end
        TabPage.Visible = true
        CreateTween(TabPage, {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Sine)
        
        if not TabPage:FindFirstChild("HasRan") then
            if type(target) == "function" then target(TabPage, TabAPI)
            elseif type(target) == "string" and target:find("http") then
                local lb = Instance.new("TextButton", TabPage)
                lb.Size = UDim2.new(0.95, 0, 0, 40)
                lb.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                lb.Text = "🐾 Load: " .. name
                lb.TextColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", lb)
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
        -- Dynamic text based on current configuration
        title.Text = "Keybind (" .. CONFIG.ToggleKey.Name .. ")"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = Enum.Font.GothamBold
        title.TextSize = CONFIG.DefaultFontSize
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 16

        -- Transformed from Frame to TextButton to isolate toggle clicks
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

        -- Independent Master Toggle Event Listener
        switchBg.MouseButton1Click:Connect(function()
            CONFIG.KeybindEnabled = not CONFIG.KeybindEnabled
            CreateTween(switchBg, {BackgroundColor3 = CONFIG.KeybindEnabled and ColorOn or ColorOff}, 0.2)
            CreateTween(knob, {Position = CONFIG.KeybindEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)

        -- Premium Garbage-Cleaned Keybind Selector Logic
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

        local HttpService = game:GetService("HttpService")
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
    end
    
    RenderSettings()
    
    TopSettingBtn.MouseButton1Click:Connect(function() 
        for _, v in pairs(PageArea:GetChildren()) do 
            if v.Visible then 
                CreateTween(v, {Position = UDim2.new(0, 20, 0, 0)}, 0.2).Completed:Connect(function() v.Visible = false end) 
            end
        end
        SettingPage.Visible = true
        CreateTween(SettingPage, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Sine)
    end)

    return WindowAPI
end 

return Veridianhub