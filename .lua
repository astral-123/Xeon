-- Razor UI Library Redesign
-- Highly accurate recreation of the provided image style

local library = {
    flags = {},
    items = {},
    theme = {
        background = Color3.fromRGB(12, 12, 12), -- Main window background
        topbar = Color3.fromRGB(15, 15, 15),     -- Top bar and tab container background
        sector = Color3.fromRGB(18, 18, 18),     -- Sector background, inactive toggle box, slider bar
        accent = Color3.fromRGB(75, 120, 210),   -- Accent color (blue)
        border = Color3.fromRGB(35, 35, 35),     -- Main borders
        inner_border = Color3.fromRGB(25, 25, 25), -- Inner border for main frame
        text = Color3.fromRGB(180, 180, 180),    -- Default text color
        text_active = Color3.fromRGB(255, 255, 255), -- Active text color
        text_dark = Color3.fromRGB(90, 90, 90),  -- Darker text for titles/secondary info
        font = Enum.Font.Code,
        fontsize = 13
    }
}

local uis = game:GetService("UserInputService")
local tweenservice = game:GetService("TweenService")
local textservice = game:GetService("TextService")
local coregui = game:GetService("CoreGui")
local httpservice = game:GetService("HttpService")

-- Helper function to make UI elements draggable
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

-- Helper function for keybind to text conversion
local function keybindToText(key)
    if key == Enum.KeyCode.None then return "None" end
    return key.Name
end

function library:CreateWindow(name, size, keybind)
    local window = {
        tabs = {},
        currentTab = nil,
        keybind = keybind or Enum.KeyCode.RightShift,
        visible = true,
        mainFrame = nil -- Store mainFrame for Unload button
    }

    local screenGui = Instance.new("ScreenGui", coregui)
    screenGui.Name = "RazorUI"
    if syn then syn.protect_gui(screenGui) end
    window.screenGui = screenGui

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "Main"
    mainFrame.Size = UDim2.fromOffset(size.X, size.Y)
    mainFrame.Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2)
    mainFrame.BackgroundColor3 = library.theme.background
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = library.theme.border
    window.mainFrame = mainFrame -- Assign to window object

    -- Inner border (matches image)
    local innerBorder = Instance.new("Frame", mainFrame)
    innerBorder.Size = UDim2.new(1, -2, 1, -2)
    innerBorder.Position = UDim2.fromOffset(1, 1)
    innerBorder.BackgroundTransparency = 1
    innerBorder.BorderSizePixel = 1
    innerBorder.BorderColor3 = library.theme.inner_border

    -- Top Bar
    local topBar = Instance.new("Frame", mainFrame)
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 25)
    topBar.BackgroundColor3 = library.theme.topbar
    topBar.BorderSizePixel = 0
    makeDraggable(topBar, mainFrame)

    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = library.theme.text_dark
    title.TextSize = 12
    title.Font = library.theme.font
    title.TextXAlignment = Enum.TextXAlignment.Center

    -- Tab Container
    local tabContainer = Instance.new("Frame", mainFrame)
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 25)
    tabContainer.Position = UDim2.fromOffset(0, 25)
    tabContainer.BackgroundColor3 = library.theme.topbar
    tabContainer.BorderSizePixel = 0

    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Padding = UDim.new(0, 5) -- Small padding between tabs

    -- Content Area
    local contentArea = Instance.new("Frame", mainFrame)
    contentArea.Name = "Content"
    contentArea.Size = UDim2.new(1, -10, 1, -55) -- Adjusted size to match image padding
    contentArea.Position = UDim2.fromOffset(5, 50) -- Adjusted position
    contentArea.BackgroundTransparency = 1

    uis.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == window.keybind then
            window.visible = not window.visible
            mainFrame.Visible = window.visible
        end
    end)

    function window:CreateTab(tabName)
        local tab = {button = nil, frame = nil}

        local tabButton = Instance.new("TextButton", tabContainer)
        tabButton.Size = UDim2.new(0, 70, 1, 0)
        tabButton.BackgroundTransparency = 1
        tabButton.Text = tabName
        tabButton.TextColor3 = library.theme.text_dark
        tabButton.TextSize = 13
        tabButton.Font = library.theme.font
        tab.button = tabButton

        local indicator = Instance.new("Frame", tabButton)
        indicator.Size = UDim2.new(0.6, 0, 0, 2)
        indicator.Position = UDim2.new(0.2, 0, 1, -2)
        indicator.BackgroundColor3 = library.theme.accent
        indicator.BorderSizePixel = 0
        indicator.Visible = false

        local tabFrame = Instance.new("Frame", contentArea)
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = false
        tab.frame = tabFrame

        local leftSide = Instance.new("ScrollingFrame", tabFrame)
        leftSide.Size = UDim2.new(0.5, -5, 1, 0)
        leftSide.BackgroundTransparency = 1
        leftSide.ScrollBarThickness = 0
        leftSide.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local leftLayout = Instance.new("UIListLayout", leftSide)
        leftLayout.Padding = UDim.new(0, 8) -- Padding between sectors
        leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            leftSide.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 10)
        end)

        local rightSide = Instance.new("ScrollingFrame", tabFrame)
        rightSide.Size = UDim2.new(0.5, -5, 1, 0)
        rightSide.Position = UDim2.fromOffset(0.5, 0) -- Position right side correctly
        rightSide.BackgroundTransparency = 1
        rightSide.ScrollBarThickness = 0
        rightSide.CanvasSize = UDim2.new(0, 0, 0, 0)

        local rightLayout = Instance.new("UIListLayout", rightSide)
        rightLayout.Padding = UDim.new(0, 8) -- Padding between sectors
        rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            rightSide.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 10)
        end)

        function tab:Select()
            for _, t in pairs(window.tabs) do
                t.frame.Visible = false
                t.button.TextColor3 = library.theme.text_dark
                t.button.indicator.Visible = false
            end
            tabFrame.Visible = true
            tabButton.TextColor3 = library.theme.text_active
            indicator.Visible = true
            window.currentTab = tab
        end

        tabButton.MouseButton1Click:Connect(function() tab:Select() end)

        function tab:CreateSector(sectorName, side)
            local sector = {}
            local parent = (side == "left" and leftSide or rightSide)

            local sectorFrame = Instance.new("Frame", parent)
            sectorFrame.Size = UDim2.new(1, 0, 0, 30)
            sectorFrame.BackgroundColor3 = library.theme.sector
            sectorFrame.BorderSizePixel = 1
            sectorFrame.BorderColor3 = library.theme.border

            local titleLabel = Instance.new("TextLabel", sectorFrame)
            titleLabel.Size = UDim2.new(0, textservice:GetTextSize(" " .. sectorName .. " ", library.theme.fontsize, library.theme.font, Vector2.new(200, 20)).X + 10, 0, 15)
            titleLabel.Position = UDim2.fromOffset(5, -8) -- Adjusted position to cut into the border
            titleLabel.BackgroundColor3 = library.theme.background -- Background to match main window
            titleLabel.Text = " " .. sectorName .. " "
            titleLabel.TextColor3 = library.theme.accent
            titleLabel.TextSize = library.theme.fontsize
            titleLabel.Font = library.theme.font
            titleLabel.TextXAlignment = Enum.TextXAlignment.Center

            local container = Instance.new("Frame", sectorFrame)
            container.Size = UDim2.new(1, -10, 1, -15) -- Adjusted padding
            container.Position = UDim2.fromOffset(5, 10)
            container.BackgroundTransparency = 1
            
            local layout = Instance.new("UIListLayout", container)
            layout.Padding = UDim.new(0, 5) -- Padding between items
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectorFrame.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 20)
            end)

            function sector:AddToggle(text, default, callback, flag)
                local toggle = {value = default or false}
                local btn = Instance.new("TextButton", container)
                btn.Size = UDim2.new(1, 0, 0, 16)
                btn.BackgroundTransparency = 1
                btn.Text = ""

                local box = Instance.new("Frame", btn)
                box.Size = UDim2.fromOffset(10, 10)
                box.Position = UDim2.fromOffset(0, 3)
                box.BackgroundColor3 = toggle.value and library.theme.accent or library.theme.sector
                box.BorderSizePixel = 1
                box.BorderColor3 = library.theme.border

                local label = Instance.new("TextLabel", btn)
                label.Size = UDim2.new(1, -15, 1, 0)
                label.Position = UDim2.fromOffset(15, 0)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = toggle.value and library.theme.text_active or library.theme.text
                label.TextSize = library.theme.fontsize
                label.Font = library.theme.font
                label.TextXAlignment = Enum.TextXAlignment.Left

                local function update()
                    box.BackgroundColor3 = toggle.value and library.theme.accent or library.theme.sector
                    label.TextColor3 = toggle.value and library.theme.text_active or library.theme.text
                    if flag then library.flags[flag] = toggle.value end
                    if callback then callback(toggle.value) end
                end

                btn.MouseButton1Click:Connect(function()
                    toggle.value = not toggle.value
                    update()
                end)

                function toggle:AddColorpicker(defaultColor, callbackFunc, flag)
                    local cpBtn = Instance.new("TextButton", btn)
                    cpBtn.Size = UDim2.fromOffset(16, 8)
                    cpBtn.Position = UDim2.new(1, -16, 0.5, -4)
                    cpBtn.BackgroundColor3 = defaultColor or Color3.new(1,1,1)
                    cpBtn.BorderSizePixel = 1
                    cpBtn.BorderColor3 = library.theme.border
                    cpBtn.Text = ""
                    cpBtn.MouseButton1Click:Connect(function()
                        -- Simplified color picker for this example, in a real scenario this would open a color picker UI
                        local r, g, b = math.random(), math.random(), math.random()
                        local newColor = Color3.new(r, g, b)
                        cpBtn.BackgroundColor3 = newColor
                        if flag then library.flags[flag] = newColor end
                        if callbackFunc then callbackFunc(newColor) end
                    end)
                end

                function toggle:AddKeybind(defaultKey, callbackFunc, flag)
                    local kbBtn = Instance.new("TextButton", btn)
                    kbBtn.Size = UDim2.fromOffset(40, 14)
                    kbBtn.Position = UDim2.new(1, -40, 0.5, -7)
                    kbBtn.BackgroundTransparency = 1
                    kbBtn.Text = "[" .. keybindToText(defaultKey or Enum.KeyCode.None) .. "]"
                    kbBtn.TextColor3 = library.theme.text_dark
                    kbBtn.TextSize = 11
                    kbBtn.Font = library.theme.font

                    kbBtn.MouseButton1Click:Connect(function()
                        kbBtn.Text = "[...]"
                        local connection
                        connection = uis.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                local newKey = input.KeyCode
                                kbBtn.Text = "[" .. keybindToText(newKey) .. "]"
                                if flag then library.flags[flag] = newKey end
                                if callbackFunc then callbackFunc(newKey) end
                                connection:Disconnect()
                            end
                        end)
                    end)
                end

                return toggle
            end

            function sector:AddSlider(text, min, default, max, prec, callback, flag)
                local slider = {value = default or min}
                local frame = Instance.new("Frame", container)
                frame.Size = UDim2.new(1, 0, 0, 28)
                frame.BackgroundTransparency = 1

                local label = Instance.new("TextLabel", frame)
                label.Size = UDim2.new(1, -30, 0, 14)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = library.theme.text
                label.TextSize = library.theme.fontsize
                label.Font = library.theme.font
                label.TextXAlignment = Enum.TextXAlignment.Left

                local valLabel = Instance.new("TextLabel", frame)
                valLabel.Size = UDim2.new(0, 30, 0, 14)
                valLabel.Position = UDim2.new(1, -30, 0, 0)
                valLabel.BackgroundTransparency = 1
                valLabel.Text = tostring(slider.value)
                valLabel.TextColor3 = library.theme.text_dark
                valLabel.TextSize = library.theme.fontsize - 2
                valLabel.Font = library.theme.font
                valLabel.TextXAlignment = Enum.TextXAlignment.Right

                local bar = Instance.new("Frame", frame)
                bar.Size = UDim2.new(1, -24, 0, 3)
                bar.Position = UDim2.fromOffset(12, 18)
                bar.BackgroundColor3 = library.theme.sector
                bar.BorderSizePixel = 1
                bar.BorderColor3 = library.theme.border

                local fill = Instance.new("Frame", bar)
                fill.Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0)
                fill.BackgroundColor3 = library.theme.accent
                fill.BorderSizePixel = 0

                local function updateSlider(newValue)
                    slider.value = math.clamp(newValue, min, max)
                    slider.value = math.floor(slider.value / prec + 0.5) * prec
                    fill.Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0)
                    valLabel.Text = tostring(slider.value)
                    if flag then library.flags[flag] = slider.value end
                    if callback then callback(slider.value) end
                end

                local sliding = false
                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        updateSlider(min + (max - min) * math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1))
                    end
                end)
                uis.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)
                uis.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(min + (max - min) * math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1))
                    end
                end)

                local minus = Instance.new("TextButton", frame)
                minus.Size = UDim2.fromOffset(10, 10)
                minus.Position = UDim2.fromOffset(0, 16)
                minus.BackgroundColor3 = library.theme.sector
                minus.BorderSizePixel = 1
                minus.BorderColor3 = library.theme.border
                minus.Text = "-" ; minus.TextColor3 = library.theme.text_dark ; minus.Font = library.theme.font ; minus.TextSize = 11
                minus.MouseButton1Click:Connect(function()
                    updateSlider(slider.value - prec)
                end)

                local plus = Instance.new("TextButton", frame)
                plus.Size = UDim2.fromOffset(10, 10)
                plus.Position = UDim2.new(1, -10, 0, 16)
                plus.BackgroundColor3 = library.theme.sector
                plus.BorderSizePixel = 1
                plus.BorderColor3 = library.theme.border
                plus.Text = "+" ; plus.TextColor3 = library.theme.text_dark ; plus.Font = library.theme.font ; plus.TextSize = 11
                plus.MouseButton1Click:Connect(function()
                    updateSlider(slider.value + prec)
                end)

                return slider
            end

            function sector:AddDropdown(text, items, default, multichoice, callback, flag)
                local dd = {value = default, open = false}
                local frame = Instance.new("Frame", container)
                frame.Size = UDim2.new(1, 0, 0, 32)
                frame.BackgroundTransparency = 1

                local label = Instance.new("TextLabel", frame)
                label.Size = UDim2.new(1, 0, 0, 14)
                label.Text = text ; label.TextColor3 = library.theme.text ; label.BackgroundTransparency = 1
                label.Font = library.theme.font ; label.TextSize = library.theme.fontsize ; label.TextXAlignment = Enum.TextXAlignment.Left

                local btn = Instance.new("TextButton", frame)
                btn.Size = UDim2.new(1, 0, 0, 16) ; btn.Position = UDim2.fromOffset(0, 15)
                btn.BackgroundColor3 = library.theme.sector ; btn.BorderSizePixel = 1 ; btn.BorderColor3 = library.theme.border
                btn.Text = "  " .. tostring(default or "None") ; btn.TextColor3 = library.theme.text_dark
                btn.Font = library.theme.font ; btn.TextSize = library.theme.fontsize - 1 ; btn.TextXAlignment = Enum.TextXAlignment.Left

                local arrow = Instance.new("TextLabel", btn)
                arrow.Size = UDim2.new(0, 16, 1, 0) ; arrow.Position = UDim2.new(1, -16, 0, 0)
                arrow.Text = "▼" ; arrow.TextColor3 = library.theme.text_dark ; arrow.BackgroundTransparency = 1
                arrow.Font = Enum.Font.SourceSans ; arrow.TextSize = 10 -- Use a standard font for arrow

                local list = Instance.new("Frame", window.screenGui) -- List is on ScreenGui to overlay
                list.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, 0)
                list.BackgroundColor3 = library.theme.sector
                list.BorderSizePixel = 1
                list.BorderColor3 = library.theme.border
                list.Visible = false
                list.ZIndex = 100

                local listLayout = Instance.new("UIListLayout", list)
                listLayout.Padding = UDim.new(0, 1)

                btn.MouseButton1Click:Connect(function()
                    dd.open = not dd.open
                    list.Visible = dd.open
                    list.Position = UDim2.fromOffset(btn.AbsolutePosition.X, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y)
                    list.Size = UDim2.fromOffset(btn.AbsoluteSize.X, #items * 18) -- Each item is 18px high
                end)

                for _, item in pairs(items) do
                    local itemBtn = Instance.new("TextButton", list)
                    itemBtn.Size = UDim2.new(1, 0, 0, 18)
                    itemBtn.BackgroundColor3 = library.theme.sector
                    itemBtn.BorderSizePixel = 0
                    itemBtn.Text = "  " .. item
                    itemBtn.TextColor3 = library.theme.text
                    itemBtn.TextSize = library.theme.fontsize - 1
                    itemBtn.Font = library.theme.font
                    itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                    itemBtn.ZIndex = 101

                    itemBtn.MouseButton1Click:Connect(function()
                        btn.Text = "  " .. item
                        dd.value = item
                        dd.open = false
                        list.Visible = false
                        if flag then library.flags[flag] = item end
                        if callback then callback(item) end
                    end)
                end

                return dd
            end

            function sector:AddTextbox(text, default, callback, flag)
                local box = {value = default or ""}
                local frame = Instance.new("Frame", container)
                frame.Size = UDim2.new(1, 0, 0, 32) ; frame.BackgroundTransparency = 1
                local label = Instance.new("TextLabel", frame)
                label.Size = UDim2.new(1, 0, 0, 14) ; label.Text = text ; label.TextColor3 = library.theme.text ; label.BackgroundTransparency = 1
                label.Font = library.theme.font ; label.TextSize = library.theme.fontsize ; label.TextXAlignment = Enum.TextXAlignment.Left
                local input = Instance.new("TextBox", frame)
                input.Size = UDim2.new(1, 0, 0, 16) ; input.Position = UDim2.fromOffset(0, 15)
                input.BackgroundColor3 = library.theme.sector ; input.BorderSizePixel = 1 ; input.BorderColor3 = library.theme.border
                input.Text = box.value ; input.TextColor3 = library.theme.text ; input.Font = library.theme.font ; input.TextSize = library.theme.fontsize - 1
                input.ClearTextOnFocus = false

                input.FocusLost:Connect(function()
                    box.value = input.Text
                    if flag then library.flags[flag] = box.value end
                    if callback then callback(box.value) end
                end)

                function box:Set(val)
                    box.value = val
                    input.Text = val
                    if callback then callback(val) end
                end
                function box:Get() return input.Text end

                return box
            end

            function sector:AddButton(text, callback)
                local btn = Instance.new("TextButton", container)
                btn.Size = UDim2.new(1, 0, 0, 18) ; btn.BackgroundColor3 = library.theme.sector
                btn.BorderSizePixel = 1 ; btn.BorderColor3 = library.theme.border
                btn.Text = text ; btn.TextColor3 = library.theme.text ; btn.Font = library.theme.font ; btn.TextSize = library.theme.fontsize
                btn.MouseButton1Click:Connect(callback)
                return btn
            end

            return sector
        end

        table.insert(window.tabs, tab)
        if #window.tabs == 1 then tab:Select() end
        return tab
    end

    -- Automatic Settings Tab
    local settings = window:CreateTab("Configs")
    local cfgSector = settings:CreateSector("Configuration", "left")
    local cfgName = cfgSector:AddTextbox("Config Name", "", function() end)
    cfgSector:AddButton("Save Config", function() print("Saved") end)
    cfgSector:AddButton("Load Config", function() print("Loaded") end)
    cfgSector:AddButton("Delete Config", function() print("Deleted") end)
    
    local menuSector = settings:CreateSector("Menu", "right")
    menuSector:AddButton("Unload", function()
        if window.mainFrame then
            window.mainFrame:Destroy()
            -- Also destroy the ScreenGui if it's the only child
            if window.screenGui and #window.screenGui:GetChildren() == 0 then
                window.screenGui:Destroy()
            end
        end
    end)

    return window
end

function library:Notify(title, text, duration)
    print("Razor Notify: " .. title .. " - " .. text)
    -- Implement a proper notification system here if needed, similar to the original library
end

return library
