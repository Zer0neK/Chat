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
        Text = title or "剑客加载器",
        TextColor3 = Color3.fromRGB(0, 200, 255),
        TextSize = 26,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- 【左侧容器修复】
    local TabContainer = CreateElement("ScrollingFrame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(0, 200, 1, -70),
        CanvasSize = UDim2.new(0, 0, 0, 0), 
        AutomaticCanvasSize = Enum.AutomaticSize.Y, -- 开启自动下滑
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    CreateElement("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    CreateElement("UIPadding", {
        Parent = TabContainer,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })

    local ContentFrame = CreateElement("Frame", {
        Name = "ContentFrame",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 210, 0, 80),
        Size = UDim2.new(1, -220, 1, -90)
    })

    function window:CreateTab(name)
        local tab = {}
        local tabButton = CreateElement("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Size = UDim2.new(1, -20, 0, 50),
            Font = Enum.Font.GothamBold,
            Text = name,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextSize = 18
        })
        CreateElement("UICorner", {CornerRadius = UDim.new(0, 12), Parent = tabButton})

        -- 【右侧内容区修复】
        local page = CreateElement("ScrollingFrame", {
            Name = name .. "Page",
            Parent = ContentFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255),
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0), -- 初始设为0
            AutomaticCanvasSize = Enum.AutomaticSize.Y, -- 核心：让右边也能下滑
            ScrollingDirection = Enum.ScrollingDirection.Y
        })
        
        CreateElement("UIListLayout", {
            Parent = page, 
            SortOrder = Enum.SortOrder.LayoutOrder, 
            Padding = UDim.new(0, 15),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        
        CreateElement("UIPadding", {
            Parent = page,
            PaddingTop = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5)
        })

        tab.Button = tabButton
        tab.Page = page
        table.insert(tabs, tab)

        tabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                t.Page.Visible = false
                t.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            end
            page.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        end)

        if #tabs == 1 then
            page.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        end

        function tab:CreateButton(text, callback)
            local button = CreateElement("TextButton", {
                Parent = page,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                Size = UDim2.new(1, -10, 0, 50),
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

    -- 简单的关闭和拖拽逻辑
    local CloseButton = CreateElement("TextButton", {
        Parent = TopBar,
        BackgroundColor3 = Color3.fromRGB(255, 80, 80),
        Position = UDim2.new(1, -50, 0.5, -15),
        Size = UDim2.new(0, 30, 0, 30),
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = CloseButton})
    CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    return window
end

return UILibrary
