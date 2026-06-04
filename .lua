-- EchoLabs Library Redesign
-- Inspired by the provided image style: Dark theme, Blue accents, Top Tabs

local library = {
    flags = {},
    items = {},
    theme = {
        background = Color3.fromRGB(15, 15, 15),
        accent = Color3.fromRGB(65, 140, 240),
        light_gray = Color3.fromRGB(30, 30, 30),
        dark_gray = Color3.fromRGB(20, 20, 20),
        text = Color3.fromRGB(200, 200, 200),
        text_dark = Color3.fromRGB(120, 120, 120),
        border = Color3.fromRGB(40, 40, 40),
        font = Enum.Font.Code,
        fontsize = 14
    }
}

local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local runservice = game:GetService("RunService")
local tweenservice = game:GetService("TweenService")
local textservice = game:GetService("TextService")
local coregui = game:GetService("CoreGui")
local httpservice = game:GetService("HttpService")

local player = players.LocalPlayer
local mouse = player:GetMouse()

-- Helper functions
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
    screenGui.Name = name
    if syn then syn.protect_gui(screenGui) end

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "Main"
    mainFrame.Size = UDim2.fromOffset(size.X, size.Y)
    mainFrame.Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2)
    mainFrame.BackgroundColor3 = library.theme.background
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = library.theme.border

    -- Top Bar
    local topBar = Instance.new("Frame", mainFrame)
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.BackgroundColor3 = library.theme.background
    topBar.BorderSizePixel = 0
    makeDraggable(topBar, mainFrame)

    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.fromOffset(10, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = library.theme.font
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Tab Container
    local tabContainer = Instance.new("Frame", mainFrame)
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Position = UDim2.fromOffset(0, 35)
    tabContainer.BackgroundColor3 = library.theme.background
    tabContainer.BorderSizePixel = 0

    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)

    local tabPadding = Instance.new("UIPadding", tabContainer)
    tabPadding.PaddingLeft = UDim.new(0, 10)

    -- Content Area
    local contentArea = Instance.new("Frame", mainFrame)
    contentArea.Name = "Content"
    contentArea.Size = UDim2.new(1, -20, 1, -75)
    contentArea.Position = UDim2.fromOffset(10, 65)
    contentArea.BackgroundTransparency = 1

    -- Keybind Toggle
    uis.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == window.keybind then
            window.visible = not window.visible
            mainFrame.Visible = window.visible
        end
    end)

    function window:CreateTab(tabName)
        local tab = {
            sectors = {left = {}, right = {}},
            button = nil,
            frame = nil
        }

        local tabButton = Instance.new("TextButton", tabContainer)
        tabButton.Size = UDim2.new(0, textservice:GetTextSize(tabName, 14, library.theme.font, Vector2.new(100, 100)).X + 20, 1, 0)
        tabButton.BackgroundTransparency = 1
        tabButton.Text = tabName
        tabButton.TextColor3 = library.theme.text_dark
        tabButton.TextSize = 14
        tabButton.Font = library.theme.font
        tab.button = tabButton

        local tabIndicator = Instance.new("Frame", tabButton)
        tabIndicator.Size = UDim2.new(1, 0, 0, 2)
        tabIndicator.Position = UDim2.new(0, 0, 1, -2)
        tabIndicator.BackgroundColor3 = library.theme.accent
        tabIndicator.BorderSizePixel = 0
        tabIndicator.Visible = false

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
        leftLayout.Padding = UDim.new(0, 15)
        leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            leftSide.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 10)
        end)

        local rightSide = Instance.new("ScrollingFrame", tabFrame)
        rightSide.Size = UDim2.new(0.5, -5, 1, 0)
        rightSide.Position = UDim2.new(0.5, 5, 0, 0)
        rightSide.BackgroundTransparency = 1
        rightSide.ScrollBarThickness = 0
        rightSide.CanvasSize = UDim2.new(0, 0, 0, 0)

        local rightLayout = Instance.new("UIListLayout", rightSide)
        rightLayout.Padding = UDim.new(0, 15)
        rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            rightSide.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 10)
        end)

        function tab:Select()
            for _, t in pairs(window.tabs) do
                t.frame.Visible = false
                t.button.TextColor3 = library.theme.text_dark
                t.button.Frame.Visible = false
            end
            tabFrame.Visible = true
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabIndicator.Visible = true
            window.currentTab = tab
        end

        tabButton.MouseButton1Click:Connect(function()
            tab:Select()
        end)

        function tab:CreateSector(sectorName, side)
            local sector = {
                frame = nil,
                container = nil
            }
            side = side or "left"
            local parent = (side == "left" and leftSide or rightSide)

            local sectorFrame = Instance.new("Frame", parent)
            sectorFrame.Size = UDim2.new(1, 0, 0, 30)
            sectorFrame.BackgroundColor3 = library.theme.dark_gray
            sectorFrame.BorderSizePixel = 1
            sectorFrame.BorderColor3 = library.theme.border
            sector.frame = sectorFrame

            local sectorTitle = Instance.new("TextLabel", sectorFrame)
            sectorTitle.Size = UDim2.new(1, -10, 0, 20)
            sectorTitle.Position = UDim2.fromOffset(5, -10)
            sectorTitle.BackgroundColor3 = library.theme.background
            sectorTitle.Text = " " .. sectorName .. " "
            sectorTitle.TextColor3 = library.theme.accent
            sectorTitle.TextSize = 13
            sectorTitle.Font = library.theme.font
            sectorTitle.Size = UDim2.fromOffset(textservice:GetTextSize(sectorTitle.Text, 13, library.theme.font, Vector2.new(200, 20)).X, 20)

            local sectorContainer = Instance.new("Frame", sectorFrame)
            sectorContainer.Size = UDim2.new(1, -10, 1, -15)
            sectorContainer.Position = UDim2.fromOffset(5, 10)
            sectorContainer.BackgroundTransparency = 1
            sector.container = sectorContainer

            local sectorLayout = Instance.new("UIListLayout", sectorContainer)
            sectorLayout.Padding = UDim.new(0, 8)
            sectorLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectorFrame.Size = UDim2.new(1, 0, 0, sectorLayout.AbsoluteContentSize.Y + 20)
            end)

            function sector:AddToggle(text, default, callback, flag)
                local toggle = {value = default or false}
                local toggleBtn = Instance.new("TextButton", sectorContainer)
                toggleBtn.Size = UDim2.new(1, 0, 0, 20)
                toggleBtn.BackgroundTransparency = 1
                toggleBtn.Text = ""

                local box = Instance.new("Frame", toggleBtn)
                box.Size = UDim2.fromOffset(14, 14)
                box.Position = UDim2.fromOffset(0, 3)
                box.BackgroundColor3 = library.theme.light_gray
                box.BorderSizePixel = 1
                box.BorderColor3 = library.theme.border

                local inner = Instance.new("Frame", box)
                inner.Size = UDim2.new(1, -4, 1, -4)
                inner.Position = UDim2.fromOffset(2, 2)
                inner.BackgroundColor3 = library.theme.accent
                inner.BorderSizePixel = 0
                inner.Visible = toggle.value

                local label = Instance.new("TextLabel", toggleBtn)
                label.Size = UDim2.new(1, -20, 1, 0)
                label.Position = UDim2.fromOffset(20, 0)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = library.theme.text
                label.TextSize = 14
                label.Font = library.theme.font
                label.TextXAlignment = Enum.TextXAlignment.Left

                local function update()
                    inner.Visible = toggle.value
                    if flag then library.flags[flag] = toggle.value end
                    callback(toggle.value)
                end

                toggleBtn.MouseButton1Click:Connect(function()
                    toggle.value = not toggle.value
                    update()
                end)

                function toggle:Set(val)
                    toggle.value = val
                    update()
                end

                function toggle:AddColorpicker(default, callback, flag)
                    local cp = {color = default or Color3.fromRGB(255, 255, 255)}
                    local cpBtn = Instance.new("TextButton", toggleBtn)
                    cpBtn.Size = UDim2.fromOffset(20, 10)
                    cpBtn.Position = UDim2.new(1, -20, 0.5, -5)
                    cpBtn.BackgroundColor3 = cp.color
                    cpBtn.BorderSizePixel = 1
                    cpBtn.BorderColor3 = library.theme.border
                    cpBtn.Text = ""

                    cpBtn.MouseButton1Click:Connect(function()
                        -- Simplified color picker for this example
                        local r = math.random()
                        local g = math.random()
                        local b = math.random()
                        cp.color = Color3.new(r, g, b)
                        cpBtn.BackgroundColor3 = cp.color
                        callback(cp.color)
                    end)
                end

                function toggle:AddKeybind(default, callback, flag)
                    local kb = {key = default or Enum.KeyCode.None}
                    local kbBtn = Instance.new("TextButton", toggleBtn)
                    kbBtn.Size = UDim2.fromOffset(40, 16)
                    kbBtn.Position = UDim2.new(1, -45, 0.5, -8)
                    kbBtn.BackgroundColor3 = library.theme.light_gray
                    kbBtn.BorderSizePixel = 1
                    kbBtn.BorderColor3 = library.theme.border
                    kbBtn.Text = kb.key == Enum.KeyCode.None and "[None]" or "[" .. kb.key.Name .. "]"
                    kbBtn.TextColor3 = library.theme.text
                    kbBtn.TextSize = 12
                    kbBtn.Font = library.theme.font

                    kbBtn.MouseButton1Click:Connect(function()
                        kbBtn.Text = "[...]"
                        local connection
                        connection = uis.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                kb.key = input.KeyCode
                                kbBtn.Text = "[" .. kb.key.Name .. "]"
                                connection:Disconnect()
                                if callback then callback(kb.key) end
                            end
                        end)
                    end)
                end

                return toggle
            end

            function sector:AddButton(text, callback)
                local btn = Instance.new("TextButton", sectorContainer)
                btn.Size = UDim2.new(1, 0, 0, 22)
                btn.BackgroundColor3 = library.theme.light_gray
                btn.BorderSizePixel = 1
                btn.BorderColor3 = library.theme.border
                btn.Text = text
                btn.TextColor3 = library.theme.text
                btn.TextSize = 14
                btn.Font = library.theme.font

                btn.MouseButton1Click:Connect(callback)
                return btn
            end

            function sector:AddSlider(text, min, default, max, prec, callback, flag)
                local slider = {value = default or min}
                local sliderFrame = Instance.new("Frame", sectorContainer)
                sliderFrame.Size = UDim2.new(1, 0, 0, 35)
                sliderFrame.BackgroundTransparency = 1

                local label = Instance.new("TextLabel", sliderFrame)
                label.Size = UDim2.new(1, 0, 0, 15)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = library.theme.text
                label.TextSize = 14
                label.Font = library.theme.font
                label.TextXAlignment = Enum.TextXAlignment.Left

                local valueLabel = Instance.new("TextLabel", sliderFrame)
                valueLabel.Size = UDim2.new(1, 0, 0, 15)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(slider.value)
                valueLabel.TextColor3 = library.theme.text
                valueLabel.TextSize = 14
                valueLabel.Font = library.theme.font
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right

                local bar = Instance.new("Frame", sliderFrame)
                bar.Size = UDim2.new(1, 0, 0, 4)
                bar.Position = UDim2.fromOffset(0, 22)
                bar.BackgroundColor3 = library.theme.light_gray
                bar.BorderSizePixel = 0

                local fill = Instance.new("Frame", bar)
                fill.Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0)
                fill.BackgroundColor3 = library.theme.accent
                fill.BorderSizePixel = 0

                local function update(input)
                    local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    slider.value = math.floor((min + (max - min) * pos) / prec + 0.5) * prec
                    fill.Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0)
                    valueLabel.Text = tostring(slider.value)
                    if flag then library.flags[flag] = slider.value end
                    callback(slider.value)
                end

                local sliding = false
                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        update(input)
                    end
                end)
                uis.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)
                uis.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input)
                    end
                end)

                function slider:Set(val)
                    slider.value = val
                    fill.Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0)
                    valueLabel.Text = tostring(slider.value)
                    callback(slider.value)
                end

                return slider
            end

            function sector:AddTextbox(text, default, callback, flag)
                local box = {value = default or ""}
                local boxFrame = Instance.new("Frame", sectorContainer)
                boxFrame.Size = UDim2.new(1, 0, 0, 35)
                boxFrame.BackgroundTransparency = 1

                local label = Instance.new("TextLabel", boxFrame)
                label.Size = UDim2.new(1, 0, 0, 15)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = library.theme.text
                label.TextSize = 14
                label.Font = library.theme.font
                label.TextXAlignment = Enum.TextXAlignment.Left

                local input = Instance.new("TextBox", boxFrame)
                input.Size = UDim2.new(1, 0, 0, 18)
                input.Position = UDim2.fromOffset(0, 17)
                input.BackgroundColor3 = library.theme.light_gray
                input.BorderSizePixel = 1
                input.BorderColor3 = library.theme.border
                input.Text = box.value
                input.TextColor3 = library.theme.text
                input.TextSize = 14
                input.Font = library.theme.font
                input.ClearTextOnFocus = false

                input.FocusLost:Connect(function()
                    box.value = input.Text
                    if flag then library.flags[flag] = box.value end
                    callback(box.value)
                end)

                function box:Set(val)
                    box.value = val
                    input.Text = val
                    callback(val)
                end
                function box:Get() return input.Text end

                return box
            end

            function sector:AddDropdown(text, items, default, multichoice, callback, flag)
                local dropdown = {value = default, open = false}
                local ddFrame = Instance.new("Frame", sectorContainer)
                ddFrame.Size = UDim2.new(1, 0, 0, 35)
                ddFrame.BackgroundTransparency = 1

                local label = Instance.new("TextLabel", ddFrame)
                label.Size = UDim2.new(1, 0, 0, 15)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = library.theme.text
                label.TextSize = 14
                label.Font = library.theme.font
                label.TextXAlignment = Enum.TextXAlignment.Left

                local btn = Instance.new("TextButton", ddFrame)
                btn.Size = UDim2.new(1, 0, 0, 18)
                btn.Position = UDim2.fromOffset(0, 17)
                btn.BackgroundColor3 = library.theme.light_gray
                btn.BorderSizePixel = 1
                btn.BorderColor3 = library.theme.border
                btn.Text = tostring(default or "None")
                btn.TextColor3 = library.theme.text
                btn.TextSize = 14
                btn.Font = library.theme.font

                local list = Instance.new("Frame", screenGui)
                list.Size = UDim2.new(0, 0, 0, 0)
                list.BackgroundColor3 = library.theme.dark_gray
                list.BorderSizePixel = 1
                list.BorderColor3 = library.theme.border
                list.Visible = false
                list.ZIndex = 100

                local listLayout = Instance.new("UIListLayout", list)

                btn.MouseButton1Click:Connect(function()
                    dropdown.open = not dropdown.open
                    list.Visible = dropdown.open
                    list.Position = UDim2.fromOffset(btn.AbsolutePosition.X, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y)
                    list.Size = UDim2.fromOffset(btn.AbsoluteSize.X, #items * 20)
                end)

                for _, item in pairs(items) do
                    local itemBtn = Instance.new("TextButton", list)
                    itemBtn.Size = UDim2.new(1, 0, 0, 20)
                    itemBtn.BackgroundColor3 = library.theme.dark_gray
                    itemBtn.BorderSizePixel = 0
                    itemBtn.Text = item
                    itemBtn.TextColor3 = library.theme.text
                    itemBtn.TextSize = 14
                    itemBtn.Font = library.theme.font
                    itemBtn.ZIndex = 101

                    itemBtn.MouseButton1Click:Connect(function()
                        btn.Text = item
                        dropdown.value = item
                        dropdown.open = false
                        list.Visible = false
                        if flag then library.flags[flag] = item end
                        callback(item)
                    end)
                end

                return dropdown
            end

            function sector:AddLabel(text, color)
                local label = Instance.new("TextLabel", sectorContainer)
                label.Size = UDim2.new(1, 0, 0, 15)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = color or library.theme.text
                label.TextSize = 14
                label.Font = library.theme.font
                label.TextXAlignment = Enum.TextXAlignment.Left
                return label
            end

            return sector
        end

        table.insert(window.tabs, tab)
        if #window.tabs == 1 then tab:Select() end
        return tab
    end

    -- Automatically create Settings Tab
    local settingsTab = window:CreateTab("Settings")
    local configSector = settingsTab:CreateSector("Configuration", "left")
    local configName = configSector:AddTextbox("Config Name", "", function() end)
    
    local configList = configSector:AddDropdown("Configs", {}, "None", false, function() end)

    configSector:AddButton("Create Config", function()
        local name = configName:Get()
        if name ~= "" then
            print("Config Created: " .. name)
            -- Logic for saving config would go here (writefile)
        end
    end)

    configSector:AddButton("Save Config", function()
        print("Config Saved")
    end)

    configSector:AddButton("Load Config", function()
        print("Config Loaded")
    end)

    configSector:AddButton("Delete Config", function()
        print("Config Deleted")
    end)

    local menuSector = settingsTab:CreateSector("Menu", "right")
    menuSector:AddKeybind("Menu Keybind", window.keybind, function(key)
        window.keybind = key
    end)

    local colorSector = settingsTab:CreateSector("Theme", "right")
    colorSector:AddButton("Sync Theme", function()
        -- Logic to update all UI elements with new theme colors
    end)

    return window
end

function library:Notify(title, text, duration)
    print("Notification: [" .. title .. "] " .. text)
    -- Simple notification logic could be added here
end

return library
