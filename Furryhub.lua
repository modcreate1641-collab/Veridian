local Veridianhub = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local CONFIG = {
    NavBtnColor = Color3.fromRGB(90, 132, 255),
    HoverColor = Color3.fromRGB(110, 152, 255),
    ClickColor = Color3.fromRGB(70, 112, 235),
    MainBgColor = Color3.fromRGB(35, 35, 40),
    NavPanelColor = Color3.fromRGB(45, 45, 50),
    SearchBgColor = Color3.fromRGB(76, 181, 191),
    DefaultFontSize = 12,
    KeybindEnabled = true,
    ToggleKey = Enum.KeyCode.K,
    BgFolder = "furlogo"
}

local function CreateTween(instance, properties, time, style, direction)
    local info = TweenService:Create(instance, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), properties)
    info:Play()
    return info
end

function Veridianhub:CreateWindow(HubName)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "VeridianHub_Official_Full"
    ScreenGui.IgnoreGuiInset = true

    -- Switched to CanvasGroup to fix GroupTransparency errors
    local MainFrame = Instance.new("CanvasGroup", ScreenGui)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Size = UDim2.new(0, 508, 0, 264)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = CONFIG.MainBgColor
    MainFrame.ClipsDescendants = true
    MainFrame.GroupTransparency = 0
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    local BgImage = Instance.new("ImageLabel", MainFrame)
    BgImage.Size = UDim2.new(1, 0, 1, 0); BgImage.BackgroundTransparency = 1; BgImage.ZIndex = 0; BgImage.ScaleType = Enum.ScaleType.Crop
    local BgCorner = Instance.new("UICorner", BgImage)
    BgCorner.CornerRadius = UDim.new(0, 10)
    
    local DarkOverlay = Instance.new("Frame", MainFrame)
    DarkOverlay.Size = UDim2.new(1, 0, 1, 0); DarkOverlay.BackgroundColor3 = Color3.new(0,0,0); DarkOverlay.BackgroundTransparency = 0.5; DarkOverlay.ZIndex = 1; DarkOverlay.Visible = false
    Instance.new("UICorner", DarkOverlay).CornerRadius = UDim.new(0, 10)

    local function ApplyAutoBackground()
        if isfolder(CONFIG.BgFolder) then
            for _, f in pairs(listfiles(CONFIG.BgFolder)) do
                local ext = f:lower()
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
    end
    ApplyAutoBackground()

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Thickness = 2; UIStroke.ZIndex = 5
    RunService.RenderStepped:Connect(function() UIStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

    local function makeDraggable(gui, targetFrame)
        local dragging, dragInput, dragStart, startPos
        gui.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not UserInputService:GetFocusedTextBox() then
                dragging = true; dragStart = input.Position; startPos = targetFrame and targetFrame.Position or gui.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        gui.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                local target = targetFrame or gui
                CreateTween(target, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05, Enum.EasingStyle.Linear)
            end
        end)
    end

    local isWindowOpen = true
    local function ToggleWindow(state)
        isWindowOpen = state
        if state then
            MainFrame.Visible = true
            -- เปลี่ยน BackgroundTransparency เป็น GroupTransparency
            CreateTween(MainFrame, {Size = UDim2.new(0, 508, 0, 264), GroupTransparency = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            -- เปลี่ยน BackgroundTransparency เป็น GroupTransparency
            local t = CreateTween(MainFrame, {Size = UDim2.new(0, 450, 0, 200), GroupTransparency = 1}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            t.Completed:Connect(function() if not isWindowOpen then MainFrame.Visible = false end end)
        end
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and CONFIG.KeybindEnabled and input.KeyCode == CONFIG.ToggleKey then 
        ToggleWindow(not isWindowOpen) 
    end
end)

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 90, 0, 40)
ToggleBtn.Position = UDim2.new(0, 335, 0, 25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 114, 255)
ToggleBtn.Text = "🐾On/Off :3"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleBtn)

makeDraggable(ToggleBtn)
makeDraggable(MainFrame)

ToggleBtn.MouseEnter:Connect(function() 
    CreateTween(ToggleBtn, {Size = UDim2.new(0, 95, 0, 45), BackgroundColor3 = Color3.fromRGB(220, 134, 255)}) 
end)
ToggleBtn.MouseLeave:Connect(function() 
    CreateTween(ToggleBtn, {Size = UDim2.new(0, 90, 0, 40), BackgroundColor3 = Color3.fromRGB(200, 114, 255)}) 
end)
ToggleBtn.MouseButton1Click:Connect(function() 
    ToggleWindow(not isWindowOpen) 
end)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, -6, 0, 45)
TopBar.Position = UDim2.new(0, 3, 0, 3)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 10

local HubLabel = Instance.new("TextLabel", TopBar)
HubLabel.Size = UDim2.new(0, 100, 1, 0)
HubLabel.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
HubLabel.Text = HubName
HubLabel.TextColor3 = Color3.new(1,1,1)
HubLabel.Font = Enum.Font.GothamBold
Instance.new("UICorner", HubLabel)

local SearchBox = Instance.new("TextBox", TopBar)
SearchBox.Size = UDim2.new(0, 260, 1, 0)
SearchBox.Position = UDim2.new(0, 106, 0, 0)
SearchBox.BackgroundColor3 = CONFIG.SearchBgColor
SearchBox.PlaceholderText = "Search..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.Font = Enum.Font.GothamSemibold
Instance.new("UICorner", SearchBox)

SearchBox.Focused:Connect(function() 
    CreateTween(SearchBox, {BackgroundColor3 = Color3.fromRGB(96, 201, 211)}, 0.2) 
end)
SearchBox.FocusLost:Connect(function() 
    CreateTween(SearchBox, {BackgroundColor3 = CONFIG.SearchBgColor}, 0.2) 
end)

local TopSettingBtn = Instance.new("TextButton", TopBar)
TopSettingBtn.Size = UDim2.new(0, 60, 1, 0)
TopSettingBtn.Position = UDim2.new(0, 372, 0, 0)
TopSettingBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
TopSettingBtn.Text = "⚙️"
TopSettingBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", TopSettingBtn)

TopSettingBtn.MouseEnter:Connect(function() 
    CreateTween(TopSettingBtn, {BackgroundColor3 = Color3.fromRGB(120, 120, 140)}) 
end)
TopSettingBtn.MouseLeave:Connect(function() 
    CreateTween(TopSettingBtn, {BackgroundColor3 = Color3.fromRGB(100, 100, 120)}) 
end)
 
    local ClosedBtn = Instance.new("TextButton", TopBar)
    ClosedBtn.Size = UDim2.new(0, 60, 1, 0); ClosedBtn.Position = UDim2.new(0, 438, 0, 0); ClosedBtn.BackgroundColor3 = Color3.fromRGB(129, 129, 129); ClosedBtn.Text = "Closed"; ClosedBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", ClosedBtn)
    ClosedBtn.MouseEnter:Connect(function() CreateTween(ClosedBtn, {BackgroundColor3 = Color3.fromRGB(231, 76, 60)}) end)
    ClosedBtn.MouseLeave:Connect(function() CreateTween(ClosedBtn, {BackgroundColor3 = Color3.fromRGB(129, 129, 129)}) end)
    ClosedBtn.MouseButton1Click:Connect(function() ToggleWindow(false) end)

    local NavSidePanel = Instance.new("Frame", MainFrame)
    NavSidePanel.Size = UDim2.new(0, 105, 1, -55); NavSidePanel.Position = UDim2.new(0, 3, 0, 55); NavSidePanel.BackgroundColor3 = CONFIG.NavPanelColor; NavSidePanel.BackgroundTransparency = 0.2; NavSidePanel.ZIndex = 2; Instance.new("UICorner", NavSidePanel)
    local NavArea = Instance.new("ScrollingFrame", NavSidePanel)
    NavArea.Size = UDim2.new(1, -4, 1, -4); NavArea.Position = UDim2.new(0, 2, 0, 2); NavArea.BackgroundTransparency = 1; NavArea.ZIndex = 3; NavArea.ScrollBarThickness = 0; NavArea.AutomaticCanvasSize = "Y"
    Instance.new("UIListLayout", NavArea).Padding = UDim.new(0, 5)

    local PageArea = Instance.new("Frame", MainFrame)
    PageArea.Size = UDim2.new(1, -115, 1, -55); PageArea.Position = UDim2.new(0, 110, 0, 55); PageArea.BackgroundTransparency = 1; PageArea.ZIndex = 3

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local input = SearchBox.Text:lower()
    for _, tabFrame in pairs(PageArea:GetChildren()) do
        if tabFrame:IsA("ScrollingFrame") and tabFrame.Visible then
            for _, item in pairs(tabFrame:GetChildren()) do
                -- Filter only valid UI elements
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
                                -- Fixed: Use BackgroundTransparency instead of GroupTransparency
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
    function WindowAPI:CreateTab(name, target, isAuto)
        local TabPage = Instance.new("ScrollingFrame", PageArea)
        TabPage.Size = UDim2.new(1, 0, 1, 0); TabPage.Position = UDim2.new(0, 20, 0, 0); TabPage.BackgroundTransparency = 1; TabPage.Visible = false; TabPage.ScrollBarThickness = 3; TabPage.AutomaticCanvasSize = "Y"
        TabPage.ZIndex = 11; TabPage.BackgroundTransparency = 1
        Instance.new("UIListLayout", TabPage).Padding = UDim.new(0, 8)

        local b = Instance.new("TextButton", NavArea)
        b.Size = UDim2.new(0, 97, 0, 34); b.BackgroundColor3 = CONFIG.NavBtnColor; b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.TextSize = CONFIG.DefaultFontSize; Instance.new("UICorner", b)
        b.ZIndex = 12
        
        b.MouseEnter:Connect(function() CreateTween(b, {BackgroundColor3 = CONFIG.HoverColor}) end)
        b.MouseLeave:Connect(function() CreateTween(b, {BackgroundColor3 = CONFIG.NavBtnColor}) end)
        
        local TabAPI = {}
        function TabAPI:CreateLabel(text)
            local lbl = Instance.new("TextLabel", TabPage)
            lbl.Size = UDim2.new(0.95, 0, 0, 25); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = Color3.new(0.9, 0.9, 0.9); lbl.Font = "GothamBold"; lbl.TextXAlignment = "Left"; lbl.ZIndex = 15
        end
        function TabAPI:CreateButton(cfg)
            local btn = Instance.new("TextButton", TabPage)
            btn.Size = UDim2.new(0.95, 0, 0, 35); btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65); btn.Text = "⚡ " .. cfg.Name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = "GothamBold"; Instance.new("UICorner", btn)
            btn.ZIndex = 15; btn.Active = true
            
            btn.MouseEnter:Connect(function() CreateTween(btn, {BackgroundColor3 = Color3.fromRGB(80, 80, 85)}) end)
            btn.MouseLeave:Connect(function() CreateTween(btn, {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}) end)
            btn.MouseButton1Down:Connect(function() CreateTween(btn, {Size = UDim2.new(0.92, 0, 0, 33)}) end)
            btn.MouseButton1Up:Connect(function() CreateTween(btn, {Size = UDim2.new(0.95, 0, 0, 35)}) end)
            btn.MouseButton1Click:Connect(function() pcall(cfg.Callback) end)
        end
        function TabAPI:CreateToggle(cfg)
            local s = cfg.Default or false
            local btn = Instance.new("TextButton", TabPage)
            local ColorOn = Color3.fromRGB(46, 204, 113)
            local ColorOff = Color3.fromRGB(231, 76, 60)
            btn.Size = UDim2.new(0.95, 0, 0, 35); btn.BackgroundColor3 = s and ColorOn or ColorOff
            btn.Text = cfg.Name .. " : " .. (s and "ON" or "OFF"); btn.TextColor3 = Color3.new(1,1,1); btn.Font = "GothamBold"; Instance.new("UICorner", btn)
            btn.ZIndex = 15; btn.Active = true
            
            btn.MouseButton1Down:Connect(function() CreateTween(btn, {Size = UDim2.new(0.92, 0, 0, 33)}) end)
            btn.MouseButton1Up:Connect(function() CreateTween(btn, {Size = UDim2.new(0.95, 0, 0, 35)}) end)
            btn.MouseButton1Click:Connect(function()
                s = not s
                CreateTween(btn, {BackgroundColor3 = s and ColorOn or ColorOff}, 0.2)
                btn.Text = cfg.Name .. " : " .. (s and "ON" or "OFF")
                pcall(cfg.Callback, s)
            end)
        end
        function TabAPI:CreateSlider(cfg)
            local dragging = false; local min, max = cfg.Min or 0, cfg.Max or 100; local val = cfg.Default or min
            local sf = Instance.new("Frame", TabPage); sf.Size = UDim2.new(0.95, 0, 0, 50); sf.BackgroundColor3 = Color3.fromRGB(50, 50, 55); Instance.new("UICorner", sf)
            sf.ZIndex = 15; sf.Active = true
            
            local t = Instance.new("TextLabel", sf); t.Name = "Title"; t.Size = UDim2.new(1, -20, 0, 20); t.Position = UDim2.new(0, 10, 0, 5); t.BackgroundTransparency = 1; t.Text = cfg.Name .. " : " .. val; t.TextColor3 = Color3.new(1,1,1); t.Font = "GothamBold"; t.TextXAlignment = "Left"; t.ZIndex = 16
            local bar = Instance.new("Frame", sf); bar.Size = UDim2.new(0.9, 0, 0, 8); bar.Position = UDim2.new(0.05, 0, 0, 32); bar.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Instance.new("UICorner", bar); bar.ZIndex = 16; bar.Active = true
            local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((val-min)/(max-min),0,1,0); fill.BackgroundColor3 = CONFIG.NavBtnColor; Instance.new("UICorner", fill); fill.ZIndex = 17
            
            local function up()
                local p = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                CreateTween(fill, {Size = UDim2.new(p,0,1,0)}, 0.1)
                val = math.floor(min + (p*(max-min))); t.Text = cfg.Name .. " : " .. val; pcall(cfg.Callback, val)
            end
            bar.InputBegan:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then dragging = true end end)
            UserInputService.InputEnded:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then dragging = false end end)
            RunService.RenderStepped:Connect(function() if dragging then up() end end)
        end
        function TabAPI:CreateDropdown(cfg)
            local open = false; local df = Instance.new("Frame", TabPage); df.Size = UDim2.new(0.95, 0, 0, 35); df.BackgroundColor3 = Color3.fromRGB(55, 55, 60); df.ClipsDescendants = true; Instance.new("UICorner", df); df.ZIndex = 15; df.Active = true
            local mb = Instance.new("TextButton", df); mb.Name = "MainBtn"; mb.Size = UDim2.new(1, 0, 0, 35); mb.BackgroundTransparency = 1; mb.Text = cfg.Name .. " 🔽"; mb.TextColor3 = Color3.new(1,1,1); mb.Font = "GothamBold"; mb.ZIndex = 16
            
            Instance.new("UIListLayout", df).Padding = UDim.new(0, 2)
            mb.MouseButton1Click:Connect(function() 
                open = not open; mb.Text = cfg.Name .. (open and " 🔼" or " 🔽")
                local targetSize = open and UDim2.new(0.95, 0, 0, 35+(#cfg.Options*32)) or UDim2.new(0.95, 0, 0, 35)
                CreateTween(df, {Size = targetSize}, 0.3, Enum.EasingStyle.Quart)
            end)
            for i, opt in pairs(cfg.Options) do
                local o = Instance.new("TextButton", df); o.Size = UDim2.new(1, 0, 0, 30); o.BackgroundColor3 = Color3.fromRGB(45, 45, 50); o.Text = opt; o.TextColor3 = Color3.new(0.8, 0.8, 0.8); Instance.new("UICorner", o); o.ZIndex = 17
                o.MouseEnter:Connect(function() CreateTween(o, {BackgroundColor3 = Color3.fromRGB(65, 65, 70)}) end)
                o.MouseLeave:Connect(function() CreateTween(o, {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}) end)
                o.MouseButton1Click:Connect(function() 
                    mb.Text = cfg.Name .. " : " .. opt .. " 🔽"; open = false
                    CreateTween(df, {Size = UDim2.new(0.95, 0, 0, 35)}, 0.3, Enum.EasingStyle.Quart)
                    pcall(cfg.Callback, opt) 
                end)
            end
        end

        local function OpenTab()
            SearchBox.Text = ""
            for _, v in pairs(PageArea:GetChildren()) do 
                if v.Visible then CreateTween(v, {BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0)}, 0.2).Completed:Connect(function() v.Visible = false end) end
            end
            TabPage.Visible = true
            CreateTween(TabPage, {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Sine)
            
            if not TabPage:FindFirstChild("HasRan") then
                if type(target) == "function" then target(TabPage, TabAPI)
                elseif type(target) == "string" and target:find("http") then
                    local lb = Instance.new("TextButton", TabPage); lb.Size = UDim2.new(0.95, 0, 0, 40); lb.BackgroundColor3 = Color3.fromRGB(60, 60, 65); lb.Text = "🐾 Load: " .. name; lb.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", lb); lb.ZIndex = 15
                    lb.MouseButton1Click:Connect(function() pcall(function() loadstring(game:HttpGet(target))() end) end)
                end
                Instance.new("BoolValue", TabPage).Name = "HasRan"
            end
        end
        b.MouseButton1Click:Connect(OpenTab)
        if isAuto then OpenTab() end
        return TabAPI
    end

    local SettingPage = Instance.new("ScrollingFrame", PageArea); SettingPage.Size = UDim2.new(1, 0, 1, 0); SettingPage.Position = UDim2.new(0, 20, 0, 0); SettingPage.BackgroundTransparency = 1; SettingPage.Visible = false; SettingPage.ScrollBarThickness = 3; SettingPage.AutomaticCanvasSize = "Y"; SettingPage.ZIndex = 11; SettingPage.BackgroundTransparency = 1
    local function RenderSettings()
        local l = Instance.new("TextLabel", SettingPage); l.Size = UDim2.new(1, 0, 0, 30); l.Text = "Control Panel"; l.BackgroundTransparency = 1; l.TextColor3 = Color3.new(1,1,1); l.Font = "GothamBold"; l.ZIndex = 15
        local kb = Instance.new("TextButton", SettingPage); kb.Size = UDim2.new(0.95, 0, 0, 40); kb.BackgroundColor3 = CONFIG.KeybindEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60); kb.Text = "Keybind (K): " .. (CONFIG.KeybindEnabled and "ENABLED" or "DISABLED"); kb.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", kb); kb.ZIndex = 15
        kb.MouseButton1Click:Connect(function() 
            CONFIG.KeybindEnabled = not CONFIG.KeybindEnabled
            CreateTween(kb, {BackgroundColor3 = CONFIG.KeybindEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)}, 0.2)
            kb.Text = "Keybind (K): " .. (CONFIG.KeybindEnabled and "ENABLED" or "DISABLED") 
        end)
    end
    RenderSettings()
    
    TopSettingBtn.MouseButton1Click:Connect(function() 
        for _, v in pairs(PageArea:GetChildren()) do 
            if v.Visible then CreateTween(v, {BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0)}, 0.2).Completed:Connect(function() v.Visible = false end) end
        end
        SettingPage.Visible = true
        CreateTween(SettingPage, {BackgroundTransparency = 0.8, Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Sine)
    end)

    return WindowAPI
end

return Veridianhub
