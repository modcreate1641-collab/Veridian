local VeridianLib = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

--[[ Configuration (colors, keys, folders) ]]--
local CONFIG = {
    NavBtnColor = Color3.fromRGB(90, 132, 255),
    HoverColor = Color3.fromRGB(110, 152, 255),
    ClickColor = Color3.fromRGB(70, 112, 235),
    MainBgColor = Color3.fromRGB(35, 35, 40),
    NavPanelColor = Color3.fromRGB(45, 45, 50),
    SearchBgColor = Color3.fromRGB(76, 181, 191),
    ElementBg = Color3.fromRGB(45, 45, 50),
    ElementHover = Color3.fromRGB(55, 55, 60),
    ToggleOn = Color3.fromRGB(46, 204, 113),
    ToggleOff = Color3.fromRGB(231, 76, 60),
    DefaultFontSize = 12,
    KeybindEnabled = true,
    ToggleKey = Enum.KeyCode.K,
    BgFolder = "furlogo"
}

--[[ Tween helper ]]--
local function CreateTween(instance, properties, time, style, direction)
    local info = TweenService:Create(instance, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), properties)
    info:Play()
    return info
end

--[[ Window creation ]]--
function VeridianLib:CreateWindow(HubName)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "VeridianLib" .. HubName
    ScreenGui.IgnoreGuiInset = true

    local MainFrame = Instance.new("CanvasGroup", ScreenGui)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Size = UDim2.new(0, 508, 0, 300)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = CONFIG.MainBgColor
    MainFrame.ClipsDescendants = true
    MainFrame.GroupTransparency = 0
    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 10)

    --[[ Background image ]]--
    local BgImage = Instance.new("ImageLabel", MainFrame)
    BgImage.Size = UDim2.new(1, 0, 1, 0)
    BgImage.BackgroundTransparency = 1
    BgImage.ZIndex = 0
    BgImage.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", BgImage).CornerRadius = UDim.new(0, 10)

    --[[ Dark overlay for background visibility ]]--
    local DarkOverlay = Instance.new("Frame", MainFrame)
    DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
    DarkOverlay.BackgroundColor3 = Color3.new(0,0,0)
    DarkOverlay.BackgroundTransparency = 0.5
    DarkOverlay.ZIndex = 1
    DarkOverlay.Visible = false
    Instance.new("UICorner", DarkOverlay).CornerRadius = UDim.new(0, 10)

    --[[ Auto-load background from folder ]]--
    local function ApplyAutoBackground()
        -- Check if all required functions exist
        if not isfolder or not listfiles then return end
        local success, err = pcall(function()
            if isfolder(CONFIG.BgFolder) then
                for _, f in pairs(listfiles(CONFIG.BgFolder)) do
                    local ext = string.lower(f)
                    if ext:find(".png") or ext:find(".jpg") or ext:find(".jpeg") then
                        local asset = (getcustomasset or getsynasset)
                        if asset then
                            BgImage.Image = asset(f)
                            DarkOverlay.Visible = true
                            MainFrame.BackgroundTransparency = 1
                            break
                        end
                    end
                end
            end
        end)
        if not success then warn("Background loading skipped: " .. tostring(err)) end
    end
    ApplyAutoBackground()

    --[[ Check if all required functions exist ]]--
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Thickness = 2
    UIStroke.ZIndex = 5
    
    local rainbowActive = true
    local rainbowConnection
    
    local function startRainbow()
        rainbowConnection = RunService.RenderStepped:Connect(function()
            if rainbowActive and UIStroke and UIStroke.Parent then
                local hue = (tick() % 5) / 5
                UIStroke.Color = Color3.fromHSV(hue, 1, 1)
            else
                if rainbowConnection then
                    rainbowConnection:Disconnect()
                end
            end
        end)
    end
    task.spawn(startRainbow)

    --[[ Dragging logic ]]--
    local function makeDraggable(gui, targetFrame)
        local dragging, dragInput, dragStart, startPos
        gui.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not UserInputService:GetFocusedTextBox() then
                dragging = true
                dragStart = input.Position
                startPos = targetFrame and targetFrame.Position or gui.Position
                
                local connection
                connection = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        connection:Disconnect()
                    end
                end)
            end
        end)

        gui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging and gui.Visible then
                local delta = input.Position - dragStart
                local target = targetFrame or gui
                CreateTween(target, {
                    Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                }, 0.05, Enum.EasingStyle.Linear)
            end
        end)
    end

    makeDraggable(MainFrame)

    --[[ Resize handle ]]--
    local ResizeHandle = Instance.new("Frame", MainFrame)
    ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
    ResizeHandle.AnchorPoint = Vector2.new(1, 1)
    ResizeHandle.Position = UDim2.new(1, 0, 1, 0)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.ZIndex = 10
    local resizeIcon = Instance.new("ImageLabel", ResizeHandle)
    resizeIcon.Size = UDim2.new(0.8, 0, 0.8, 0)
    resizeIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
    resizeIcon.BackgroundTransparency = 1
    resizeIcon.Image = "rbxassetid://8168490087" -- subtle resize indicator
    resizeIcon.ZIndex = 11

    local function resizeWindow()
        local dragging = false
        ResizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
                local mousePos = UserInputService:GetMouseLocation()
                local delta = mousePos - MainFrame.AbsolutePosition
                local minW, minH = 400, 250
                local newW = math.max(minW, delta.X)
                local newH = math.max(minH, delta.Y)
                CreateTween(MainFrame, {Size = UDim2.new(0, newW, 0, newH)}, 0.05, Enum.EasingStyle.Linear)
            end
        end)
    end
    resizeWindow()

    --[[ Toggle visibility with keybind ]]--
    local isWindowOpen = true
    local function ToggleWindow(state)
        isWindowOpen = state
        if state then
            MainFrame.Visible = true
            CreateTween(MainFrame, {GroupTransparency = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            local t = CreateTween(MainFrame, {GroupTransparency = 1}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            t.Completed:Connect(function()
                if not isWindowOpen then
                    MainFrame.Visible = false
                end
            end)
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and CONFIG.KeybindEnabled and input.KeyCode == CONFIG.ToggleKey then
            ToggleWindow(not isWindowOpen)
        end
    end)

    --[[ [ Top bar ] --]]
    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, -10, 0, 45)
    TopBar.Position = UDim2.new(0, 5, 0, 5)
    TopBar.BackgroundTransparency = 1
    TopBar.ZIndex = 10

    local HubLabel = Instance.new("TextLabel", TopBar)
    HubLabel.Size = UDim2.new(0, 100, 1, 0)
    HubLabel.Position = UDim2.new(0, 0, 0, 0)
    HubLabel.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
    HubLabel.Text = HubName
    HubLabel.TextColor3 = Color3.new(1,1,1)
    HubLabel.Font = Enum.Font.GothamBold
    HubLabel.TextSize = 14
    --[[ Capsule Corner for HubLabel ]]--
    local HubCorner = Instance.new("UICorner", HubLabel)
    HubCorner.CornerRadius = UDim.new(1, 0)

    local SearchBox = Instance.new("TextBox", TopBar)
    SearchBox.Size = UDim2.new(1, -230, 1, 0)
    SearchBox.Position = UDim2.new(0, 110, 0, 0)
    SearchBox.BackgroundColor3 = CONFIG.SearchBgColor
    SearchBox.PlaceholderText = "Search..."
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.new(1,1,1)
    SearchBox.Font = Enum.Font.GothamSemibold
    SearchBox.TextSize = 14
    SearchBox.ZIndex = 11
    --[[ Capsule Corner for SearchBox ]]--
    local SearchCorner = Instance.new("UICorner", SearchBox)
    SearchCorner.CornerRadius = UDim.new(1, 0)

    SearchBox.Focused:Connect(function()
        CreateTween(SearchBox, {BackgroundColor3 = Color3.fromRGB(96, 201, 211)}, 0.2)
    end)
    SearchBox.FocusLost:Connect(function()
        CreateTween(SearchBox, {BackgroundColor3 = CONFIG.SearchBgColor}, 0.2)
    end)

    local SettingsBtn = Instance.new("TextButton", TopBar)
    SettingsBtn.Size = UDim2.new(0, 60, 1, 0)
    SettingsBtn.Position = UDim2.new(1, -125, 0, 0)
    SettingsBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    SettingsBtn.Text = "⚙️"
    SettingsBtn.TextColor3 = Color3.new(1,1,1)
    SettingsBtn.TextSize = 18
    Instance.new("UICorner", SettingsBtn)
    SettingsBtn.ZIndex = 11
    SettingsBtn.MouseEnter:Connect(function()
        CreateTween(SettingsBtn, {BackgroundColor3 = Color3.fromRGB(120, 120, 140)})
    end)
    SettingsBtn.MouseLeave:Connect(function()
        CreateTween(SettingsBtn, {BackgroundColor3 = Color3.fromRGB(100, 100, 120)})
    end)

    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 60, 1, 0)
    CloseBtn.Position = UDim2.new(1, -60, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(129, 129, 129)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.TextSize = 18
    Instance.new("UICorner", CloseBtn)
    CloseBtn.ZIndex = 11
    CloseBtn.MouseEnter:Connect(function()
        CreateTween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(231, 76, 60)})
    end)
    CloseBtn.MouseLeave:Connect(function()
        CreateTween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(129, 129, 129)})
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ToggleWindow(false)
    end)

    --[[ Navigation side panel ]]--
    local NavSidePanel = Instance.new("Frame", MainFrame)
    NavSidePanel.Size = UDim2.new(0, 105, 1, -60)
    NavSidePanel.Position = UDim2.new(0, 5, 0, 55)
    NavSidePanel.BackgroundColor3 = CONFIG.NavPanelColor
    NavSidePanel.BackgroundTransparency = 0.3
    NavSidePanel.ZIndex = 3
    Instance.new("UICorner", NavSidePanel)

    local NavScroll = Instance.new("ScrollingFrame", NavSidePanel)
    NavScroll.Size = UDim2.new(1, -6, 1, -6)
    NavScroll.Position = UDim2.new(0, 3, 0, 3)
    NavScroll.BackgroundTransparency = 1
    NavScroll.ZIndex = 4
    NavScroll.ScrollBarThickness = 0
    NavScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local NavLayout = Instance.new("UIListLayout", NavScroll)
    NavLayout.Padding = UDim.new(0, 5)

    --[[ Main pages container ]]--
    local PageArea = Instance.new("Frame", MainFrame)
    PageArea.Size = UDim2.new(1, -120, 1, -60)
    PageArea.Position = UDim2.new(0, 115, 0, 55)
    PageArea.BackgroundTransparency = 1
    PageArea.ZIndex = 3

    --[[ Global keybinds array ]]--
    local globalKeybinds = {}
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for _, bind in pairs(globalKeybinds) do
            if input.KeyCode == bind.Key and bind.Enabled then
                pcall(bind.Callback)
            end
        end
    end)

    --[[ Search functionality (includes NoteContent) ]]--
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for _, tabFrame in pairs(PageArea:GetChildren()) do
            if tabFrame:IsA("ScrollingFrame") and tabFrame.Visible then
                for _, item in pairs(tabFrame:GetChildren()) do
                    local found = false
                    if item:IsA("TextButton") or item:IsA("TextLabel") then
                        if item.Text:lower():find(query) then found = true end
                    elseif item:IsA("Frame") then
                        local title = item:FindFirstChild("Title")
                        if title and title:IsA("TextLabel") and title.Text:lower():find(query) then found = true end
                        local main = item:FindFirstChild("MainBtn")
                        if main and main:IsA("TextButton") and main.Text:lower():find(query) then found = true end
                        local note = item:FindFirstChild("NoteContent")
                        if note and note:IsA("TextBox") and note.Text:lower():find(query) then found = true end
                    end
                    if found then
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
    end)

    --[[ Window API ]]--
    local WindowAPI = {}
    function WindowAPI:CreateTab(name, content, isAuto)
        local TabScrolling = Instance.new("ScrollingFrame", PageArea)
        TabScrolling.Size = UDim2.new(1, 0, 1, 0)
        TabScrolling.Position = UDim2.new(0, 10, 0, 0)
        TabScrolling.BackgroundTransparency = 0.1
        TabScrolling.Visible = false
        TabScrolling.ScrollBarThickness = 3
        TabScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabScrolling.ZIndex = 11
        local TabLayout = Instance.new("UIListLayout", TabScrolling)
        TabLayout.Padding = UDim.new(0, 10)
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local TabButton = Instance.new("TextButton", NavScroll)
        TabButton.Size = UDim2.new(0, 95, 0, 32)
        TabButton.BackgroundColor3 = CONFIG.NavBtnColor
        TabButton.Text = name
        TabButton.TextColor3 = Color3.new(1,1,1)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 14
        
        --[[ Added Capsule Corner for TabButton ]]--
        local TabBtnCorner = Instance.new("UICorner", TabButton)
        TabBtnCorner.CornerRadius = UDim.new(1, 0)
        
        TabButton.ZIndex = 12
        
        --[[ Tab opening logic Fixed Error at Line 410 ]]--
        local function OpenTab()
            if SearchBox then SearchBox.Text = "" end
            for _, otherTab in pairs(PageArea:GetChildren()) do
                if otherTab:IsA("ScrollingFrame") and otherTab ~= TabScrolling then
                    otherTab.Visible = false
                    otherTab.BackgroundTransparency = 0.1
                end
            end
            
            TabScrolling.Visible = true
            CreateTween(TabScrolling, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Sine)
            
            if not TabScrolling:FindFirstChild("Loaded") then
                local loadedTag = Instance.new("BoolValue", TabScrolling)
                loadedTag.Name = "Loaded"
                
                if type(content) == "function" then
                    local success, err = pcall(function()
                        content(TabAPI)
                    end)
                    if not success then warn("Veridian UI: Error in Tab '"..name.."': "..tostring(err)) end
                elseif type(content) == "string" and content:find("http") then
                    local success, err = pcall(function()
                        loadstring(game:HttpGet(content))()
                    end)
                    if not success then warn("Veridian UI: Failed to load URL for Tab '"..name.."': "..tostring(err)) end
                end
            end
        end

        TabButton.MouseEnter:Connect(function() CreateTween(TabButton, {BackgroundColor3 = CONFIG.HoverColor}) end)
        TabButton.MouseLeave:Connect(function() CreateTween(TabButton, {BackgroundColor3 = CONFIG.NavBtnColor}) end)
        TabButton.MouseButton1Click:Connect(OpenTab)

        local TabAPI = {}

        function TabAPI:CreateLabel(text)
            local lbl = Instance.new("TextLabel", TabScrolling)
            lbl.Size = UDim2.new(0.95, 0, 0, 25)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextSize = 14
            lbl.ZIndex = 15
            return lbl
        end

        function TabAPI:CreateButton(cfg)
            local btn = Instance.new("TextButton", TabScrolling)
            btn.Size = UDim2.new(0.95, 0, 0, 35)
            btn.BackgroundColor3 = CONFIG.ElementBg
            btn.Text = "⚡  " .. (cfg.Name or "Button")
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            
            --[[ Added Capsule Corner for Button ]]--
            local BtnCorner = Instance.new("UICorner", btn)
            BtnCorner.CornerRadius = UDim.new(1, 0)
            
            btn.ZIndex = 15
            btn.AutoButtonColor = false
            btn.MouseEnter:Connect(function() CreateTween(btn, {BackgroundColor3 = CONFIG.ElementHover}) end)
            btn.MouseLeave:Connect(function() CreateTween(btn, {BackgroundColor3 = CONFIG.ElementBg}) end)
            btn.MouseButton1Down:Connect(function() CreateTween(btn, {Size = UDim2.new(0.92, 0, 0, 33)}) end)
            btn.MouseButton1Up:Connect(function() CreateTween(btn, {Size = UDim2.new(0.95, 0, 0, 35)}) end)
            btn.MouseButton1Click:Connect(function() 
                if cfg.Callback then pcall(cfg.Callback) end 
            end)
            return btn
        end

        function TabAPI:CreateToggle(cfg)
            local state = cfg.Default or false
            local btn = Instance.new("TextButton", TabScrolling)
            btn.Size = UDim2.new(0.95, 0, 0, 35)
            btn.BackgroundColor3 = state and CONFIG.ToggleOn or CONFIG.ToggleOff
            btn.Text = (cfg.Name or "Toggle") .. " : " .. (state and "🐾ON" or "OFF😐")
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            
            --[[ Added Capsule Corner for Toggle ]]--
            local ToggleCorner = Instance.new("UICorner", btn)
            ToggleCorner.CornerRadius = UDim.new(1, 0)
            
            btn.ZIndex = 15
            btn.AutoButtonColor = false
            btn.MouseButton1Down:Connect(function() CreateTween(btn, {Size = UDim2.new(0.92, 0, 0, 33)}) end)
            btn.MouseButton1Up:Connect(function() CreateTween(btn, {Size = UDim2.new(0.95, 0, 0, 35)}) end)
            btn.MouseButton1Click:Connect(function()
                state = not state
                CreateTween(btn, {BackgroundColor3 = state and CONFIG.ToggleOn or CONFIG.ToggleOff}, 0.2)
                btn.Text = (cfg.Name or "Toggle") .. " : " .. (state and "ON" or "OFF")
                if cfg.Callback then pcall(cfg.Callback, state) end
            end)
            return btn
        end

        if isAuto then task.spawn(OpenTab) end
        return TabAPI
    end

        function TabAPI:CreateSlider(cfg)
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            if min > max then min, max = max, min end
            local value = math.clamp(cfg.Default or min, min, max)
            
            local container = Instance.new("Frame", TabScrolling)
            container.Size = UDim2.new(0.95, 0, 0, 50)
            container.BackgroundColor3 = CONFIG.ElementBg
            container.ZIndex = 15
            
            --[[ Added Smooth Corner for Slider Container ]]--
            local SliderContCorner = Instance.new("UICorner", container)
            SliderContCorner.CornerRadius = UDim.new(0, 8)

            local title = Instance.new("TextLabel", container)
            title.Name = "Title"
            title.Size = UDim2.new(1, -20, 0, 20)
            title.Position = UDim2.new(0, 10, 0, 5)
            title.BackgroundTransparency = 1
            title.Text = (cfg.Name or "Slider") .. " : " .. value
            title.TextColor3 = Color3.new(1,1,1)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 14
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 16

            local bar = Instance.new("Frame", container)
            bar.Size = UDim2.new(0.9, 0, 0, 8)
            bar.Position = UDim2.new(0.05, 0, 0, 32)
            bar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            bar.ZIndex = 16
            
            --[[ Added Capsule Corner for Slider Bar ]]--
            local BarCorner = Instance.new("UICorner", bar)
            BarCorner.CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = CONFIG.NavBtnColor
            fill.ZIndex = 17
            
            --[[ Added Capsule Corner for Slider Fill ]]--
            local FillCorner = Instance.new("UICorner", fill)
            FillCorner.CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function updateFromMouse()
                if not bar or not bar.Parent then return end
                local mouseX = UserInputService:GetMouseLocation().X
                local barAbs = bar.AbsolutePosition.X
                local barWidth = bar.AbsoluteSize.X
                local percent = math.clamp((mouseX - barAbs) / barWidth, 0, 1)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                value = math.floor(min + percent * (max - min))
                title.Text = (cfg.Name or "Slider") .. " : " .. value
                if cfg.Callback then pcall(cfg.Callback, value) end
            end

            bar.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    dragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    dragging = false
                end
            end)
            RunService.RenderStepped:Connect(function()
                if dragging and container.Visible then updateFromMouse() end
            end)
            return container
        end

        function TabAPI:CreateDropdown(cfg)
            local options = type(cfg.Options) == "table" and cfg.Options or {"No Options"}
            local open = false
            local container = Instance.new("Frame", TabScrolling)
            container.Size = UDim2.new(0.95, 0, 0, 35)
            container.BackgroundColor3 = CONFIG.ElementBg
            container.ClipsDescendants = true
            container.ZIndex = 15
            
            --[[ Added Smooth Corner for Dropdown Container ]]--
            local DropContCorner = Instance.new("UICorner", container)
            DropContCorner.CornerRadius = UDim.new(0, 8)

            local mainBtn = Instance.new("TextButton", container)
            mainBtn.Name = "MainBtn"
            mainBtn.Size = UDim2.new(1, 0, 0, 35)
            mainBtn.BackgroundTransparency = 1
            mainBtn.Text = (cfg.Name or "Dropdown") .. "  🔽"
            mainBtn.TextColor3 = Color3.new(1,1,1)
            mainBtn.Font = Enum.Font.GothamBold
            mainBtn.TextSize = 14
            mainBtn.ZIndex = 16

            local listLayout = Instance.new("UIListLayout", container)
            listLayout.Padding = UDim.new(0, 2)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local function collapse()
                open = false
                container.ZIndex = 15
                mainBtn.Text = (cfg.Name or "Dropdown") .. "  🔽"
                CreateTween(container, {Size = UDim2.new(0.95, 0, 0, 35)}, 0.3, Enum.EasingStyle.Quart)
            end

            local function expand()
                open = true
                container.ZIndex = 50 -- ดันขึ้นมาข้างบนไม่ให้โดนอันอื่นบัง
                mainBtn.Text = (cfg.Name or "Dropdown") .. "  🔼"
                local targetHeight = 35 + (#options * 32) + (#options * 2)
                CreateTween(container, {Size = UDim2.new(0.95, 0, 0, targetHeight)}, 0.3, Enum.EasingStyle.Quart)
            end

            mainBtn.MouseButton1Click:Connect(function()
                if open then collapse() else expand() end
            end)

            for i, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton", container)
                optBtn.Size = UDim2.new(1, 0, 0, 30)
                optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                optBtn.Text = tostring(opt)
                optBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 14
                optBtn.ZIndex = 17
                optBtn.LayoutOrder = i
                
                --[[ Added Smooth Corner for Dropdown Options ]]--
                local OptBtnCorner = Instance.new("UICorner", optBtn)
                OptBtnCorner.CornerRadius = UDim.new(0, 6)
                
                optBtn.MouseEnter:Connect(function() CreateTween(optBtn, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}) end)
                optBtn.MouseLeave:Connect(function() CreateTween(optBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}) end)
                optBtn.MouseButton1Click:Connect(function()
                    mainBtn.Text = (cfg.Name or "Dropdown") .. " : " .. tostring(opt) .. "  🔽"
                    collapse()
                    if cfg.Callback then pcall(cfg.Callback, opt) end
                end)
            end
            return container
        end

        function TabAPI:CreateColorPicker(cfg)
            local color = typeof(cfg.Default) == "Color3" and cfg.Default or Color3.new(1,1,1)
            local container = Instance.new("Frame", TabScrolling)
            container.Size = UDim2.new(0.95, 0, 0, 40)
            container.BackgroundColor3 = CONFIG.ElementBg
            container.ClipsDescendants = true
            container.ZIndex = 15
            
            --[[ Added Smooth Corner for ColorPicker Container ]]--
            local CPContCorner = Instance.new("UICorner", container)
            CPContCorner.CornerRadius = UDim.new(0, 8)

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 0, 40)
            header.BackgroundTransparency = 1
            header.Text = (cfg.Name or "Color Picker") .. "  🎨"
            header.TextColor3 = Color3.new(1,1,1)
            header.Font = Enum.Font.GothamBold
            header.TextSize = 14
            header.ZIndex = 16

            local preview = Instance.new("Frame", header)
            preview.Size = UDim2.new(0, 25, 0, 25)
            preview.Position = UDim2.new(0, 10, 0.5, -12)
            preview.BackgroundColor3 = color
            preview.ZIndex = 17
            Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)

            local expanded = false
            local slidersFrame = Instance.new("Frame", container)
            slidersFrame.Size = UDim2.new(1, 0, 0, 110)
            slidersFrame.Position = UDim2.new(0, 0, 0, 42)
            slidersFrame.BackgroundTransparency = 1
            slidersFrame.Visible = false
            slidersFrame.ZIndex = 18

            local function buildSliders()
                for _, child in ipairs(slidersFrame:GetChildren()) do child:Destroy() end
                local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
                local function addSlider(label, defaultVal, component)
                    local frame = Instance.new("Frame", slidersFrame)
                    frame.Size = UDim2.new(1, -10, 0, 30)
                    frame.BackgroundTransparency = 1
                    frame.ZIndex = 19
                    local lbl = Instance.new("TextLabel", frame)
                    lbl.Size = UDim2.new(0, 20, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = label
                    lbl.TextColor3 = Color3.new(1,1,1)
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 12
                    lbl.ZIndex = 20
                    local bar = Instance.new("Frame", frame)
                    bar.Size = UDim2.new(1, -30, 0, 10)
                    bar.Position = UDim2.new(0, 25, 0.5, -5)
                    bar.BackgroundColor3 = Color3.fromRGB(30,30,35)
                    
                    --[[ Added Capsule Corner for ColorPicker Bar ]]--
                    local CPBarCorner = Instance.new("UICorner", bar)
                    CPBarCorner.CornerRadius = UDim.new(1, 0)
                    
                    bar.ZIndex = 19
                    local fill = Instance.new("Frame", bar)
                    fill.Size = UDim2.new(math.clamp(defaultVal/255, 0, 1), 0, 1, 0)
                    if label == "R" then fill.BackgroundColor3 = Color3.fromRGB(255,0,0)
                    elseif label == "G" then fill.BackgroundColor3 = Color3.fromRGB(0,255,0)
                    else fill.BackgroundColor3 = Color3.fromRGB(0,0,255) end
                    
                    --[[ Added Capsule Corner for ColorPicker Fill ]]--
                    local CPFillCorner = Instance.new("UICorner", fill)
                    CPFillCorner.CornerRadius = UDim.new(1, 0)
                    
                    fill.ZIndex = 20

                    local dragging = false
                    local function update(p)
                        fill.Size = UDim2.new(p, 0, 1, 0)
                        local newVal = math.floor(p * 255)
                        if component == "R" then r = newVal
                        elseif component == "G" then g = newVal
                        else b = newVal end
                        color = Color3.fromRGB(r, g, b)
                        preview.BackgroundColor3 = color
                        if cfg.Callback then pcall(cfg.Callback, color) end
                    end
                    bar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
                    end)
                    RunService.RenderStepped:Connect(function()
                        if dragging then
                            local mouseX = UserInputService:GetMouseLocation().X
                            local barAbs = bar.AbsolutePosition.X
                            local barWidth = bar.AbsoluteSize.X
                            local p = math.clamp((mouseX - barAbs) / barWidth, 0, 1)
                            update(p)
                        end
                    end)
                end
                local layout = Instance.new("UIListLayout", slidersFrame)
                layout.Padding = UDim.new(0, 5)
                addSlider("R", r, "R")
                addSlider("G", g, "G")
                addSlider("B", b, "B")
            end
            buildSliders()

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                slidersFrame.Visible = expanded
                container.ZIndex = expanded and 50 or 15
                local targetHeight = expanded and 160 or 40
                CreateTween(container, {Size = UDim2.new(0.95, 0, 0, targetHeight)}, 0.3, Enum.EasingStyle.Quart)
                if expanded then buildSliders() end
            end)
            return container
        end

        function TabAPI:CreateKeybind(cfg)
            local key = cfg.Default or Enum.KeyCode.Unknown
            local bindObj = {Key = key, Callback = cfg.Callback, Enabled = true}
            local container = Instance.new("Frame", TabScrolling)
            container.Size = UDim2.new(0.95, 0, 0, 35)
            container.BackgroundColor3 = CONFIG.ElementBg
            
            --[[ Added Smooth Corner for Keybind Container ]]--
            local KBContCorner = Instance.new("UICorner", container)
            KBContCorner.CornerRadius = UDim.new(0, 8)
            
            container.ZIndex = 15
            local btn = Instance.new("TextButton", container)
            btn.Name = "MainBtn"
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = (cfg.Name or "Keybind") .. " : " .. (key == Enum.KeyCode.Unknown and "..." or key.Name)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.ZIndex = 16
            local listening = false
            btn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                btn.Text = (cfg.Name or "Keybind") .. " : press a key..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        key = input.KeyCode
                        bindObj.Key = key
                        listening = false
                        btn.Text = (cfg.Name or "Keybind") .. " : " .. (key == Enum.KeyCode.Unknown and "..." or key.Name)
                        conn:Disconnect()
                    end
                end)
            end)
            table.insert(globalKeybinds, bindObj)
            return container
        end

        function TabAPI:CreateNote(cfg)
            local titleText = cfg.Title or "Note"
            local contentText = cfg.Content or ""
            local noteFrame = Instance.new("Frame", TabScrolling)
            noteFrame.Size = UDim2.new(0.95, 0, 0, 160)
            noteFrame.BackgroundColor3 = CONFIG.ElementBg
            noteFrame.ZIndex = 15
            
            --[[ Added Smooth Corner for Note Frame ]]--
            local NoteFrameCorner = Instance.new("UICorner", noteFrame)
            NoteFrameCorner.CornerRadius = UDim.new(0, 8)

            local titleLabel = Instance.new("TextLabel", noteFrame)
            titleLabel.Name = "Title"
            titleLabel.Size = UDim2.new(1, -10, 0, 24)
            titleLabel.Position = UDim2.new(0, 10, 0, 5)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = titleText
            titleLabel.TextColor3 = Color3.new(1,1,1)
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 14
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.ZIndex = 16

            local textBox = Instance.new("TextBox", noteFrame)
            textBox.Name = "NoteContent"
            textBox.Size = UDim2.new(1, -10, 1, -35)
            textBox.Position = UDim2.new(0, 5, 0, 30)
            textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            textBox.Text = contentText
            textBox.TextColor3 = Color3.new(1,1,1)
            textBox.Font = Enum.Font.Gotham
            textBox.TextSize = 14
            textBox.ClearTextOnFocus = false
            textBox.MultiLine = true
            textBox.TextWrapped = true
            textBox.TextXAlignment = Enum.TextXAlignment.Left
            textBox.TextYAlignment = Enum.TextYAlignment.Top
            textBox.ZIndex = 17
            
            --[[ Added Smooth Corner for Note TextBox ]]--
            local NoteTextCorner = Instance.new("UICorner", textBox)
            NoteTextCorner.CornerRadius = UDim.new(0, 8)

            textBox.FocusLost:Connect(function()
                if cfg.Callback then pcall(cfg.Callback, textBox.Text) end
            end)

            return noteFrame
        end

        local function OpenTab()
            if SearchBox then SearchBox.Text = "" end
            for _, otherTab in pairs(PageArea:GetChildren()) do
                if otherTab:IsA("ScrollingFrame") and otherTab ~= TabScrolling then
                    otherTab.Visible = false
                    otherTab.BackgroundTransparency = 1
                end
            end
            TabScrolling.Visible = true
            CreateTween(TabScrolling, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Sine)
            if not TabScrolling:FindFirstChild("Loaded") then
                local loadedTag = Instance.new("BoolValue", TabScrolling)
                loadedTag.Name = "Loaded"
                if type(content) == "function" then
                    pcall(function() content(TabAPI) end)
                elseif type(content) == "string" and content:find("http") then
                    TabAPI:CreateButton({
                        Name = "Load " .. (name or "Script"),
                        Callback = function()
                            local success, err = pcall(function()
                                loadstring(game:HttpGet(content))()
                            end)
                            if not success then warn("Veridian UI Error: "..tostring(err)) end
                        end
                    })
                end
            end
        end
        TabButton.MouseButton1Click:Connect(OpenTab)
        if isAuto then task.spawn(OpenTab) end
        return TabAPI
    end

    function WindowAPI:Destroy()
        rainbowActive = false
        if ScreenGui then ScreenGui:Destroy() end
        globalKeybinds = {}
    end

    function WindowAPI:Toggle()
        ToggleWindow(not isWindowOpen)
    end

    return WindowAPI
end

return VeridianLib
