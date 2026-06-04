-- Razor UI Library ULTIMATE
-- Pixel-perfect recreation of the provided image

local library = {
    flags = {},
    items = {},
    theme = {
        background = Color3.fromRGB(12, 12, 12),
        topbar = Color3.fromRGB(15, 15, 15),
        sector = Color3.fromRGB(18, 18, 18),
        accent = Color3.fromRGB(75, 120, 210),
        border = Color3.fromRGB(35, 35, 35),
        text = Color3.fromRGB(180, 180, 180),
        text_active = Color3.fromRGB(255, 255, 255),
        text_dark = Color3.fromRGB(90, 90, 90),
        font = Enum.Font.Code,
        fontsize = 13
    }
}

local uis = game:GetService("UserInputService")
local tweenservice = game:GetService("TweenService")
local textservice = game:GetService("TextService")
local coregui = game:GetService("CoreGui")

local function makeDraggable(obj, parent)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = parent.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    uis.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function library:CreateWindow(name, size, keybind)
    local window = {
        tabs = {},
        currentTab = nil,
        keybind = keybind or Enum.KeyCode.RightShift,
        visible = true
    }

    local screenGui = Instance.new("ScreenGui", coregui)
    screenGui.Name = "RazorUI_Final"
    screenGui.DisplayOrder = 100
    if syn then syn.protect_gui(screenGui) end
    window.screenGui = screenGui

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "Main"
    mainFrame.Size = UDim2.fromOffset(size.X, size.Y)
    mainFrame.Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2)
    mainFrame.BackgroundColor3 = library.theme.background
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = library.theme.border

    -- Triple border effect
    local b1 = Instance.new("Frame", mainFrame)
    b1.Size = UDim2.new(1, 2, 1, 2) ; b1.Position = UDim2.fromOffset(-1, -1) ; b1.BackgroundTransparency = 1 ; b1.BorderSizePixel = 1 ; b1.BorderColor3 = Color3.new(0,0,0) ; b1.ZIndex = 0
    local b2 = Instance.new("Frame", mainFrame)
    b2.Size = UDim2.new(1, 4, 1, 4) ; b2.Position = UDim2.fromOffset(-2, -2) ; b2.BackgroundTransparency = 1 ; b2.BorderSizePixel = 1 ; b2.BorderColor3 = library.theme.border ; b2.ZIndex = -1

    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 30) ; topBar.BackgroundColor3 = library.theme.topbar ; topBar.BorderSizePixel = 0 ; topBar.ZIndex = 2
    makeDraggable(topBar, mainFrame)

    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, 0, 1, 0) ; title.BackgroundTransparency = 1 ; title.Text = name ; title.TextColor3 = library.theme.text_dark ; title.Font = library.theme.font ; title.TextSize = 12 ; title.ZIndex = 3

    local tabContainer = Instance.new("Frame", mainFrame)
    tabContainer.Size = UDim2.new(1, 0, 0, 25) ; tabContainer.Position = UDim2.fromOffset(0, 30) ; tabContainer.BackgroundColor3 = library.theme.topbar ; tabContainer.BorderSizePixel = 0 ; tabContainer.ZIndex = 2
    local tabLayout = Instance.new("UIListLayout", tabContainer) ; tabLayout.FillDirection = Enum.FillDirection.Horizontal ; tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center ; tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local contentArea = Instance.new("Frame", mainFrame)
    contentArea.Size = UDim2.new(1, -20, 1, -65) ; contentArea.Position = UDim2.fromOffset(10, 60) ; contentArea.BackgroundTransparency = 1 ; contentArea.ZIndex = 2

    uis.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == window.keybind then
            window.visible = not window.visible
            mainFrame.Visible = window.visible
        end
    end)

    function window:CreateTab(tabName)
        local tab = {sectors = {}}
        local btn = Instance.new("TextButton", tabContainer)
        btn.Size = UDim2.new(0, 80, 1, 0) ; btn.BackgroundTransparency = 1 ; btn.Text = tabName ; btn.TextColor3 = library.theme.text_dark ; btn.Font = library.theme.font ; btn.TextSize = 13 ; btn.ZIndex = 3
        
        local indicator = Instance.new("Frame", btn)
        indicator.Size = UDim2.new(0.6, 0, 0, 2) ; indicator.Position = UDim2.new(0.2, 0, 1, -2) ; indicator.BackgroundColor3 = library.theme.accent ; indicator.BorderSizePixel = 0 ; indicator.Visible = false ; indicator.ZIndex = 4

        local frame = Instance.new("Frame", contentArea)
        frame.Size = UDim2.new(1, 0, 1, 0) ; frame.BackgroundTransparency = 1 ; frame.Visible = false ; frame.ZIndex = 3

        local left = Instance.new("ScrollingFrame", frame)
        left.Size = UDim2.new(0.5, -5, 1, 0) ; left.BackgroundTransparency = 1 ; left.ScrollBarThickness = 0 ; left.CanvasSize = UDim2.new(0,0,0,0) ; left.ZIndex = 4
        local leftLayout = Instance.new("UIListLayout", left) ; leftLayout.Padding = UDim.new(0, 15)
        leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() left.CanvasSize = UDim2.new(0,0,0,leftLayout.AbsoluteContentSize.Y + 5) end)

        local right = Instance.new("ScrollingFrame", frame)
        right.Size = UDim2.new(0.5, -5, 1, 0) ; right.Position = UDim2.new(0.5, 5, 0, 0) ; right.BackgroundTransparency = 1 ; right.ScrollBarThickness = 0 ; right.CanvasSize = UDim2.new(0,0,0,0) ; right.ZIndex = 4
        local rightLayout = Instance.new("UIListLayout", right) ; rightLayout.Padding = UDim.new(0, 15)
        rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() right.CanvasSize = UDim2.new(0,0,0,rightLayout.AbsoluteContentSize.Y + 5) end)

        function tab:Select()
            for _, t in pairs(window.tabs) do t.frame.Visible = false ; t.btn.TextColor3 = library.theme.text_dark ; t.indicator.Visible = false end
            frame.Visible = true ; btn.TextColor3 = library.theme.text_active ; indicator.Visible = true ; window.currentTab = tab
        end
        btn.MouseButton1Click:Connect(function() tab:Select() end)

        function tab:CreateSector(name, side)
            local sector = {}
            local parent = (side == "left" and left or right)
            local sFrame = Instance.new("Frame", parent) ; sFrame.Size = UDim2.new(1, 0, 0, 100) ; sFrame.BackgroundColor3 = library.theme.background ; sFrame.BorderSizePixel = 1 ; sFrame.BorderColor3 = library.theme.border ; sFrame.ZIndex = 5
            local sTitle = Instance.new("TextLabel", sFrame) ; sTitle.Text = " " .. name .. " " ; sTitle.Size = UDim2.fromOffset(textservice:GetTextSize(sTitle.Text, 12, library.theme.font, Vector2.new(200,20)).X, 15) ; sTitle.Position = UDim2.fromOffset(10, -8) ; sTitle.BackgroundColor3 = library.theme.background ; sTitle.TextColor3 = library.theme.accent ; sTitle.Font = library.theme.font ; sTitle.TextSize = 12 ; sTitle.ZIndex = 7
            local container = Instance.new("Frame", sFrame) ; container.Size = UDim2.new(1, -16, 1, -15) ; container.Position = UDim2.fromOffset(8, 10) ; container.BackgroundTransparency = 1 ; container.ZIndex = 6
            local layout = Instance.new("UIListLayout", container) ; layout.Padding = UDim.new(0, 6)
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() sFrame.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 20) end)

            function sector:AddToggle(text, default, callback, flag)
                local toggle = {value = default or false}
                local tBtn = Instance.new("TextButton", container) ; tBtn.Size = UDim2.new(1, 0, 0, 16) ; tBtn.BackgroundTransparency = 1 ; tBtn.Text = "" ; tBtn.ZIndex = 7
                local box = Instance.new("Frame", tBtn) ; box.Size = UDim2.fromOffset(10, 10) ; box.Position = UDim2.fromOffset(0, 3) ; box.BackgroundColor3 = toggle.value and library.theme.accent or library.theme.sector ; box.BorderSizePixel = 1 ; box.BorderColor3 = library.theme.border ; box.ZIndex = 8
                local label = Instance.new("TextLabel", tBtn) ; label.Size = UDim2.new(1, -15, 1, 0) ; label.Position = UDim2.fromOffset(15, 0) ; label.BackgroundTransparency = 1 ; label.Text = text ; label.TextColor3 = toggle.value and library.theme.text_active or library.theme.text ; label.Font = library.theme.font ; label.TextSize = 13 ; label.TextXAlignment = Enum.TextXAlignment.Left ; label.ZIndex = 8
                local function update() box.BackgroundColor3 = toggle.value and library.theme.accent or library.theme.sector ; label.TextColor3 = toggle.value and library.theme.text_active or library.theme.text ; if flag then library.flags[flag] = toggle.value end ; if callback then callback(toggle.value) end end
                tBtn.MouseButton1Click:Connect(function() toggle.value = not toggle.value ; update() end)
                function toggle:AddColorpicker(default, callback, flag)
                    local cp = Instance.new("TextButton", tBtn) ; cp.Size = UDim2.fromOffset(16, 8) ; cp.Position = UDim2.new(1, -16, 0.5, -4) ; cp.BackgroundColor3 = default or Color3.new(1,1,1) ; cp.BorderSizePixel = 1 ; cp.BorderColor3 = library.theme.border ; cp.Text = "" ; cp.ZIndex = 9
                    cp.MouseButton1Click:Connect(function() local c = Color3.new(math.random(), math.random(), math.random()) ; cp.BackgroundColor3 = c ; if callback then callback(c) end end)
                end
                function toggle:AddKeybind(default, callback, flag)
                    local kb = Instance.new("TextButton", tBtn) ; kb.Size = UDim2.fromOffset(40, 14) ; kb.Position = UDim2.new(1, -40, 0.5, -7) ; kb.BackgroundTransparency = 1 ; kb.Text = "[" .. (default and default.Name or "None") .. "]" ; kb.TextColor3 = library.theme.text_dark ; kb.Font = library.theme.font ; kb.TextSize = 11 ; kb.ZIndex = 9
                end
                return toggle
            end

            function sector:AddSlider(text, min, default, max, prec, callback, flag)
                local slider = {value = default or min}
                local sFrame = Instance.new("Frame", container) ; sFrame.Size = UDim2.new(1, 0, 0, 28) ; sFrame.BackgroundTransparency = 1 ; sFrame.ZIndex = 7
                local sLabel = Instance.new("TextLabel", sFrame) ; sLabel.Size = UDim2.new(1, -30, 0, 14) ; sLabel.Text = text ; sLabel.TextColor3 = library.theme.text ; sLabel.BackgroundTransparency = 1 ; sLabel.Font = library.theme.font ; sLabel.TextSize = 13 ; sLabel.TextXAlignment = Enum.TextXAlignment.Left ; sLabel.ZIndex = 8
                local bar = Instance.new("Frame", sFrame) ; bar.Size = UDim2.new(1, -24, 0, 3) ; bar.Position = UDim2.fromOffset(12, 18) ; bar.BackgroundColor3 = library.theme.sector ; bar.BorderSizePixel = 1 ; bar.BorderColor3 = library.theme.border ; bar.ZIndex = 8
                local fill = Instance.new("Frame", bar) ; fill.Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0) ; fill.BackgroundColor3 = library.theme.accent ; fill.BorderSizePixel = 0 ; fill.ZIndex = 9
                local valLabel = Instance.new("TextLabel", sFrame) ; valLabel.Size = UDim2.new(0, 30, 0, 14) ; valLabel.Position = UDim2.new(0.5, -15, 0, 16) ; valLabel.BackgroundTransparency = 1 ; valLabel.Text = tostring(slider.value) ; valLabel.TextColor3 = library.theme.text_dark ; valLabel.TextSize = 11 ; valLabel.Font = library.theme.font ; valLabel.ZIndex = 9
                local function update(val) slider.value = math.clamp(math.floor(val / prec + 0.5) * prec, min, max) ; fill.Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0) ; valLabel.Text = tostring(slider.value) ; if callback then callback(slider.value) end end
                local minus = Instance.new("TextButton", sFrame) ; minus.Size = UDim2.fromOffset(10, 10) ; minus.Position = UDim2.fromOffset(0, 15) ; minus.Text = "-" ; minus.TextColor3 = library.theme.text_dark ; minus.BackgroundColor3 = library.theme.sector ; minus.BorderSizePixel = 1 ; minus.BorderColor3 = library.theme.border ; minus.ZIndex = 9 ; minus.MouseButton1Click:Connect(function() update(slider.value - prec) end)
                local plus = Instance.new("TextButton", sFrame) ; plus.Size = UDim2.fromOffset(10, 10) ; plus.Position = UDim2.new(1, -10, 0, 15) ; plus.Text = "+" ; plus.TextColor3 = library.theme.text_dark ; plus.BackgroundColor3 = library.theme.sector ; plus.BorderSizePixel = 1 ; plus.BorderColor3 = library.theme.border ; plus.ZIndex = 9 ; plus.MouseButton1Click:Connect(function() update(slider.value + prec) end)
                return slider
            end

            function sector:AddDropdown(text, items, default, multichoice, callback, flag)
                local dd = {value = default}
                local dFrame = Instance.new("Frame", container) ; dFrame.Size = UDim2.new(1, 0, 0, 32) ; dFrame.BackgroundTransparency = 1 ; dFrame.ZIndex = 7
                local dLabel = Instance.new("TextLabel", dFrame) ; dLabel.Size = UDim2.new(1, 0, 0, 14) ; dLabel.Text = text ; dLabel.TextColor3 = library.theme.text ; dLabel.BackgroundTransparency = 1 ; dLabel.Font = library.theme.font ; dLabel.TextSize = 13 ; dLabel.TextXAlignment = Enum.TextXAlignment.Left ; dLabel.ZIndex = 8
                local btn = Instance.new("TextButton", dFrame) ; btn.Size = UDim2.new(1, 0, 0, 16) ; btn.Position = UDim2.fromOffset(0, 15) ; btn.BackgroundColor3 = library.theme.sector ; btn.BorderSizePixel = 1 ; btn.BorderColor3 = library.theme.border ; btn.Text = "  " .. tostring(default or "None") ; btn.TextColor3 = library.theme.text_dark ; btn.Font = library.theme.font ; btn.TextSize = 12 ; btn.TextXAlignment = Enum.TextXAlignment.Left ; btn.ZIndex = 8
                return dd
            end

            function sector:AddTextbox(text, default, callback, flag)
                local box = {value = default or ""}
                local tFrame = Instance.new("Frame", container) ; tFrame.Size = UDim2.new(1, 0, 0, 32) ; tFrame.BackgroundTransparency = 1 ; tFrame.ZIndex = 7
                local tLabel = Instance.new("TextLabel", tFrame) ; tLabel.Size = UDim2.new(1, 0, 0, 14) ; tLabel.Text = text ; tLabel.TextColor3 = library.theme.text ; tLabel.BackgroundTransparency = 1 ; tLabel.Font = library.theme.font ; tLabel.TextSize = 13 ; tLabel.TextXAlignment = Enum.TextXAlignment.Left ; tLabel.ZIndex = 8
                local input = Instance.new("TextBox", tFrame) ; input.Size = UDim2.new(1, 0, 0, 16) ; input.Position = UDim2.fromOffset(0, 15) ; input.BackgroundColor3 = library.theme.sector ; input.BorderSizePixel = 1 ; input.BorderColor3 = library.theme.border ; input.Text = box.value ; input.TextColor3 = library.theme.text ; input.Font = library.theme.font ; input.TextSize = 12 ; input.ZIndex = 8 ; input.ClearTextOnFocus = false
                input.FocusLost:Connect(function() box.value = input.Text ; if callback then callback(input.Text) end end)
                return {Get = function() return input.Text end}
            end

            function sector:AddButton(text, callback)
                local b = Instance.new("TextButton", container) ; b.Size = UDim2.new(1, 0, 0, 18) ; b.BackgroundColor3 = library.theme.sector ; b.BorderSizePixel = 1 ; b.BorderColor3 = library.theme.border ; b.Text = text ; b.TextColor3 = library.theme.text ; b.Font = library.theme.font ; b.TextSize = 13 ; b.ZIndex = 7 ; b.MouseButton1Click:Connect(callback)
                return b
            end

            return sector
        end

        tab.btn = btn ; tab.indicator = indicator ; tab.frame = frame
        table.insert(window.tabs, tab)
        if #window.tabs == 1 then tab:Select() end
        return tab
    end

    local cfgTab = window:CreateTab("Configs")
    local cfgSector = cfgTab:CreateSector("Configuration", "left")
    local cfgName = cfgSector:AddTextbox("Config Name", "", function() end)
    cfgSector:AddButton("Save Config", function() end)
    cfgSector:AddButton("Load Config", function() end)
    cfgSector:AddButton("Delete Config", function() end)
    local mSector = cfgTab:CreateSector("Menu", "right")
    mSector:AddButton("Unload", function() screenGui:Destroy() end)

    return window
end

function library:Notify(title, text, duration) print("Notify: " .. title .. " - " .. text) end

return library
