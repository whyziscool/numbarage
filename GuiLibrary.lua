local request = (syn and syn.request) or request or http_request or (http and http.request)
local UIS = game:GetService("UserInputService")
local GuiLibrary = {}
local utils = {}; GuiLibrary.utils = utils do
    function utils:require(url, bypass)
        if isfile(url) then
            return readfile(url)
        end

        local newUrl = (bypass and "https://raw.githubusercontent.com/joeengo/" or "https://raw.githubusercontent.com/joeengo/engoware/main/") .. url:gsub("engoware/", ""):gsub("engoware\\", "")
        local response = request({
            Url = newUrl,
            Method = "GET",
        })
        if response.StatusCode == 200 then
            return response.Body
        end
    end

    function utils:getColorOfObject(object)
        if utils:isRainbow() then
            local yPos = object.AbsolutePosition.Y
            return utils:getRainbow(yPos)
        end
        return utils:getColorTheme()
    end

    function utils:getColor()
        if utils:isRainbow() then
            return utils:getRainbow()
        end
        return utils:getColorTheme()
    end

    function utils:getColorTheme(table)
        local color = GuiLibrary.ColorTheme or {H = 0, S = 1, V = 1}
        return table and color or Color3.fromHSV(color.H, color.S, color.V)
    end

    function utils:setColorTheme(color)
        local typeOf = typeof(color)
        GuiLibrary.ColorTheme = GuiLibrary.ColorTheme or {}

        if typeOf == "table" then
            GuiLibrary.ColorTheme = color
        else
            local h,s,v = (color):ToHSV()
            GuiLibrary.ColorTheme.H = h
            GuiLibrary.ColorTheme.S = s
            GuiLibrary.ColorTheme.V = v
        end
        if GuiLibrary.ColorUpdate then
            GuiLibrary.ColorUpdate:Fire()
        end
    end

    function utils:isRainbow()
        return GuiLibrary.Rainbow or false
    end

    function utils:getRainbow(yPos)
        if utils:isRainbow() then
            local yPos = yPos or 0
            if yPos < 0 then
                yPos = -yPos
            end
            local color = utils:getColorTheme(true).H
            local calculatedColor = color + (yPos / (GuiLibrary.RainbowSmoothness or 1750))
            while (calculatedColor > 1) do
                calculatedColor = calculatedColor - 1
            end
            return Color3.fromHSV(calculatedColor, GuiLibrary.ColorTheme.S, GuiLibrary.ColorTheme.V)
        end
        return Color3.new(0,0,0)
    end

    function utils:connection(connection)
        GuiLibrary.Connections = GuiLibrary.Connections or {}
        GuiLibrary.Connections[#GuiLibrary.Connections + 1] = connection
    end

    function utils:addObject(name, object) 
        GuiLibrary.Objects = GuiLibrary.Objects or {}
        GuiLibrary.Objects[name] = object
    end
    
    function utils:removeObject(name) 
        local function remove(t)
            for i,v in next, t do 
                local typeOf = typeof(v)
                if typeOf == 'Instance' then 
                    v:Destroy()
                elseif typeOf == 'RBXScriptConnection' then
                    if v.Connected then 
                        v:Disconnect()
                    end
                elseif typeOf == 'table' then 
                    remove(v)
                end
            end
        end
        
        if GuiLibrary.Objects[name] then
            remove(GuiLibrary.Objects[name])
            GuiLibrary.Objects[name] = nil
        end
    end

    function utils:getNextWindowPosition() 
        if GuiLibrary.WindowX then 
            GuiLibrary.WindowX = GuiLibrary.WindowX + 220
        else
            GuiLibrary.WindowX = 150
        end
        return GuiLibrary.WindowX
    end
end

coroutine.wrap(function()
    while task.wait() do
        if utils:isRainbow() then
            local old = GuiLibrary.ColorTheme or {}
            local hue = old.H or 0
            if hue >= 1 then
                hue = 0
            end
            utils:setColorTheme({
                H = (hue) + 0.001,
                S = old.S or 1,
                V = old.V or 1
            })
        end
    end
end)()

local SignalLib = loadstring(utils:require("roblox/main/SignalLib.lua", true))()
local ColorUpdate = SignalLib.new()
GuiLibrary.ColorUpdate = ColorUpdate

local ScreenGui = Instance.new("ScreenGui")
local ClickGUI = Instance.new("Frame")
ScreenGui.Name = "engoware"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ClickGUI.Name = "ClickGUI"
ClickGUI.Parent = ScreenGui
ClickGUI.BackgroundTransparency = 1
ClickGUI.Size = UDim2.new(1, 0, 1, 0)
if syn then
    syn.protect_gui(ScreenGui)
end
if gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = game:GetService("CoreGui").RobloxGui
end

GuiLibrary.ClickGUI = ClickGUI
GuiLibrary.ScreenGui = ScreenGui
function GuiLibrary.CreateWindow(args)
    local windowapi = {Expanded = true}
    local windowname = args.Name
    local nextPos = utils:getNextWindowPosition()
    local WindowTopBar = Instance.new("TextButton", ClickGUI)
    WindowTopBar.Name = args.Name.."WindowTopBar"
    WindowTopBar.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    WindowTopBar.BorderSizePixel = 0
    WindowTopBar.Position = UDim2.new(0, nextPos, 0.05, 0)
    WindowTopBar.Size = UDim2.new(0, 203, 0, 33)
    WindowTopBar.AutoButtonColor = false
    WindowTopBar.Font = Enum.Font.Code
    WindowTopBar.Text = ""
    WindowTopBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    WindowTopBar.TextSize = 14.000
    WindowTopBar.Modal = true
    local Name = Instance.new("TextLabel")
    Name.Name = "Name"
    Name.Parent = WindowTopBar
    Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Name.BackgroundTransparency = 1.000
    Name.Position = UDim2.new(0.049261082, 0, 0, 0)
    Name.Size = UDim2.new(-0.024630541, 162, 1, 0)
    Name.ZIndex = 2
    Name.Font = Enum.Font.Code
    Name.Text = windowname
    Name.TextColor3 = Color3.fromRGB(255, 255, 255)
    Name.TextSize = 14.000
    Name.TextXAlignment = Enum.TextXAlignment.Left
    local Expand = Instance.new("ImageButton")
    Expand.Name = "Expand"
    Expand.Parent = WindowTopBar
    Expand.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Expand.BackgroundTransparency = 1.000
    Expand.BorderSizePixel = 0
    Expand.Position = UDim2.new(0.857073903, 0, 0.211999997, 0)
    Expand.Rotation = 180
    Expand.Size = UDim2.new(0, 19, 0, 19)
    Expand.ZIndex = 2
    Expand.Image = "http://www.roblox.com/asset/?id=6031094679"
    Expand.ScaleType = Enum.ScaleType.Fit
    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Parent = WindowTopBar
    Window.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Window.BackgroundTransparency = 0.100
    Window.BorderSizePixel = 0
    Window.Position = UDim2.new(0, 0, 0, 33)
    Window.Size = UDim2.new(0, 203, 0, 396)
    local ModuleContainer = Instance.new("Frame")
    ModuleContainer.Name = "ModuleContainer"
    ModuleContainer.Parent = Window
    ModuleContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ModuleContainer.BackgroundTransparency = 1.000
    ModuleContainer.BorderSizePixel = 0
    ModuleContainer.Size = UDim2.new(0, 203, 0.990886092, 0)
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 0)
    UIListLayout.Parent = ModuleContainer
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    function windowapi.Update() 
        local size = UIListLayout.AbsoluteContentSize
        ModuleContainer.Size = UDim2.new(0, 203, 0, size.Y)
        Window.Size = UDim2.new(0, 203, 0, size.Y)
    end

    utils:connection(UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(windowapi.Update))

    windowapi.Update()

    function windowapi.Expand()
        if windowapi.Expanded then
            Window.Visible = false
            windowapi.Expanded = false
            Expand.Rotation = 0
            ModuleContainer.Visible = false
        else
            Window.Visible = true
            windowapi.Expanded = true
            Expand.Rotation = 180
            ModuleContainer.Visible = true
        end
        windowapi.Update()
    end

    Expand.MouseButton1Click:Connect(windowapi.Expand)

    function windowapi.CreateOptionsButton(args)
        local buttonapi = {Expanded = false, Enabled = false, Recording = false}
        local optionsbuttonname = args.Name
        local Module = Instance.new("TextButton")
        Module.Name = optionsbuttonname.."Module"
        Module.Parent = ModuleContainer
        Module.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
        Module.BackgroundTransparency = 0.300
        Module.BorderSizePixel = 0
        Module.Size = UDim2.new(0, 203, 0, 28)
        Module.Font = Enum.Font.Code
        Module.Text = ""
        Module.TextColor3 = Color3.fromRGB(255, 255, 255)
        Module.TextSize = 14.000
        local Name_2 = Instance.new("TextLabel")
        Name_2.Name = "Name"
        Name_2.Parent = Module
        Name_2.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
        Name_2.BackgroundTransparency = 1.000
        Name_2.BorderSizePixel = 0
        Name_2.Position = UDim2.new(0.0495019183, 0, 0, 0)
        Name_2.Size = UDim2.new(-0.0887388065, 182, 1, 0)
        Name_2.Font = Enum.Font.Code
        Name_2.Text = optionsbuttonname
        Name_2.TextColor3 = Color3.fromRGB(255, 255, 255)
        Name_2.TextSize = 14.000
        Name_2.TextXAlignment = Enum.TextXAlignment.Left
        local ModuleChildrenContainer = Instance.new("Frame")
        ModuleChildrenContainer.Name = "ModuleChildrenContainer"
        ModuleChildrenContainer.Parent = ModuleContainer
        ModuleChildrenContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ModuleChildrenContainer.BackgroundTransparency = 1.000
        ModuleChildrenContainer.BorderSizePixel = 0
        ModuleChildrenContainer.Position = UDim2.new(0, 0, 0, 27)
        ModuleChildrenContainer.Size = UDim2.new(0, 203, 0, 368)
        ModuleChildrenContainer.Visible = false
        local UIListLayout_2 = Instance.new("UIListLayout")
        UIListLayout_2.Parent = ModuleChildrenContainer
        UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_2.Padding = UDim.new(0, 4)
        local Bind = Instance.new("TextButton")
        Bind.Name = "Bind"
        Bind.Parent = ModuleChildrenContainer
        Bind.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
        Bind.BackgroundTransparency = 0.300
        Bind.BorderColor3 = Color3.fromRGB(6, 6, 6)
        Bind.LayoutOrder = 2
        Bind.Size = UDim2.new(0, 184, 0, 22)
        Bind.Font = Enum.Font.SourceSans
        Bind.Text = ""
        Bind.TextColor3 = Color3.fromRGB(0, 0, 0)
        Bind.TextSize = 14.000
        local Name_3 = Instance.new("TextLabel")
        Name_3.Name = "Name"
        Name_3.Parent = Bind
        Name_3.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
        Name_3.BackgroundTransparency = 1.000
        Name_3.BorderSizePixel = 0
        Name_3.Position = UDim2.new(0.0440070182, 0, 0.227272734, 0)
        Name_3.Size = UDim2.new(0.046920944, 140, 0.5, 0)
        Name_3.Font = Enum.Font.Code
        Name_3.Text = "bind: none"
        Name_3.TextColor3 = Color3.fromRGB(255, 255, 255)
        Name_3.TextSize = 14.000
        Name_3.TextXAlignment = Enum.TextXAlignment.Left
        utils:connection(Bind.MouseButton1Click:Connect(function() 
            if GuiLibrary.IsRecording then 
                return 
            end

            buttonapi.Recording = not buttonapi.Recording
            if buttonapi.Recording then 
                GuiLibrary.IsRecording = true
                Name_3.Text = "press a key..."
            end
        end))
        local ModuleOptionsContainer = Instance.new("Frame")
        ModuleOptionsContainer.Name = "ModuleOptionsContainer"
        ModuleOptionsContainer.Parent = ModuleChildrenContainer
        ModuleOptionsContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ModuleOptionsContainer.BackgroundTransparency = 1.000
        ModuleOptionsContainer.BorderSizePixel = 0
        ModuleOptionsContainer.LayoutOrder = 1
        ModuleOptionsContainer.Size = UDim2.new(0, 203, 0, 334)
        local UIListLayout_3 = Instance.new("UIListLayout")
        UIListLayout_3.Parent = ModuleOptionsContainer
        UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_3.Padding = UDim.new(0, 4)

        function buttonapi.SetBind(key) 
            buttonapi.Recording = false
            GuiLibrary.IsRecording = false
            if key then
                buttonapi.Bind = key
            else
                buttonapi.Bind = nil
            end
            Name_3.Text = "bind: "..(buttonapi.Bind and buttonapi.Bind:lower() or "none")
        end

        local bind = args.Bind or args.DefaultBind
        if bind then 
            buttonapi.SetBind(bind)
        end

        function buttonapi.Update() 
            local size2 = UIListLayout_2.AbsoluteContentSize
            ModuleChildrenContainer.Size = UDim2.new(0, 203, 0, size2.Y + 8)
            local size = UIListLayout_3.AbsoluteContentSize
            ModuleOptionsContainer.Size = UDim2.new(0, 203, 0, size.Y)
        end
        utils:connection(UIListLayout_3:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(buttonapi.Update))
        utils:connection(UIListLayout_2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(buttonapi.Update))

        utils:connection(ColorUpdate:Connect(function()
            if buttonapi.Enabled then
                Module.BackgroundColor3 = utils:getColorOfObject(Module)
            else
                Module.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            end
        end))

        function buttonapi.Toggle()
            if buttonapi.Enabled then
                buttonapi.Enabled = false
                Module.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            else
                buttonapi.Enabled = true
                Module.BackgroundColor3 = utils:getColorOfObject(Module)
            end
            if args.Function then
                args.Function(buttonapi.Enabled)
            end
        end

        function buttonapi.Expand()
            if buttonapi.Expanded then
                buttonapi.Expanded = false
                ModuleChildrenContainer.Visible = false
            else
                buttonapi.Expanded = true
                ModuleChildrenContainer.Visible = true
            end
            windowapi.Update()
        end

        utils:connection(Module.MouseButton1Click:Connect(buttonapi.Toggle))
        utils:connection(Module.MouseButton2Click:Connect(buttonapi.Expand))

        -- OPTIONS --

        function buttonapi.CreateToggle(args) 
            local toggleapi = {}
            local Toggle = Instance.new("Frame")
            Toggle.Name = "Toggle"
            Toggle.Parent = ModuleOptionsContainer
            Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Toggle.BackgroundTransparency = 1.000
            Toggle.BorderSizePixel = 0
            Toggle.Position = UDim2.new(0, 0, 2.75755095, 0)
            Toggle.Size = UDim2.new(0, 203, 0, 24)
            local Name_7 = Instance.new("TextLabel")
            Name_7.Name = "Name"
            Name_7.Parent = Toggle
            Name_7.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            Name_7.BackgroundTransparency = 1.000
            Name_7.BorderSizePixel = 0
            Name_7.Position = UDim2.new(0.0495016165, 0, 0, 0)
            Name_7.Size = UDim2.new(-0.197113186, 182, 1, 0)
            Name_7.Font = Enum.Font.Code
            Name_7.Text = args.Name
            Name_7.TextColor3 = Color3.fromRGB(255, 255, 255)
            Name_7.TextSize = 14.000
            Name_7.TextXAlignment = Enum.TextXAlignment.Left
            local Toggle_2 = Instance.new("Frame")
            Toggle_2.Name = "Toggle"
            Toggle_2.Parent = Toggle
            Toggle_2.AnchorPoint = Vector2.new(0, 0.5)
            Toggle_2.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            Toggle_2.BackgroundTransparency = 0.300
            Toggle_2.BorderSizePixel = 0
            Toggle_2.Position = UDim2.new(0, 170, 0, 14)
            Toggle_2.Size = UDim2.new(0, 21, 0, 10)
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Parent = Toggle_2
            ToggleButton.AnchorPoint = Vector2.new(0, 0.5)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(2, 255, 137)
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Position = UDim2.new(-0.2, 0, 0.5, 0)
            ToggleButton.Size = UDim2.new(0, 10, 0, 12)
            ToggleButton.Font = Enum.Font.Code
            ToggleButton.Text = ""
            ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            ToggleButton.TextSize = 14.000
            utils:connection(ColorUpdate:Connect(function()
                ToggleButton.BackgroundColor3 = utils:getColorOfObject(ToggleButton)
            end))

            function toggleapi.Toggle() 
                if toggleapi.Enabled then 
                    toggleapi.Enabled = false
                    ToggleButton:TweenPosition(UDim2.fromScale(-0.2, 0.5), "Out", "Quad", 0.2, true)
                else
                    toggleapi.Enabled = true
                    ToggleButton:TweenPosition(UDim2.fromScale(0.6, 0.5), "Out", "Quad", 0.2, true)
                end
                if args.Function then
                    args.Function(toggleapi.Enabled)
                end
            end
            utils:connection(ToggleButton.MouseButton1Click:Connect(toggleapi.Toggle))

            if (args.Default == true) then 
                toggleapi.Toggle()
            end

            utils:addObject(args.Name .. "Toggle", {Name = args.Name, Instance = Toggle, Type = "Toggle", OptionsButton = optionsbuttonname, API = toggleapi, args = args})

            return toggleapi
        end

        function buttonapi.CreateSlider(args) 
            local sliderapi = {}
            local min, max, default, round = args.Min, args.Max, (args.Default or args.Min), (args.Round or 1)
            
            local function getValueText(value)
                if math.floor(value) == value then 
                    return tostring(value) .. ".0"
                end
                return tostring(value)
            end  
            
            local Slider = Instance.new("Frame")
            Slider.Name = "Slider"
            Slider.Parent = ModuleOptionsContainer
            Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Slider.BackgroundTransparency = 1.000
            Slider.BorderSizePixel = 0
            Slider.Position = UDim2.new(0, 0, 0.945145488, 0)
            Slider.Size = UDim2.new(0, 203, 0, 39)
            local Name_6 = Instance.new("TextLabel")
            Name_6.Name = "Name"
            Name_6.Parent = Slider
            Name_6.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            Name_6.BackgroundTransparency = 1.000
            Name_6.BorderSizePixel = 0
            Name_6.Position = UDim2.new(0.0495016165, 0, 0, 0)
            Name_6.Size = UDim2.new(0, 140, 0.5, 0)
            Name_6.Font = Enum.Font.Code
            Name_6.Text = args.Name
            Name_6.TextColor3 = Color3.fromRGB(255, 255, 255)
            Name_6.TextSize = 14.000
            Name_6.TextXAlignment = Enum.TextXAlignment.Left
            local Value = Instance.new("TextBox")   
            Value.Name = "Value"
            Value.Parent = Name_6
            Value.AnchorPoint = Vector2.new(0, 0.5)
            Value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Value.BackgroundTransparency = 1.000
            Value.Position = UDim2.new(1.01400006, 0, 0.5, 0)
            Value.Size = UDim2.new(0, 39, 0, 14)
            Value.Font = Enum.Font.Code
            Value.PlaceholderText = "val"
            Value.Text = getValueText(default)
            Value.TextColor3 = Color3.fromRGB(255, 255, 255)
            Value.TextSize = 13.000
            Value.TextXAlignment = Enum.TextXAlignment.Right
            local SliderBack = Instance.new("Frame")
            SliderBack.Name = "SliderBack"
            SliderBack.Parent = Slider
            SliderBack.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderBack.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            SliderBack.BackgroundTransparency = 0.300
            SliderBack.BorderSizePixel = 0
            SliderBack.Position = UDim2.new(0.5, 0, 0.699999988, 0)
            SliderBack.Size = UDim2.new(0, 182, 0, 5)
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "SliderFill"
            SliderFill.Parent = SliderBack
            SliderFill.AnchorPoint = Vector2.new(0, 0.5)
            SliderFill.BackgroundColor3 = Color3.fromRGB(2, 255, 137)
            SliderFill.BorderSizePixel = 0
            SliderFill.Position = UDim2.new(0, 0, 0.5, 0)
            SliderFill.Size = UDim2.new(0, 50, 1, 0)
            utils:connection(ColorUpdate:Connect(function()
                SliderFill.BackgroundColor3 = utils:getColorOfObject(SliderFill)
            end))

            utils:connection(Value.FocusLost:Connect(function() 
                local parsed = tonumber(Value.Text)
                if parsed then 
                    sliderapi.Set(parsed, true)
                else
                    Value.Text = getValueText(sliderapi.Value)
                end
            end))
          
            local function slide(input)
                local sizeX = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
                SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                local value = math.round(((( (max - min) * sizeX ) + min) * (10 ^ round))) / (10 ^ round)
                sliderapi.Value = value
                Value.Text = getValueText(value)
                if args.OnInputEnded then
                    return
                end
                if args.Function then
                    args.Function(value)
                end
            end

            local isSliding
            utils:connection(Slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isSliding = true
                    slide(input)
                end
            end))

            utils:connection(Slider.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if args.OnInputEnded then
                        if args.Function then
                            args.Function(sliderapi.Value)
                        end
                    end
                    isSliding = false
                end
            end))

            utils:connection(UIS.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if isSliding then
                        slide(input)
                    end
                end
            end))

            function sliderapi.Set(value, useOverMax)
                local value = not useOverMax and math.floor((math.clamp(value, min, max) * (10^round))+0.5)/(10^round) or 
                math.clamp(value, (args.RealMin or -math.huge), (args.RealMax or math.huge))
                local sizeValue = math.floor((math.clamp(value, min, max) * (10^round))+0.5)/(10^round)
                sliderapi.Value = value
                SliderFill.Size = UDim2.new((sizeValue - min) / (max - min), 0, 1, 0)
                Value.Text = getValueText(value)
                if args.Function then
                    args.Function(value)
                end
            end
            sliderapi.Set(default)

            utils:addObject(args.Name .. "Slider", {Name = args.Name, Instance = Slider, Type = "Slider", OptionsButton = optionsbuttonname, API = sliderapi, args = args})

            return sliderapi
        end

        function buttonapi.CreateTextbox(args)
            local boxapi = {}
            local Textbox = Instance.new("Frame")
            Textbox.Name = "Textbox"
            Textbox.Parent = ModuleOptionsContainer
            Textbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Textbox.BackgroundTransparency = 1.000
            Textbox.BorderSizePixel = 0
            Textbox.AnchorPoint = Vector2.new(0, 0.5)
            Textbox.Position = UDim2.new(0, 0, 0.5, 0)
            Textbox.Size = UDim2.new(0, 203, 0, 30)
            local Textbox_2 = Instance.new("Frame")
            Textbox_2.Name = "Textbox"
            Textbox_2.Parent = Textbox
            Textbox_2.AnchorPoint = Vector2.new(0.5, 0.5)
            Textbox_2.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            Textbox_2.BackgroundTransparency = 0.300
            Textbox_2.BorderColor3 = Color3.fromRGB(6, 6, 6)
            Textbox_2.Position = UDim2.new(0.5, 0, 0.5, 0)
            Textbox_2.Size = UDim2.new(0, 184, 0, 22)
            local TextBoxValue = Instance.new("TextBox")
            TextBoxValue.Name = "TextBoxValue"
            TextBoxValue.Parent = Textbox_2
            TextBoxValue.AnchorPoint = Vector2.new(0.5, 0.5)
            TextBoxValue.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            TextBoxValue.BackgroundTransparency = 1.000
            TextBoxValue.BorderSizePixel = 0
            TextBoxValue.Position = UDim2.new(0.521894395, 0, 0.5, 0)
            TextBoxValue.Size = UDim2.new(0.955993056, 0, 1, 0)
            TextBoxValue.ClearTextOnFocus = false
            TextBoxValue.Font = Enum.Font.Code
            TextBoxValue.PlaceholderColor3 = Color3.fromRGB(113, 113, 113)
            TextBoxValue.PlaceholderText = args.Name
            TextBoxValue.Text = (args.Default or "")
            TextBoxValue.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBoxValue.TextSize = 14.000
            TextBoxValue.TextXAlignment = Enum.TextXAlignment.Left

            function boxapi.Set(value) 
                TextBoxValue.Text = value
                if args.Function then
                    args.Function(value)
                end
            end

            utils:connection(TextBoxValue.FocusLost:Connect(function()
                local text = TextBoxValue.Text
                if text and text ~= "" then
                    boxapi.Set(text)
                end
            end))
            utils:addObject(args.Name .. "Textbox", {Name = args.Name, Instance = Textbox, Type = "Textbox", OptionsButton = optionsbuttonname, API = boxapi, args = args})
            return boxapi
        end
        buttonapi.CreateTextBox = buttonapi.CreateTextbox

        function buttonapi.CreateDropdown(args) 
            local dropdownapi = {Values = {}, Expanded = false}
            local Dropdown = Instance.new("Frame")
            Dropdown.Name = "Dropdown"
            Dropdown.Parent = ModuleOptionsContainer
            Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Dropdown.BackgroundTransparency = 1.000
            Dropdown.BorderSizePixel = 0
            Dropdown.Position = UDim2.new(0, 0, 0.592544496, 0)
            Dropdown.Size = UDim2.new(0, 203, 0, 28)
            local DropdownBack = Instance.new("Frame")
            DropdownBack.Name = "DropdownBack"
            DropdownBack.Parent = Dropdown
            DropdownBack.AnchorPoint = Vector2.new(0.5, 0.5)
            DropdownBack.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            DropdownBack.BackgroundTransparency = 0.300
            DropdownBack.BorderSizePixel = 0
            DropdownBack.Position = UDim2.new(0.5, 0, 0, 15)
            DropdownBack.Size = UDim2.new(0, 184, 0, 22)
            local Name_4 = Instance.new("TextLabel")
            Name_4.Name = "Name"
            Name_4.Parent = DropdownBack
            Name_4.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            Name_4.BackgroundTransparency = 1.000
            Name_4.BorderSizePixel = 0
            Name_4.Position = UDim2.new(0.0440070182, 0, 0.227272734, 0)
            Name_4.Size = UDim2.new(0.046920944, 140, 0.5, 0)
            Name_4.Font = Enum.Font.Code
            Name_4.Text = args.Name
            Name_4.TextColor3 = Color3.fromRGB(255, 255, 255)
            Name_4.TextSize = 14.000
            Name_4.TextXAlignment = Enum.TextXAlignment.Left
            Name_4.TextTruncate = Enum.TextTruncate.AtEnd
            local Expand_2 = Instance.new("ImageButton")
            Expand_2.Name = "Expand"
            Expand_2.Parent = DropdownBack
            Expand_2.AnchorPoint = Vector2.new(0, 0.5)
            Expand_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Expand_2.BackgroundTransparency = 1.000
            Expand_2.BorderSizePixel = 0
            Expand_2.Position = UDim2.new(0.889967024, 0, 0.5, 0)
            Expand_2.Rotation = 0
            Expand_2.Size = UDim2.new(0, 19, 0, 19)
            Expand_2.ZIndex = 2
            Expand_2.Image = "http://www.roblox.com/asset/?id=6031094679"
            Expand_2.ScaleType = Enum.ScaleType.Fit
            local DropdownValues = Instance.new("Frame")
            DropdownValues.Name = "DropdownValues"
            DropdownValues.Parent = Dropdown
            DropdownValues.AnchorPoint = Vector2.new(0.5, 0.5)
            DropdownValues.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            DropdownValues.BackgroundTransparency = 1.000
            DropdownValues.BorderSizePixel = 0
            DropdownValues.Position = UDim2.new(0.5, 0, 0, 37)
            DropdownValues.Size = UDim2.new(0, 184, 0, 22)
            DropdownValues.Visible = false
            local UIListLayout_4 = Instance.new("UIListLayout")
            UIListLayout_4.Parent = DropdownValues
            UIListLayout_4.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder

            function dropdownapi.Update() 
                local size = UIListLayout_4.AbsoluteContentSize.Y
                if DropdownValues.Visible then
                    Dropdown.Size = UDim2.new(0, 203, 0, 28 + size)
                else
                    Dropdown.Size = UDim2.new(0, 203, 0, 28)
                end
            end

            utils:connection(UIListLayout_4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(dropdownapi.Update))

            function dropdownapi.SetValue(value)
                for i,v in next, dropdownapi.Values do
                    if v.Value == value then
                        if dropdownapi.Expanded then
                            --dropdownapi.Expand()
                        end
                        dropdownapi.Value = value
                        v.SelectedInstance.Visible = true
                        Name_4.Text = args.Name .. " - " .. tostring(value)
                        if args.Function then
                            args.Function(value)
                        end
                    else
                        v.SelectedInstance.Visible = false
                    end
                end
            end

            local function newValue(value)
                local valueapi = {}
                valueapi.Value = value
                local DropdownValue = Instance.new("TextButton")
                DropdownValue.Name = tostring(value).."DropdownValue"
                DropdownValue.Parent = DropdownValues
                DropdownValue.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
                DropdownValue.BackgroundTransparency = 0.300
                DropdownValue.BorderColor3 = Color3.fromRGB(6, 6, 6)
                DropdownValue.Size = UDim2.new(0, 184, 0, 22)
                DropdownValue.Font = Enum.Font.SourceSans
                DropdownValue.Text = ""
                DropdownValue.TextColor3 = Color3.fromRGB(0, 0, 0)
                DropdownValue.TextSize = 14.000
                DropdownValue.MouseButton1Click:Connect(function()
                    dropdownapi.SetValue(value)
                end)
                local Name_5 = Instance.new("TextLabel")
                Name_5.Name = "Name"
                Name_5.Parent = DropdownValue
                Name_5.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
                Name_5.BackgroundTransparency = 1.000
                Name_5.BorderSizePixel = 0
                Name_5.Position = UDim2.new(0.0440070182, 0, 0.227272734, 0)
                Name_5.Size = UDim2.new(0.046920944, 140, 0.5, 0)
                Name_5.Font = Enum.Font.Code
                Name_5.Text = tostring(value)
                Name_5.TextColor3 = Color3.fromRGB(255, 255, 255)
                Name_5.TextSize = 14.000
                Name_5.TextXAlignment = Enum.TextXAlignment.Left
                local Selected = Instance.new("Frame")
                Selected.Name = "Selected"
                Selected.Parent = DropdownValue
                Selected.AnchorPoint = Vector2.new(0, 0.5)
                Selected.BackgroundColor3 = Color3.fromRGB(2, 255, 137)
                Selected.Visible = false
                Selected.BorderSizePixel = 0
                Selected.Position = UDim2.new(0, 0, 0.5, 0)
                Selected.Size = UDim2.new(0, 2, 1, 0)
                utils:connection(ColorUpdate:Connect(function()
                    Selected.BackgroundColor3 = utils:getColorOfObject(Selected)
                end))
                valueapi.SelectedInstance = Selected
                valueapi.Instance = DropdownValue
                return valueapi
            end

            function dropdownapi.Expand() 
                if dropdownapi.Expanded then 
                    dropdownapi.Expanded = false
                    DropdownValues.Visible = false
                    Expand_2.Rotation = 0
                else
                    Expand_2.Rotation = 180
                    dropdownapi.Expanded = true
                    DropdownValues.Visible = true
                end
                dropdownapi.Update() 
            end
            utils:connection(Expand_2.MouseButton1Click:Connect(dropdownapi.Expand))

            for i,v in next, args.List do 
                dropdownapi.Values[#dropdownapi.Values+1] = newValue(v)
            end

            if args.Default then
                dropdownapi.SetValue(args.Default)
            end

            function dropdownapi.SetList(list)
                for i,v in next, dropdownapi.Values do
                    v.Instance:Destroy()
                    dropdownapi.Values[i] = nil
                end
                dropdownapi.Values = {}
                for i,v in next, list do 
                    dropdownapi.Values[#dropdownapi.Values+1] = newValue(v)
                end
            end

            utils:addObject(args.Name .. "Dropdown", {Name = args.Name, Instance = Dropdown, Type = "Dropdown", OptionsButton = optionsbuttonname, API = dropdownapi, args = args})

            return dropdownapi
        end



        function buttonapi.CreateMultiDropdown(args) 
            local dropdownapi = {Values = {}, Expanded = false}

            local MultiDropdown = Instance.new("Frame")
            MultiDropdown.Name = "MultiDropdown"
            MultiDropdown.Parent = ModuleOptionsContainer
            MultiDropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            MultiDropdown.BackgroundTransparency = 1.000
            MultiDropdown.BorderSizePixel = 0
            MultiDropdown.Position = UDim2.new(0, 0, 0.769933522, 0)
            MultiDropdown.Size = UDim2.new(0, 203, 0, 72)
            local MultiDropdownBack = Instance.new("Frame")
            MultiDropdownBack.Name = "MultiDropdownBack"
            MultiDropdownBack.Parent = MultiDropdown
            MultiDropdownBack.AnchorPoint = Vector2.new(0.5, 0.5)
            MultiDropdownBack.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            MultiDropdownBack.BackgroundTransparency = 0.300
            MultiDropdownBack.BorderSizePixel = 0
            MultiDropdownBack.Position = UDim2.new(0.5, 0, 0, 15)
            MultiDropdownBack.Size = UDim2.new(0, 184, 0, 22)
            local Name_8 = Instance.new("TextLabel")
            Name_8.Name = "Name"
            Name_8.Parent = MultiDropdownBack
            Name_8.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            Name_8.BackgroundTransparency = 1.000
            Name_8.BorderSizePixel = 0
            Name_8.Position = UDim2.new(0.0440070182, 0, 0.227272734, 0)
            Name_8.Size = UDim2.new(0.046920944, 140, 0.5, 0)
            Name_8.Font = Enum.Font.Code
            Name_8.Text = args.Name
            Name_8.TextColor3 = Color3.fromRGB(255, 255, 255)
            Name_8.TextSize = 14.000
            Name_8.TextXAlignment = Enum.TextXAlignment.Left
            Name_8.TextTruncate = Enum.TextTruncate.AtEnd
            local Expand_3 = Instance.new("ImageButton")
            Expand_3.Name = "Expand"
            Expand_3.Parent = MultiDropdownBack
            Expand_3.AnchorPoint = Vector2.new(0, 0.5)
            Expand_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Expand_3.BackgroundTransparency = 1.000
            Expand_3.BorderSizePixel = 0
            Expand_3.Position = UDim2.new(0.889967024, 0, 0.5, 0)
            Expand_3.Rotation = 0
            Expand_3.Size = UDim2.new(0, 19, 0, 19)
            Expand_3.ZIndex = 2
            Expand_3.Image = "http://www.roblox.com/asset/?id=6031094679"
            Expand_3.ScaleType = Enum.ScaleType.Fit
            local MultiDropdownValues = Instance.new("Frame")
            MultiDropdownValues.Name = "MultiDropdownValues"
            MultiDropdownValues.Parent = MultiDropdown
            MultiDropdownValues.AnchorPoint = Vector2.new(0.5, 0.5)
            MultiDropdownValues.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            MultiDropdownValues.BackgroundTransparency = 1.000
            MultiDropdownValues.BorderSizePixel = 0
            MultiDropdownValues.Position = UDim2.new(0.5, 0, 0, 37)
            MultiDropdownValues.Size = UDim2.new(0, 184, 0, 22)
            MultiDropdownValues.Visible = false
            local UIListLayout_6 = Instance.new("UIListLayout")
            UIListLayout_6.Parent = MultiDropdownValues
            UIListLayout_6.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder

            
            function dropdownapi.Update() 
                local size = UIListLayout_6.AbsoluteContentSize.Y
                if MultiDropdownValues.Visible then
                    MultiDropdown.Size = UDim2.new(0, 203, 0, 28 + size)
                else
                    MultiDropdown.Size = UDim2.new(0, 203, 0, 28)
                end
            end

            utils:connection(UIListLayout_6:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(dropdownapi.Update))

            function dropdownapi.ToggleValue(value)
                for i,v in next, dropdownapi.Values do
                    if v.Value == value then
                        v.Toggle()
                        --dropdownapi.Expand()
                        local tab = {}
                        for i,v in next, dropdownapi.Values do 
                            if v.Enabled then 
                                tab[#tab+1] = v.Value
                            end
                        end
                        Name_8.Text = args.Name .. (#tab~=0 and (" - " .. table.concat(tab, ", ")) or "")
                        if args.Function then
                            args.Function(tab)
                        end
                    end
                end
            end

            local function newValue(value)
                local valueapi = {Enabled = false}
                valueapi.Value = value
                local MultiDropdownValue = Instance.new("TextButton")
                MultiDropdownValue.Name = "MultiDropdownValue"
                MultiDropdownValue.Parent = MultiDropdownValues
                MultiDropdownValue.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
                MultiDropdownValue.BackgroundTransparency = 0.300
                MultiDropdownValue.BorderColor3 = Color3.fromRGB(6, 6, 6)
                MultiDropdownValue.Size = UDim2.new(0, 184, 0, 22)
                MultiDropdownValue.Font = Enum.Font.SourceSans
                MultiDropdownValue.Text = ""
                MultiDropdownValue.TextColor3 = Color3.fromRGB(0, 0, 0)
                MultiDropdownValue.TextSize = 14.000
                local Name_9 = Instance.new("TextLabel")
                Name_9.Name = "Name"
                Name_9.Parent = MultiDropdownValue
                Name_9.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
                Name_9.BackgroundTransparency = 1.000
                Name_9.BorderSizePixel = 0
                Name_9.Position = UDim2.new(0.0440070182, 0, 0.227272734, 0)
                Name_9.Size = UDim2.new(0.046920944, 140, 0.5, 0)
                Name_9.Font = Enum.Font.Code
                Name_9.Text = tostring(value)
                Name_9.TextColor3 = Color3.fromRGB(255, 255, 255)
                Name_9.TextSize = 14.000
                Name_9.TextXAlignment = Enum.TextXAlignment.Left
                local Selected = Instance.new("Frame")
                Selected.Name = "Selected"
                Selected.Parent = MultiDropdownValue
                Selected.AnchorPoint = Vector2.new(0, 0.5)
                Selected.BackgroundColor3 = Color3.fromRGB(2, 255, 137)
                Selected.Visible = false
                Selected.BorderSizePixel = 0
                Selected.Position = UDim2.new(0, 0, 0.5, 0)
                Selected.Size = UDim2.new(0, 2, 1, 0)

                utils:connection(ColorUpdate:Connect(function()
                    Selected.BackgroundColor3 = utils:getColorOfObject(Selected)
                end))
                
                function valueapi.Toggle() 
                    if valueapi.Enabled then
                        valueapi.Enabled = false
                        Selected.Visible = false
                    else
                        valueapi.Enabled = true
                        Selected.Visible = true
                    end
                end

                MultiDropdownValue.MouseButton1Click:Connect(function()
                    dropdownapi.ToggleValue(value)
                end)

                valueapi.SelectedInstance = Selected
                valueapi.Instance = MultiDropdownValue
                return valueapi
            end
            for i,v in next, args.List do 
                dropdownapi.Values[tostring(v)] = newValue(v)
            end

            for i,v in next, (args.Default or {}) do 
                dropdownapi.ToggleValue(v)
            end

            function dropdownapi.SetList(list)
                for i,v in next, dropdownapi.Values do
                    v.Instance:Destroy()
                    dropdownapi.Values[i] = nil
                end
                dropdownapi.Values = {}
                for i,v in next, list do 
                    dropdownapi.Values[tostring(v)] = newValue(v)
                end
            end

            function dropdownapi.Expand() 
                if dropdownapi.Expanded then 
                    dropdownapi.Expanded = false
                    MultiDropdownValues.Visible = false
                    Expand_3.Rotation = 0
                else
                    Expand_3.Rotation = 180
                    dropdownapi.Expanded = true
                    MultiDropdownValues.Visible = true
                end
                dropdownapi.Update() 
            end

            dropdownapi.Update()
            utils:connection(Expand_3.MouseButton1Click:Connect(dropdownapi.Expand))
            utils:addObject(args.Name .. "MultiDropdown", {Name = args.Name, Instance = MultiDropdown, Type = "MultiDropdown", OptionsButton = optionsbuttonname, API = dropdownapi, args = args})

            return dropdownapi
        end

        utils:addObject(optionsbuttonname .. "OptionsButton", {Name = optionsbuttonname, Instance = Module, Type = "OptionsButton", Window = windowname , API = buttonapi, args = args})

        return buttonapi
    end

    utils:addObject(windowname .. "Window", {Name = windowname, Instance = Window, Type = "Window" , API = windowapi, args = args})

    return windowapi
end

utils:connection(UIS.InputBegan:Connect(function(input)
    if UIS:GetFocusedTextBox() then 
        return 
    end

    if input.KeyCode == Enum.KeyCode.Unknown then
        return
    end
    
    local key = input.KeyCode.Name
    if key == 'Backspace' or key == 'Delete' or key == 'Escape' then
        key = nil
    end
    if GuiLibrary.Objects then
        for i,v in next, GuiLibrary.Objects do 
            if GuiLibrary.IsRecording then
                if v.Type == 'OptionsButton' and v.API.Recording then
                    GuiLibrary.IsRecording = false
                    v.API.Recording = false
                    v.API.SetBind(key)
                    return
                end
            else
                if v.Type == 'OptionsButton' and v.API.Bind == (key or "") then
                    v.API.Toggle()
                end
            end
        end
    end
end))

return GuiLibrary