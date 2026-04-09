local UILibrary = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function CreateElement(class, properties)
    local element = Instance.new(class)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end

function UILibrary:CreateWindow(title)
    local window = {}
    local tabs = {}
    local Minimized = false
    
    local ScreenGui = CreateElement("ScreenGui", {
        Name = "UILibWindow",
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    local MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -350, 0.5, -250),
        Size = UDim2.new(0, 700, 0, 500),
        ClipsDescendants = true,
        Visible = true
    })

    CreateElement("UICorner", {CornerRadius = UDim.new(0, 20), Parent = MainFrame})
    CreateElement("UIStroke", {Color = Color3.fromRGB(0, 200, 255), Thickness = 3, Transparency = 0.5, Parent = MainFrame})
    CreateElement("UIGradient", {Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 10)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))}, Rotation = 45, Parent = MainFrame})

    local TopBar = CreateElement("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 70)
    })

    CreateElement("UICorner", {CornerRadius = UDim.new(0, 20), Parent = TopBar})

    CreateElement("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 25, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = title or "UI Library",
        TextColor3 = Color3.fromRGB(0, 200, 255),
        TextSize = 26,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextStrokeTransparency = 0.9,
        TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    })

    -- --- 核心修改部分：左侧页签容器改为可滚动 ---
    local TabContainer = CreateElement("ScrollingFrame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(0, 200, 1, -70),
        CanvasSize = UDim2.new(0, 0, 0, 0), -- 初始画布大小
        AutomaticCanvasSize = Enum.AutomaticSize.Y, -- 根据内容自动增长高度
        ScrollBarThickness = 2, -- 侧边滚动条粗细
        ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    CreateElement("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })

    -- 增加内边距防止第一个按钮贴顶
    CreateElement("UIPadding", {
        Parent = TabContainer,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })
    -- --- 修改结束 ---

    local ContentFrame = CreateElement("Frame", {
        Name = "ContentFrame",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 210, 0, 80),
        Size = UDim2.new(1, -220, 1, -90)
    })

    local CloseButton = CreateElement("TextButton", {
        Parent = TopBar,
        BackgroundColor3 = Color3.fromRGB(255, 80, 80),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -60, 0.5, -20),
        Size = UDim2.new(0, 40, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20
    })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = CloseButton})

    local MinimizeButton = CreateElement("TextButton", {
        Parent = TopBar,
        BackgroundColor3 = Color3.fromRGB(255, 200, 80),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -110, 0.5, -20),
        Size = UDim2.new(0, 40, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20
    })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MinimizeButton})

    -- 窗口拖动逻辑
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        task.wait(0.3)
        ScreenGui:Destroy()
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        TabContainer.Visible = not Minimized
        ContentFrame.Visible = not Minimized
        if Minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 700, 0, 70)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 700, 0, 500)}):Play()
        end
    end)

    function window:SwitchToTab(tabToSelect)
        for _, tab in pairs(tabs) do
            tab.Page.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25), TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
        end
        tabToSelect.Page.Visible = true
        TweenService:Create(tabToSelect.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end

    function window:CreateTab(name)
        local tab = {}
        local tabButton = CreateElement("TextButton", {
            Name = name .. "Tab",
            Parent = TabContainer,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 50),
            Font = Enum.Font.GothamBold,
            Text = name,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextSize = 18
        })
        CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = tabButton})
        
        local tabStroke = CreateElement("UIStroke", {Color = Color3.fromRGB(0, 200, 255), Thickness = 2, Transparency = 0.6, Parent = tabButton})

        local page = CreateElement("ScrollingFrame", {
            Name = name .. "Page",
            Parent = ContentFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255),
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        CreateElement("UIListLayout", {Parent = page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)})

        tab.Button = tabButton
        tab.Page = page
        table.insert(tabs, tab)

        tabButton.MouseButton1Click:Connect(function() window:SwitchToTab(tab) end)
        if #tabs == 1 then window:SwitchToTab(tab) end

        function tab:CreateButton(text, callback)
            local button = CreateElement("TextButton", {
                Parent = page,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -20, 0, 50),
                Font = Enum.Font.GothamBold,
                Text = text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 18
            })
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = button})
            button.MouseButton1Click:Connect(function() pcall(callback) end)
            return button
        end

        return tab
    end

    return window
end

return UILibrary
