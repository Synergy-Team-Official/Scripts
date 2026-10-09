local uis = game:GetService("UserInputService") 
local players = game:GetService("Players") 
local ws = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local run = game:GetService("RunService")
local stats = game:GetService("Stats")
local coregui = game:GetService("CoreGui")
local debris = game:GetService("Debris")
local tween_service = game:GetService("TweenService")
local sound_service = game:GetService("SoundService")

local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new 
local rect = Rect.new
local cfr = CFrame.new
local empty_cfr = cfr()
local point_object_space = empty_cfr.PointToObjectSpace
local angle = CFrame.Angles
local dim_offset = UDim2.fromOffset

local color = Color3.new
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local hsv = Color3.fromHSV
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local numseq = NumberSequence.new
local numkey = NumberSequenceKeypoint.new

local camera = ws.CurrentCamera
local lp = players.LocalPlayer 
local mouse = lp:GetMouse() 

local max = math.max 
local floor = math.floor 
local min = math.min 
local abs = math.abs 
local noise = math.noise
local rad = math.rad 
local random = math.random 
local pow = math.pow 
local sin = math.sin 
local pi = math.pi 
local tan = math.tan 
local atan2 = math.atan2 
local clamp = math.clamp 

local insert = table.insert 
local find = table.find 
local remove = table.remove
local concat = table.concat

local library = {
    directory = "milenium",
    folders = {
        "/fonts",
        "/configs",
    },
    flags = {},
    config_flags = {},
    connections = {},   
    notifications = {notifs = {}},
    current_open;
    unloaded = false;
    flag_counter = 0;
}

local themes = {
    preset = {
        accent = rgb(155, 150, 219),
    }, 

    utility = {
        accent = {
            BackgroundColor3 = {}, 	
            TextColor3 = {}, 
            ImageColor3 = {}, 
            ScrollBarImageColor3 = {} 
        },
    }
}

local keys = {
    [Enum.KeyCode.LeftShift] = "LS",
    [Enum.KeyCode.RightShift] = "RS",
    [Enum.KeyCode.LeftControl] = "LC",
    [Enum.KeyCode.RightControl] = "RC",
    [Enum.KeyCode.Insert] = "INS",
    [Enum.KeyCode.Backspace] = "BS",
    [Enum.KeyCode.Return] = "Ent",
    [Enum.KeyCode.LeftAlt] = "LA",
    [Enum.KeyCode.RightAlt] = "RA",
    [Enum.KeyCode.CapsLock] = "CAPS",
    [Enum.KeyCode.One] = "1",
    [Enum.KeyCode.Two] = "2",
    [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4",
    [Enum.KeyCode.Five] = "5",
    [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7",
    [Enum.KeyCode.Eight] = "8",
    [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.KeypadOne] = "Num1",
    [Enum.KeyCode.KeypadTwo] = "Num2",
    [Enum.KeyCode.KeypadThree] = "Num3",
    [Enum.KeyCode.KeypadFour] = "Num4",
    [Enum.KeyCode.KeypadFive] = "Num5",
    [Enum.KeyCode.KeypadSix] = "Num6",
    [Enum.KeyCode.KeypadSeven] = "Num7",
    [Enum.KeyCode.KeypadEight] = "Num8",
    [Enum.KeyCode.KeypadNine] = "Num9",
    [Enum.KeyCode.KeypadZero] = "Num0",
    [Enum.KeyCode.Minus] = "-",
    [Enum.KeyCode.Equals] = "=",
    [Enum.KeyCode.Tilde] = "~",
    [Enum.KeyCode.LeftBracket] = "[",
    [Enum.KeyCode.RightBracket] = "]",
    [Enum.KeyCode.RightParenthesis] = ")",
    [Enum.KeyCode.LeftParenthesis] = "(",
    [Enum.KeyCode.Semicolon] = ";",
    [Enum.KeyCode.Quote] = "'",
    [Enum.KeyCode.BackSlash] = "\\",
    [Enum.KeyCode.Comma] = ",",
    [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Slash] = "/",
    [Enum.KeyCode.Asterisk] = "*",
    [Enum.KeyCode.Plus] = "+",
    [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Backquote] = "`",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
    [Enum.KeyCode.Escape] = "ESC",
    [Enum.KeyCode.Space] = "SPC",
}
    
library.__index = library

library.is_mobile = uis.TouchEnabled and (not uis.MouseEnabled or not uis.KeyboardEnabled)
library.mobile_tabs = {}
library.mobile_columns = {}
library.mobile_pages = {}
library.mobile_sections = {}

local function ensure_folder(path)
    if type(isfolder) == "function" then
        local ok, result = pcall(isfolder, path)
        if ok and result then return true end
    end
    if type(makefolder) ~= "function" then return false end
    local ok = pcall(makefolder, path)
    if not ok and type(isfolder) == "function" then
        local exists, result = pcall(isfolder, path)
        return exists and result
    end
    return ok
end

local function has_file(path)
    if type(isfile) ~= "function" then return false end
    local ok, exists = pcall(isfile, path)
    return ok and exists
end

local function read_file(path)
    if not has_file(path) or type(readfile) ~= "function" then return nil end
    local ok, content = pcall(readfile, path)
    return ok and type(content) == "string" and content or nil
end

local function write_file(path, content)
    if type(writefile) ~= "function" then return false, "writefile unavailable" end
    local ok, err = pcall(writefile, path, content)
    if not ok then return false, tostring(err) end
    if err == false then return false, "writefile returned false" end
    return true
end

local function safe_callback(callback, ...)
    if type(callback) ~= "function" then return end
    local ok, result = pcall(callback, ...)
    if not ok then warn("[Millenium] callback error: " .. tostring(result)) end
    return ok, result
end

local function config_name(value)
    if type(value) ~= "string" then return nil end
    local name = value:match("^%s*(.-)%s*$")
    if not name or name == "" then return nil end
    name = name:gsub("%.cfg$", "")
    name = name:gsub("[^%w%._%-]", "_"):sub(1, 64)
    if name == "" or name == "." or name == ".." then return nil end
    return name
end

local function separator_option(options, default)
    if options.seperator ~= nil then return options.seperator end
    if options.Seperator ~= nil then return options.Seperator end
    return default
end

local function config_path(value)
    local name = config_name(value)
    return name and (library.directory .. "/configs/" .. name .. ".cfg") or nil
end

library.filesystem_available = ensure_folder(library.directory)
for _, path in ipairs(library.folders) do
    library.filesystem_available = ensure_folder(library.directory .. path) and library.filesystem_available
end

local flags = library.flags
local config_flags = library.config_flags
local notifications = library.notifications

local fonts = {
    small = Font.fromEnum(Enum.Font.Gotham),
    font = Font.fromEnum(Enum.Font.GothamBold)
}

do
    local function register_font(name, weight, file_name, url)
        if not library.filesystem_available or type(getcustomasset) ~= "function" then return nil end
        local ttf = library.directory .. "/fonts/" .. file_name
        local manifest = library.directory .. "/fonts/" .. name .. ".font"
        if not has_file(ttf) then
            local ok, content = pcall(function() return game:HttpGet(url) end)
            if not ok or type(content) ~= "string" or #content < 100 then return nil end
            local wrote = write_file(ttf, content)
            if not wrote then return nil end
        end
        local ok, asset = pcall(getcustomasset, ttf)
        if not ok or type(asset) ~= "string" then return nil end
        local data = {name = name, faces = {{name = "Normal", weight = weight, style = "Normal", assetId = asset}}}
        local encoded_ok, encoded = pcall(function() return http_service:JSONEncode(data) end)
        if not encoded_ok then return nil end
        local existing = read_file(manifest)
        if existing ~= encoded then
            if not write_file(manifest, encoded) then return nil end
        end
        local custom_ok, font_asset = pcall(getcustomasset, manifest)
        return custom_ok and font_asset or nil
    end

    local medium = register_font("Medium", 500, "Medium.ttf", "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Inter_28pt-Medium.ttf")
    local semibold = register_font("SemiBold", 600, "SemiBold.ttf", "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Inter_28pt-SemiBold.ttf")
    if medium then
        local ok, face = pcall(Font.new, medium, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        if ok then fonts.small = face end
    end
    if semibold then
        local ok, face = pcall(Font.new, semibold, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        if ok then fonts.font = face end
    end
end


function library:tween(obj, properties, easing_style, time)
    if library.unloaded or not obj then return nil end
    local tween = tween_service:Create(obj, TweenInfo.new(time or 0.25, easing_style or Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), properties)
    tween:Play()
    return tween
end

function library:resizify(frame) 
    local Frame = Instance.new("TextButton")
    Frame.Position = dim2(1, -10, 1, -10)
    Frame.BorderColor3 = rgb(0, 0, 0)
    Frame.Size = dim2(0, 10, 0, 10)
    Frame.BorderSizePixel = 0
    Frame.BackgroundColor3 = rgb(255, 255, 255)
    Frame.Parent = frame
    Frame.BackgroundTransparency = 1 
    Frame.Text = ""

    local resizing = false 
    local start_size 
    local start 
    local og_size = frame.Size  

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            start = input.Position
            start_size = frame.Size
        end
    end)

    Frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)

    library:connection(uis.InputChanged, function(input, game_event) 
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local viewport = (ws.CurrentCamera and ws.CurrentCamera.ViewportSize) or camera.ViewportSize
            local viewport_x = viewport.X
            local viewport_y = viewport.Y

            local current_size = dim2(
                start_size.X.Scale,
                math.clamp(
                    start_size.X.Offset + (input.Position.X - start.X),
                    min(og_size.X.Offset, viewport_x),
                    viewport_x
                ),
                start_size.Y.Scale,
                math.clamp(
                    start_size.Y.Offset + (input.Position.Y - start.Y),
                    min(og_size.Y.Offset, viewport_y),
                    viewport_y
                )
            )

            library:tween(frame, {Size = current_size}, Enum.EasingStyle.Linear, 0.05)
        end
    end)
end 

function library:next_flag()
    repeat
        library.flag_counter += 1
    until flags["flagnumber" .. library.flag_counter] == nil
    return "flagnumber" .. library.flag_counter
end 

function library:mouse_in_frame(uiobject)
    local y_cond = uiobject.AbsolutePosition.Y <= mouse.Y and mouse.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
    local x_cond = uiobject.AbsolutePosition.X <= mouse.X and mouse.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X

    return (y_cond and x_cond)
end

function library:draggify(frame)
    local dragging = false 
    local start_size = frame.Position
    local start 

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start = input.Position
            start_size = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    library:connection(uis.InputChanged, function(input, game_event) 
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local viewport = (ws.CurrentCamera and ws.CurrentCamera.ViewportSize) or camera.ViewportSize
            local viewport_x = viewport.X
            local viewport_y = viewport.Y

            local current_position = dim2(
                0,
                clamp(
                    start_size.X.Offset + (input.Position.X - start.X),
                    0,
                    max(0, viewport_x - frame.AbsoluteSize.X)
                ),
                0,
                math.clamp(
                    start_size.Y.Offset + (input.Position.Y - start.Y),
                    0,
                    max(0, viewport_y - frame.AbsoluteSize.Y)
                )
            )

            library:tween(frame, {Position = current_position}, Enum.EasingStyle.Linear, 0.05)
            library:close_element()
        end
    end)
end 

function library:convert(str)
    if type(str) ~= "string" then return end
    local values = {}

    for value in string.gmatch(str, "[^,]+") do
        local number = tonumber(value)
        if not number or number ~= number or number == math.huge or number == -math.huge then return end
        insert(values, number)
    end
    
    if #values == 4 then              
        return unpack(values)
    else 
        return
    end
end

function library:convert_enum(enum)
    if typeof(enum) == "EnumItem" then return enum end
    if type(enum) ~= "string" then return nil end
    local category, item = enum:match("^Enum%.([%w_]+)%.([%w_]+)$")
    if not category or not item then return nil end
    local ok, result = pcall(function() return Enum[category][item] end)
    return ok and result or nil
end

local config_holder;
function library:update_config_list()
    if not config_holder or type(listfiles) ~= "function" or not library.filesystem_available then return end
    local ok, files = pcall(listfiles, library.directory .. "/configs")
    if not ok or type(files) ~= "table" then return end
    local result, seen = {}, {}
    for _, file in ipairs(files) do
        if type(file) == "string" then
            local basename = file:gsub("\\", "/"):match("([^/]+)$")
            local name = basename and basename:match("^(.*)%.cfg$")
            if name and not seen[name] then
                seen[name] = true
                table.insert(result, name)
            end
        end
    end
    table.sort(result)
    config_holder.refresh_options(result)
end

function library:get_config()
    local data = {}
    for key, value in pairs(flags) do
        if key ~= "config_name_list" and key ~= "config_name_text" then
            if type(value) == "table" and value.key ~= nil then
                data[key] = {active = value.active == true, mode = value.mode, key = tostring(value.key)}
            elseif type(value) == "table" and typeof(value.Color) == "Color3" then
                data[key] = {Transparency = value.Transparency or 0, Color = value.Color:ToHex()}
            else
                data[key] = value
            end
        end
    end
    return http_service:JSONEncode(data)
end

function library:load_config(config_json)
    local ok, data = pcall(function() return http_service:JSONDecode(config_json) end)
    if not ok or type(data) ~= "table" then return false, "Invalid configuration JSON" end
    local errors = {}
    for key, value in pairs(data) do
        local setter = config_flags[key]
        if setter then
            local succeeded, err = pcall(function()
                if type(value) == "table" and type(value.Color) == "string" then
                    setter(hex(value.Color), math.clamp(tonumber(value.Transparency) or 0, 0, 1))
                else
                    setter(value)
                end
            end)
            if not succeeded then table.insert(errors, tostring(key) .. ": " .. tostring(err)) end
        end
    end
    if #errors > 0 then return false, table.concat(errors, "; ") end
    return true
end

function library:round(number, float) 
    if type(number) ~= "number" then return 0 end
    if type(float) ~= "number" or float <= 0 then float = 1 end
    local multiplier = 1 / float

    return floor(number * multiplier + 0.5) / multiplier
end 

function library:apply_theme(instance, theme, property) 
    if themes.utility[theme] and themes.utility[theme][property] then
        insert(themes.utility[theme][property], instance)
    end
end

function library:update_theme(theme, new_color)
    if typeof(new_color) ~= "Color3" or not themes.utility[theme] then return end
    local previous = themes.preset[theme]
    for property_name, instances in pairs(themes.utility[theme]) do
        for index = #instances, 1, -1 do
            local object = instances[index]
            if not object or not object.Parent then
                table.remove(instances, index)
            else
                local ok, current = pcall(function() return object[property_name] end)
                if ok and current == previous then
                    object[property_name] = new_color
                end
            end
        end
    end
    themes.preset[theme] = new_color
end

function library:connection(signal, callback)
    local connection = signal:Connect(callback)
    
    insert(library.connections, connection)

    return connection 
end

function library:close_element(new_path)
    local previous = library.current_open
    if previous ~= new_path then
        library.current_open = nil
        if previous and type(previous.set_visible) == "function" then
            previous.open = false
            previous.set_visible(false)
        end
        library.current_open = new_path
    end
end

function library:create(instance, options)
    local ins = Instance.new(instance) 
    
    for prop, value in options do 
        ins[prop] = value
    end
    
    return ins 
end

function library:mobile_popup_position(anchor, width, height, gap)
    local viewport = (ws.CurrentCamera and ws.CurrentCamera.ViewportSize) or vec2(800, 600)
    local left = clamp(anchor.AbsolutePosition.X, 6, max(6, viewport.X - width - 6))
    local top = anchor.AbsolutePosition.Y + anchor.AbsoluteSize.Y + (gap or 8)
    if top + height > viewport.Y - 8 then
        top = anchor.AbsolutePosition.Y - height - 8
    end
    top = clamp(top, min(48, viewport.Y * 0.12), max(min(48, viewport.Y * 0.12), viewport.Y - height - 8))
    return dim_offset(floor(left), floor(top))
end

function library:refresh_mobile_layout()
    if not library.is_mobile or not library.mobile_window then return end
    local win = library.mobile_window
    local it = win.items
    local viewport = ws.CurrentCamera.ViewportSize
    local narrow = viewport.X < 600
    local side = narrow and 56 or 140
    local header = narrow and 44 or 48
    local footer = 22
    local top = min(56, floor(viewport.Y * 0.13))
    local bottom = 12
    local width = max(1, min(860, viewport.X - (narrow and 14 or 24)))
    local height = max(1, min(narrow and 710 or 540, viewport.Y - top - bottom))
    local x = floor((viewport.X - width) / 2)
    local y = floor(top + max(0, (viewport.Y - top - bottom - height) / 2))

    local viewport_changed = not library.mobile_viewport or library.mobile_viewport ~= viewport
    library.mobile_viewport = viewport
    it.main.Size = dim_offset(width, height)
    if viewport_changed then it.main.Position = dim_offset(x, y) end
    it.side_frame.Size = dim2(0, side, 1, -footer)
    it.button_holder.Position = dim_offset(0, narrow and 48 or 55)
    it.button_holder.Size = dim2(1, 0, 1, -(narrow and 48 or 55))
    it.title.Text = narrow and win.name:sub(1, 1):upper() or string.format('<u>%s</u><font color="rgb(255, 255, 255)">%s</font>', win.name, win.suffix)
    it.title.TextSize = narrow and 26 or 20
    it.title.Size = dim2(1, 0, 0, narrow and 48 or 55)
    it.multi_holder.Position = dim_offset(side, 0)
    it.multi_holder.Size = dim2(1, -side, 0, header)
    it.global_fade.Position = dim_offset(side, header)
    it.global_fade.Size = dim2(1, -side, 1, -(header + footer))
    it.info.Size = dim2(1, 0, 0, footer)
    it.game.Visible = not narrow
    it.other_info.Visible = not narrow

    for _, child in it.button_holder:GetChildren() do
        if child:IsA('TextLabel') then
            child.Visible = not narrow
        end
    end

    for _, tab in library.mobile_tabs do
        if tab.items and tab.items.button then
            tab.items.name.Visible = not narrow
            tab.items.icon.Position = dim2(0, narrow and 8 or 10, 0.5, 0)
            tab.items.button.Size = dim2(1, 0, 0, narrow and 40 or 38)
            local panel = tab.items.tab_holder
            panel.Position = dim_offset(side, header)
            panel.Size = dim2(1, -side - 6, 1, -(header + footer + 6))
            tab.items.multi_section_button_holder.Size = dim2(1, 0, 1, 0)
        end
    end

    for _, page in library.mobile_pages do
        if page.Parent then
            local layout = page:FindFirstChildOfClass('UIListLayout')
            page.ScrollingEnabled = narrow
            page.ScrollingDirection = Enum.ScrollingDirection.Y
            page.AutomaticCanvasSize = narrow and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            page.CanvasSize = dim_offset(0, 0)
            if layout then
                layout.FillDirection = narrow and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
                layout.HorizontalFlex = Enum.UIFlexAlignment.Fill
                layout.VerticalFlex = narrow and Enum.UIFlexAlignment.None or Enum.UIFlexAlignment.Fill
            end
        end
    end

    for _, column in library.mobile_columns do
        if column.Parent then
            column.AutomaticSize = narrow and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            column.Size = narrow and dim2(1, 0, 0, 0) or dim2(0, 0, column:GetAttribute('MileniumSectionSize') or 1, 0)
        end
    end

    for _, sec in library.mobile_sections do
        if sec.outline.Parent then
            if narrow then
                local content = sec.layout.AbsoluteContentSize.Y
                local target = clamp(content + 82, 122, min(360, max(180, height * 0.67)))
                sec.outline.Size = dim2(1, 0, 0, target)
            else
                sec.outline.Size = dim2(0, 0, sec.size, -3)
            end
        end
    end
    if win.mobile_button then
        win.mobile_button.Position = dim2(1, -49, 0, max(8, floor(top * 0.20)))
    end
end

function library:queue_mobile_layout()
    if not library.is_mobile or library.mobile_refresh_pending then return end
    library.mobile_refresh_pending = true
    task.defer(function()
        library.mobile_refresh_pending = false
        if library.mobile_window and library.mobile_window.items.main.Parent then
            library:refresh_mobile_layout()
        end
    end)
end

function library:mobile_drag(handle, frame)
    local touch
    local origin
    local start
    handle.Active = true
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and not touch then
            touch = input
            origin = input.Position
            start = frame.Position
            library:close_element()
        end
    end)
    library:connection(uis.InputChanged, function(input)
        if input ~= touch then return end
        local view = ws.CurrentCamera.ViewportSize
        local next_x = clamp(start.X.Offset + input.Position.X - origin.X, 0, max(0, view.X - frame.AbsoluteSize.X))
        local next_y = clamp(start.Y.Offset + input.Position.Y - origin.Y, 0, max(0, view.Y - frame.AbsoluteSize.Y))
        frame.Position = dim_offset(next_x, next_y)
    end)
    library:connection(uis.InputEnded, function(input)
        if input == touch then touch = nil end
    end)
end

function library:unload_menu()
    if library.unloaded then return end
    library.unloaded = true
    library.current_open = nil
    for index = #library.connections, 1, -1 do
        local connection = library.connections[index]
        if connection then pcall(function() connection:Disconnect() end) end
        library.connections[index] = nil
    end
    if library.items then library.items:Destroy() end
    if library.other then library.other:Destroy() end
    library.items, library.other, library.mobile_window, library.cache = nil, nil, nil, nil
    table.clear(library.mobile_tabs)
    table.clear(library.mobile_pages)
    table.clear(library.mobile_columns)
    table.clear(library.mobile_sections)
    table.clear(library.notifications.notifs)
    for _, group in pairs(themes.utility) do
        for _, objects in pairs(group) do table.clear(objects) end
    end
end

library.unload = library.unload_menu

function library:window(properties)
    assert(not library.unloaded, "Millenium has been unloaded")
    assert(not library.items, "This Millenium instance already has a window; load a new instance for another window")
    properties = properties or {}
    local cfg = { 
        suffix = properties.suffix or properties.Suffix or "tech";
        name = properties.name or properties.Name or "nebula";
        game_name = properties.gameInfo or properties.game_info or properties.GameInfo or "Millenium";
        size = properties.size or properties.Size or dim2(0, 700, 0, 565);
        selected_tab;
        items = {};

        tween;
    }
    
    library[ "items" ] = library:create( "ScreenGui" , {
        Parent = coregui;
        Name = "\0";
        Enabled = true;
        ZIndexBehavior = Enum.ZIndexBehavior.Global;
        IgnoreGuiInset = true;
    });
    
    library[ "other" ] = library:create( "ScreenGui" , {
        Parent = coregui;
        Name = "\0";
        Enabled = false;
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        IgnoreGuiInset = true;
    }); 

    library.cache = library:create("Folder", {Name = "TabCache", Parent = library.other})
    local initial_viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(1440, 900)
    local items = cfg.items; do
        items[ "main" ] = library:create( "Frame" , {
            Parent = library[ "items" ];
            Size = cfg.size;
            Name = "\0";
            Position = dim_offset(
                floor((initial_viewport.X - (initial_viewport.X * cfg.size.X.Scale + cfg.size.X.Offset)) / 2),
                floor((initial_viewport.Y - (initial_viewport.Y * cfg.size.Y.Scale + cfg.size.Y.Offset)) / 2)
            );
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(14, 14, 16)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "main" ];
            CornerRadius = dim(0, 10)
        });
        
        library:create( "UIStroke" , {
            Color = rgb(23, 23, 29);
            Parent = items[ "main" ];
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        });
        
        items[ "side_frame" ] = library:create( "Frame" , {
            Parent = items[ "main" ];
            BackgroundTransparency = 1;
            Name = "\0";
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 196, 1, -25);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(14, 14, 16)
        });
        
        library:create( "Frame" , {
            AnchorPoint = vec2(1, 0);
            Parent = items[ "side_frame" ];
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 1, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(21, 21, 23)
        });
        
        items[ "button_holder" ] = library:create( library.is_mobile and "ScrollingFrame" or "Frame" , {
            Parent = items[ "side_frame" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 0, 60);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 1, -60);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        }); cfg.button_holder = items[ "button_holder" ];
        if library.is_mobile then
            items.button_holder.Active = true
            items.button_holder.ScrollingDirection = Enum.ScrollingDirection.Y
            items.button_holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
            items.button_holder.ScrollBarThickness = 2
            items.button_holder.CanvasSize = dim_offset(0, 0)
            items.button_holder.ClipsDescendants = true
        end
        
        library:create( "UIListLayout" , {
            Parent = items[ "button_holder" ];
            Padding = dim(0, 5);
            SortOrder = Enum.SortOrder.LayoutOrder
        });
        
        library:create( "UIPadding" , {
            PaddingTop = dim(0, 16);
            PaddingBottom = dim(0, 36);
            Parent = items[ "button_holder" ];
            PaddingRight = dim(0, 11);
            PaddingLeft = dim(0, 10)
        });

        local accent = themes.preset.accent
        items[ "title" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "side_frame" ];
            Name = "\0";
            Text = string.format('<u>%s</u><font color = "rgb(255, 255, 255)">%s</font>', cfg.name, cfg.suffix);
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 70);
            TextColor3 = themes.preset.accent;
            BorderSizePixel = 0;
            RichText = true;
            TextSize = 30;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "title" ], "accent", "TextColor3");
        
        items[ "multi_holder" ] = library:create( "Frame" , {
            Parent = items[ "main" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 196, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -196, 0, 56);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        }); cfg.multi_holder = items[ "multi_holder" ];
        
        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = items[ "multi_holder" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(21, 21, 23)
        });
        
        items[ "shadow" ] = library:create( "ImageLabel" , {
            ImageColor3 = rgb(0, 0, 0);
            ScaleType = Enum.ScaleType.Slice;
            Parent = items[ "main" ];
            BorderColor3 = rgb(0, 0, 0);
            Name = "\0";
            BackgroundColor3 = rgb(255, 255, 255);
            Size = dim2(1, 75, 1, 75);
            AnchorPoint = vec2(0.5, 0.5);
            Image = "rbxassetid://112971167999062";
            BackgroundTransparency = 1;
            Position = dim2(0.5, 0, 0.5, 0);
            SliceScale = 0.75;
            ZIndex = -100;
            BorderSizePixel = 0;
            SliceCenter = rect(vec2(112, 112), vec2(147, 147))
        });
        
        items[ "global_fade" ] = library:create( "Frame" , {
            Parent = items[ "main" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 196, 0, 56);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -196, 1, -81);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(14, 14, 16);
            ZIndex = 2;
        });                

        library:create( "UICorner" , {
            Parent = items[ "shadow" ];
            CornerRadius = dim(0, 5)
        });
        
        items[ "info" ] = library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = items[ "main" ];
            Name = "\0";
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 25);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(23, 23, 25)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "info" ];
            CornerRadius = dim(0, 10)
        });
        
        items[ "grey_fill" ] = library:create( "Frame" , {
            Name = "\0";
            Parent = items[ "info" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 6);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(23, 23, 25)
        });
        
        items[ "game" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            Parent = items[ "info" ];
            TextColor3 = rgb(72, 72, 73);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.game_name;
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            AnchorPoint = vec2(0, 0.5);
            Position = dim2(0, 10, 0.5, -1);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        }); 
        
        items[ "other_info" ] = library:create( "TextLabel" , {
            Parent = items[ "info" ];
            RichText = true;
            Name = "\0";
            TextColor3 = themes.preset.accent;
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name .. cfg.suffix;
            Size = dim2(1, 0, 0, 0);
            Position = dim2(0, -10, 0.5, -1);
            AnchorPoint = vec2(0, 0.5);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Right;
            AutomaticSize = Enum.AutomaticSize.XY;
            FontFace = fonts.font;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "other_info" ], "accent", "TextColor3");        
    end 

    do
        if library.is_mobile then
            library.mobile_window = cfg
            library:mobile_drag(items.title, items.main)
            cfg.mobile_button = library:create("TextButton", {
                Parent = library.items,
                Name = "MobileMenu",
                Text = "☰",
                FontFace = fonts.font,
                TextSize = 24,
                TextColor3 = rgb(255, 255, 255),
                BackgroundColor3 = rgb(25, 25, 29),
                BorderSizePixel = 0,
                Size = dim_offset(38, 38),
                Position = dim2(1, -49, 0, 8),
                ZIndex = 50
            })
            library:create("UICorner", {Parent = cfg.mobile_button, CornerRadius = dim(0, 9)})
            cfg.mobile_button.MouseButton1Click:Connect(function()
                items.main.Visible = not items.main.Visible
                if not items.main.Visible then library:close_element() end
            end)
            local viewport_connection
            local function track_viewport()
                if viewport_connection then viewport_connection:Disconnect() end
                if ws.CurrentCamera then
                    viewport_connection = library:connection(ws.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
                        library:queue_mobile_layout()
                    end)
                end
                library:queue_mobile_layout()
            end
            library:connection(ws:GetPropertyChangedSignal("CurrentCamera"), track_viewport)
            track_viewport()
            library:refresh_mobile_layout()
        else
            library:draggify(items[ "main" ])
            library:resizify(items[ "main" ])
        end
    end 

    function cfg.toggle_menu(bool) 
        if library.is_mobile then
            items.main.Visible = bool
            library:close_element()
        else
            library[ "items" ].Enabled = bool
        end
    end 
        
    return setmetatable(cfg, library)
end 

function library:tab(properties)
    local cfg = {
        name = properties.name or properties.Name or "visuals"; 
        icon = properties.icon or properties.Icon or "http://www.roblox.com/asset/?id=6034767608";
        
        tabs = properties.tabs or properties.Tabs or {"Main", "Misc.", "Settings"};
        pages = {}; 
        current_multi; 
        
        items = {};
    } 

    local items = cfg.items; do 
        items[ "tab_holder" ] = library:create( "Frame" , {
            Parent = library.cache;
            Name = "\0";
            Visible = false;
            BackgroundTransparency = 1;
            Position = dim2(0, 196, 0, 56);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -216, 1, -101);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        items[ "button" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "button_holder" ];
            AutoButtonColor = false;
            BackgroundTransparency = 1;
            Name = "\0";
            Size = dim2(1, 0, 0, 35);
            BorderSizePixel = 0;
            TextSize = 16;
            BackgroundColor3 = rgb(29, 29, 29)
        });
        
        items[ "icon" ] = library:create( "ImageLabel" , {
            ImageColor3 = rgb(72, 72, 73);
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "button" ];
            AnchorPoint = vec2(0, 0.5);
            Image = cfg.icon;
            BackgroundTransparency = 1;
            Position = dim2(0, 10, 0.5, 0);
            Name = "\0";
            Size = dim2(0, 22, 0, 22);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "icon" ], "accent", "ImageColor3");
        
        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(72, 72, 73);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "button" ];
            Name = "\0";
            Size = dim2(0, 0, 1, 0);
            Position = dim2(0, 40, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "button" ];
            CornerRadius = dim(0, 7)
        });
        
        library:create( "UIStroke" , {
            Color = rgb(23, 23, 29);
            Parent = items[ "button" ];
            Enabled = false;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        });

        items[ "multi_section_button_holder" ] = library:create( library.is_mobile and "ScrollingFrame" or "Frame" , {
            Parent = library.cache;
            BackgroundTransparency = 1;
            Name = "\0";
            Visible = false;
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        if library.is_mobile then
            local holder = items.multi_section_button_holder
            holder.Active = true
            holder.ClipsDescendants = true
            holder.ScrollBarThickness = 0
            holder.ScrollingDirection = Enum.ScrollingDirection.X
            holder.AutomaticCanvasSize = Enum.AutomaticSize.X
            holder.CanvasSize = dim_offset(0, 0)
        end
        
        library:create( "UIListLayout" , {
            Parent = items[ "multi_section_button_holder" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder;
            FillDirection = Enum.FillDirection.Horizontal
        });
        
        library:create( "UIPadding" , {
            PaddingTop = dim(0, 8);
            PaddingBottom = dim(0, 7);
            Parent = items[ "multi_section_button_holder" ];
            PaddingRight = dim(0, 7);
            PaddingLeft = dim(0, 7)
        });                        

        for _, section in cfg.tabs do
            local data = {items = {}} 

            local multi_items = data.items; do 
                multi_items[ "button" ] = library:create( "TextButton" , {
                    FontFace = fonts.font;
                    TextColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    AutoButtonColor = false;
                    Text = "";
                    Parent = items[ "multi_section_button_holder" ];
                    Name = "\0";
                    Size = dim2(0, 0, 0, 39);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.X;
                    TextSize = 16;
                    BackgroundColor3 = rgb(25, 25, 29)
                });
                
                multi_items[ "name" ] = library:create( "TextLabel" , {
                    FontFace = fonts.font;
                    TextColor3 = rgb(62, 62, 63);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = section;
                    Parent = multi_items[ "button" ];
                    Name = "\0";
                    Size = dim2(0, 0, 1, 0);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 16;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create( "UIPadding" , {
                    Parent = multi_items[ "name" ];
                    PaddingRight = dim(0, 5);
                    PaddingLeft = dim(0, 5)
                });
                
                multi_items[ "accent" ] = library:create( "Frame" , {
                    BorderColor3 = rgb(0, 0, 0);
                    AnchorPoint = vec2(0, 1);
                    Parent = multi_items[ "button" ];
                    BackgroundTransparency = 1;
                    Position = dim2(0, 10, 1, 4);
                    Name = "\0";
                    Size = dim2(1, -20, 0, 6);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                }); library:apply_theme(multi_items[ "accent" ], "accent", "BackgroundColor3");
                
                library:create( "UICorner" , {
                    Parent = multi_items[ "accent" ];
                    CornerRadius = dim(0, 999)
                });
                
                library:create( "UIPadding" , {
                    Parent = multi_items[ "button" ];
                    PaddingRight = dim(0, 10);
                    PaddingLeft = dim(0, 10)
                });
                
                library:create( "UICorner" , {
                    Parent = multi_items[ "button" ];
                    CornerRadius = dim(0, 7)
                }); 

                multi_items[ "tab" ] = library:create( "Frame" , {
                    Parent = library.cache;
                    BackgroundTransparency = 1;
                    Name = "\0";
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -20, 1, -20);
                    BorderSizePixel = 0;
                    Visible = false;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create( "UIListLayout" , {
                    FillDirection = Enum.FillDirection.Vertical;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    Parent = multi_items[ "tab" ];
                    Padding = dim(0, 7);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    VerticalFlex = Enum.UIFlexAlignment.Fill
                });
                
                library:create( "UIPadding" , {
                    PaddingTop = dim(0, 7);
                    PaddingBottom = dim(0, 7);
                    Parent = multi_items[ "tab" ];
                    PaddingRight = dim(0, 7);
                    PaddingLeft = dim(0, 7)
                });
            end

            data.text = multi_items[ "name" ]
            data.accent = multi_items[ "accent" ]
            data.button = multi_items[ "button" ]
            data.page = multi_items[ "tab" ]
            data.parent = setmetatable(data, library):sub_tab({}).items[ "tab_parent" ]
            
            function data.open_page()
                local page = cfg.current_multi; 
                
                if page and page.text ~= data.text then 
                    self.items[ "global_fade" ].BackgroundTransparency = 0
                    library:tween(self.items[ "global_fade" ], {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.4)
                    
                    local old_size = page.page.Size
                    page.page.Size = dim2(1, -20, 1, -20)
                end

                if page then
                    library:tween(page.text, {TextColor3 = rgb(62, 62, 63)})
                    library:tween(page.accent, {BackgroundTransparency = 1})
                    library:tween(page.button, {BackgroundTransparency = 1})

                    page.page.Visible = false
                    page.page.Parent = library[ "cache" ] 
                end 
                
                library:tween(data.text, {TextColor3 = rgb(255, 255, 255)})
                library:tween(data.accent, {BackgroundTransparency = 0})
                library:tween(data.button, {BackgroundTransparency = 0})
                library:tween(data.page, {Size = dim2(1, 0, 1, 0)}, Enum.EasingStyle.Quad, 0.4)

                data.page.Visible = true
                data.page.Parent = items["tab_holder"]

                cfg.current_multi = data

                library:close_element()
            end

            multi_items[ "button" ].MouseButton1Down:Connect(function()
                data.open_page() 
            end)

            cfg.pages[#cfg.pages + 1] = setmetatable(data, library)
        end 

        if cfg.pages[1] then cfg.pages[1].open_page() end
    end 

    function cfg.open_tab() 
        local selected_tab = self.selected_tab
        
        if selected_tab then 
            if selected_tab[ 4 ] ~= items[ "tab_holder" ] then 
                self.items[ "global_fade" ].BackgroundTransparency = 0
                
                library:tween(self.items[ "global_fade" ], {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.4)
                selected_tab[ 4 ].Size = library.is_mobile and selected_tab[ 4 ].Size or dim2(1, -216, 1, -101)
            end

            library:tween(selected_tab[ 1 ], {BackgroundTransparency = 1})
            library:tween(selected_tab[ 2 ], {ImageColor3 = rgb(72, 72, 73)})
            library:tween(selected_tab[ 3 ], {TextColor3 = rgb(72, 72, 73)})

            selected_tab[ 4 ].Visible = false
            selected_tab[ 4 ].Parent = library[ "cache" ]
            selected_tab[ 5 ].Visible = false
            selected_tab[ 5 ].Parent = library[ "cache" ]
        end

        library:tween(items[ "button" ], {BackgroundTransparency = 0})
        library:tween(items[ "icon" ], {ImageColor3 = themes.preset.accent})
        library:tween(items[ "name" ], {TextColor3 = rgb(255, 255, 255)})
        if not library.is_mobile then
            library:tween(items[ "tab_holder" ], {Size = dim2(1, -196, 1, -81)}, Enum.EasingStyle.Quad, 0.4)
        end
        
        items[ "tab_holder" ].Visible = true 
        items[ "tab_holder" ].Parent = self.items[ "main" ]
        items[ "multi_section_button_holder" ].Visible = true 
        items[ "multi_section_button_holder" ].Parent = self.items[ "multi_holder" ]

        self.selected_tab = {
            items[ "button" ];
            items[ "icon" ];
            items[ "name" ];
            items[ "tab_holder" ];
            items[ "multi_section_button_holder" ];
        }

        library:close_element()
        if library.is_mobile then library:queue_mobile_layout() end
    end

    items[ "button" ].MouseButton1Down:Connect(function()
        cfg.open_tab()
    end)
    
    if not self.selected_tab then 
        cfg.open_tab(true) 
    end

    if library.is_mobile then
        insert(library.mobile_tabs, cfg)
        library:queue_mobile_layout()
    end
    return unpack(cfg.pages)
end

function library:seperator(properties)
    local cfg = {items = {}, name = properties.Name or properties.name or "General"}

    local items = cfg.items do 
        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(72, 72, 73);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = self.items[ "button_holder" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            Position = dim2(0, 40, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0; 
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });                
    end;    

    return setmetatable(cfg, library)
end 

function library:column(properties) 
    local cfg = {items = {}, size = properties.size or 1}

    local items = cfg.items; do     
        items[ "column" ] = library:create( "Frame" , {
            Parent = self[ "parent" ] or self.items["tab_parent"];
            BackgroundTransparency = 1;
            Name = "\0";
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, cfg.size, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        if library.is_mobile then
            items.column:SetAttribute("MileniumSectionSize", cfg.size)
            insert(library.mobile_columns, items.column)
            library:queue_mobile_layout()
        end
        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 10);
            Parent = items[ "column" ]
        });
        
        library:create( "UIListLayout" , {
            Parent = items[ "column" ];
            HorizontalFlex = Enum.UIFlexAlignment.Fill;
            Padding = dim(0, 10);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder
        });
    end 

    return setmetatable(cfg, library)
end 

function library:sub_tab(properties) 
    local cfg = {items = {}, order = properties.order or 0; size = properties.size or 1}

    local items = cfg.items; do 
        items[ "tab_parent" ] = library:create( library.is_mobile and "ScrollingFrame" or "Frame" , {
            Parent = self.items[ "tab" ];
            BackgroundTransparency = 1;
            Name = "\0";
            Size = dim2(0,0,cfg.size,0);
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            Visible = true;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        if library.is_mobile then
            local page = items.tab_parent
            page.Active = true
            page.ScrollBarThickness = 3
            page.ScrollingDirection = Enum.ScrollingDirection.Y
            page.CanvasSize = dim_offset(0, 0)
            insert(library.mobile_pages, page)
        end
        library:create( "UIListLayout" , {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalFlex = Enum.UIFlexAlignment.Fill;
            VerticalFlex = Enum.UIFlexAlignment.Fill;
            Parent = items[ "tab_parent" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder;
        });
    end

    return setmetatable(cfg, library)
end 

function library:section(properties)
    local cfg = {
        name = properties.name or properties.Name or "section"; 
        side = properties.side or properties.Side or "left";
        default = properties.default or properties.Default or false;
        size = properties.size or properties.Size or self.size or 0.5; 
        icon = properties.icon or properties.Icon or "http://www.roblox.com/asset/?id=6022668898";
        fading_toggle = properties.fading or properties.Fading or false;
        items = {};
    };
    
    local elements_layout
    local items = cfg.items; do 
        items[ "outline" ] = library:create( "Frame" , {
            Name = "\0";
            Parent = self.items[ "column" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, cfg.size, -3);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(25, 25, 29)
        });

        library:create( "UICorner" , {
            Parent = items[ "outline" ];
            CornerRadius = dim(0, 7)
        });
        
        items[ "inline" ] = library:create( "Frame" , {
            Parent = items[ "outline" ];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(22, 22, 24)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "inline" ];
            CornerRadius = dim(0, 7)
        });
        
        items[ "scrolling" ] = library:create( "ScrollingFrame" , {
            ScrollBarImageColor3 = rgb(44, 44, 46);
            Active = true;
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            ScrollBarThickness = 2;
            Parent = items[ "inline" ];
            Name = "\0";
            Size = dim2(1, 0, 1, -40);
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 0, 35);
            BackgroundColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            CanvasSize = dim2(0, 0, 0, 0)
        });
        
        items[ "elements" ] = library:create( "Frame" , {
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "scrolling" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 10, 0, 10);
            Size = dim2(1, -20, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        elements_layout = library:create( "UIListLayout" , {
            Parent = items[ "elements" ];
            Padding = dim(0, 10);
            SortOrder = Enum.SortOrder.LayoutOrder
        });
        
        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 15);
            Parent = items[ "elements" ]
        });
        
        items[ "button" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            Parent = items[ "outline" ];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            Size = dim2(1, -2, 0, 35);
            BorderSizePixel = 0;
            TextSize = 16;
            BackgroundColor3 = rgb(19, 19, 21)
        });
        
        library:create( "UIStroke" , {
            Color = rgb(23, 23, 29);
            Parent = items[ "button" ];
            Enabled = false;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        });
        
        library:create( "UICorner" , {
            Parent = items[ "button" ];
            CornerRadius = dim(0, 7)
        });
        
        items[ "Icon" ] = library:create( "ImageLabel" , {
            ImageColor3 = themes.preset.accent;
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "button" ];
            AnchorPoint = vec2(0, 0.5);
            Image = cfg.icon;
            BackgroundTransparency = 1;
            Position = dim2(0, 10, 0.5, 0);
            Name = "\0";
            Size = dim2(0, 22, 0, 22);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "Icon" ], "accent", "ImageColor3");
        
        items[ "section_title" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "button" ];
            Name = "\0";
            Size = dim2(0, 0, 1, 0);
            Position = dim2(0, 40, 0, -1);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = items[ "button" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(36, 36, 37)
        });
        
        if cfg.fading_toggle then 
            items[ "toggle" ] = library:create( "TextButton" , {
                FontFace = fonts.small;
                TextColor3 = rgb(0, 0, 0);
                BorderColor3 = rgb(0, 0, 0);
                AutoButtonColor = false;
                Text = "";
                AnchorPoint = vec2(1, 0.5);
                Parent = items[ "button" ];
                Name = "\0";
                Position = dim2(1, -9, 0.5, 0);
                Size = dim2(0, 36, 0, 18);
                BorderSizePixel = 0;
                TextSize = 14;
                BackgroundColor3 = rgb(58, 58, 62)
            });  library:apply_theme(items[ "toggle" ], "accent", "BackgroundColor3");
            
            library:create( "UICorner" , {
                Parent = items[ "toggle" ];
                CornerRadius = dim(0, 999)
            });
            
            items[ "toggle_outline" ] = library:create( "Frame" , {
                Parent = items[ "toggle" ];
                Size = dim2(1, -2, 1, -2);
                Name = "\0";
                BorderMode = Enum.BorderMode.Inset;
                BorderColor3 = rgb(0, 0, 0);
                Position = dim2(0, 1, 0, 1);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(50, 50, 50)
            });  library:apply_theme(items[ "toggle_outline" ], "accent", "BackgroundColor3");
            
            library:create( "UICorner" , {
                Parent = items[ "toggle_outline" ];
                CornerRadius = dim(0, 999)
            });
            
            library:create( "UIGradient" , {
                Color = rgbseq{rgbkey(0, rgb(211, 211, 211)), rgbkey(1, rgb(211, 211, 211))};
                Parent = items[ "toggle_outline" ]
            });
            
            items[ "toggle_circle" ] = library:create( "Frame" , {
                Parent = items[ "toggle_outline" ];
                Name = "\0";
                Position = dim2(0, 2, 0, 2);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, 12, 0, 12);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(86, 86, 88)
            });
            
            library:create( "UICorner" , {
                Parent = items[ "toggle_circle" ];
                CornerRadius = dim(0, 999)
            });
            
            library:create( "UICorner" , {
                Parent = items[ "outline" ];
                CornerRadius = dim(0, 7)
            });
        
            items[ "fade" ] = library:create( "Frame" , {
                Parent = items[ "outline" ];
                BackgroundTransparency = 0.800000011920929;
                Name = "\0";
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(1, 0, 1, 0);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(0, 0, 0)
            });
            
            library:create( "UICorner" , {
                Parent = items[ "fade" ];
                CornerRadius = dim(0, 7)
            });
        end 
    end;

    if cfg.fading_toggle then
        items[ "toggle" ].MouseButton1Click:Connect(function()
            cfg.default = not cfg.default
            cfg.toggle_section(cfg.default)
        end)
        items[ "button" ].MouseButton1Click:Connect(function()
            cfg.default = not cfg.default 
            cfg.toggle_section(cfg.default) 
        end)

        function cfg.toggle_section(bool)
            library:tween(items[ "toggle" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(58, 58, 62)}, Enum.EasingStyle.Quad)
            library:tween(items[ "toggle_outline" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(50, 50, 50)}, Enum.EasingStyle.Quad)
            library:tween(items[ "toggle_circle" ], {BackgroundColor3 = bool and rgb(255, 255, 255) or rgb(86, 86, 88), Position = bool and dim2(1, -14, 0, 2) or dim2(0, 2, 0, 2)}, Enum.EasingStyle.Quad)
            library:tween(items[ "fade" ], {BackgroundTransparency = bool and 1 or 0.8}, Enum.EasingStyle.Quad)
        end
        cfg.toggle_section(cfg.default)
    end

    if library.is_mobile then
        insert(library.mobile_sections, {outline = items.outline, layout = elements_layout, size = cfg.size})
        library:connection(elements_layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            library:queue_mobile_layout()
        end)
        library:queue_mobile_layout()
    end
    return setmetatable(cfg, library)
end  

function library:toggle(options) 
    local cfg = {
        enabled = options.default == true,
        name = options.name or "Toggle",
        info = options.info or nil,
        flag = options.flag or library:next_flag(),
        
        type = options.type and string.lower(options.type) or "toggle";

        default = options.default or false,
        folding = options.folding or false, 
        callback = options.callback or function() end,

        items = {};
        seperator = options.seperator or options.Seperator or false;
    }

    flags[cfg.flag] = cfg.default

    local items = cfg.items; do
        items[ "toggle" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "toggle" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        if cfg.info then 
            items[ "info" ] = library:create( "TextLabel" , {
                FontFace = fonts.small;
                TextColor3 = rgb(130, 130, 130);
                BorderColor3 = rgb(0, 0, 0);
                TextWrapped = true;
                Text = cfg.info;
                Parent = items[ "toggle" ];
                Name = "\0";
                Position = dim2(0, 5, 0, 17);
                Size = dim2(1, -10, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                TextSize = 16;
                BackgroundColor3 = rgb(255, 255, 255)
            });
        end 
        
        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });
        
        items[ "right_components" ] = library:create( "Frame" , {
            Parent = items[ "toggle" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIListLayout" , {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            Parent = items[ "right_components" ];
            Padding = dim(0, 9);
            SortOrder = Enum.SortOrder.LayoutOrder
        });
        
        if cfg.type == "checkbox" then 
            items[ "toggle_button" ] = library:create( "TextButton" , {
                FontFace = fonts.small;
                TextColor3 = rgb(0, 0, 0);
                BorderColor3 = rgb(0, 0, 0);
                Text = "";
                LayoutOrder = 2;
                AutoButtonColor = false;
                AnchorPoint = vec2(1, 0);
                Parent = items[ "right_components" ];
                Name = "\0";
                Position = dim2(1, 0, 0, 0);
                Size = dim2(0, 16, 0, 16);
                BorderSizePixel = 0;
                TextSize = 14;
                BackgroundColor3 = rgb(67, 67, 68)
            }); library:apply_theme(items[ "toggle_button" ], "accent", "BackgroundColor3");
            
            library:create( "UICorner" , {
                Parent = items[ "toggle_button" ];
                CornerRadius = dim(0, 4)
            });
            
            items[ "outline" ] = library:create( "Frame" , {
                Parent = items[ "toggle_button" ];
                Size = dim2(1, -2, 1, -2);
                Name = "\0";
                BorderMode = Enum.BorderMode.Inset;
                BorderColor3 = rgb(0, 0, 0);
                Position = dim2(0, 1, 0, 1);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(22, 22, 24)
            }); library:apply_theme(items[ "outline" ], "accent", "BackgroundColor3");
            
            items[ "tick" ] = library:create( "ImageLabel" , {
                ImageTransparency = 1;
                BorderColor3 = rgb(0, 0, 0);
                Image = "rbxassetid://111862698467575";
                BackgroundTransparency = 1;
                Position = dim2(0, -1, 0, 0);
                Parent = items[ "outline" ];
                Size = dim2(1, 2, 1, 2);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255);
                ZIndex = 1;
            });

            library:create( "UICorner" , {
                Parent = items[ "outline" ];
                CornerRadius = dim(0, 4)
            });
            
            library:create( "UIGradient" , {
                Enabled = false;
                Parent = items[ "outline" ];
                Color = rgbseq{rgbkey(0, rgb(211, 211, 211)), rgbkey(1, rgb(211, 211, 211))}
            });  
        else 
            items[ "toggle_button" ] = library:create( "TextButton" , {
                FontFace = fonts.font;
                TextColor3 = rgb(0, 0, 0);
                BorderColor3 = rgb(0, 0, 0);
                Text = "";
                LayoutOrder = 2;
                AnchorPoint = vec2(1, 0.5);
                Parent = items[ "right_components" ];
                Name = "\0";
                Position = dim2(1, -9, 0.5, 0);
                Size = dim2(0, 36, 0, 18);
                BorderSizePixel = 0;
                TextSize = 14;
                BackgroundColor3 = themes.preset.accent
            }); library:apply_theme(items[ "toggle_button" ], "accent", "BackgroundColor3");
            
            library:create( "UICorner" , {
                Parent = items[ "toggle_button" ];
                CornerRadius = dim(0, 999)
            });
            
            items[ "inline" ] = library:create( "Frame" , {
                Parent = items[ "toggle_button" ];
                Size = dim2(1, -2, 1, -2);
                Name = "\0";
                BorderMode = Enum.BorderMode.Inset;
                BorderColor3 = rgb(0, 0, 0);
                Position = dim2(0, 1, 0, 1);
                BorderSizePixel = 0;
                BackgroundColor3 = themes.preset.accent
            }); library:apply_theme(items[ "inline" ], "accent", "BackgroundColor3");
            
            library:create( "UICorner" , {
                Parent = items[ "inline" ];
                CornerRadius = dim(0, 999)
            });
            
            library:create( "UIGradient" , {
                Color = rgbseq{rgbkey(0, rgb(211, 211, 211)), rgbkey(1, rgb(211, 211, 211))};
                Parent = items[ "inline" ]
            });
            
            items[ "circle" ] = library:create( "Frame" , {
                Parent = items[ "inline" ];
                Name = "\0";
                Position = dim2(1, -14, 0, 2);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, 12, 0, 12);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });
            
            library:create( "UICorner" , {
                Parent = items[ "circle" ];
                CornerRadius = dim(0, 999)
            });                        
        end 
    end;
    
    function cfg.set(bool)
        bool = bool == true
        cfg.enabled = bool
        if cfg.type == "checkbox" then 
            library:tween(items[ "tick" ], {Rotation = bool and 0 or 45, ImageTransparency = bool and 0 or 1})
            library:tween(items[ "toggle_button" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(67, 67, 68)})
            library:tween(items[ "outline" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(22, 22, 24)})
        else
            library:tween(items[ "toggle_button" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(58, 58, 62)}, Enum.EasingStyle.Quad)
            library:tween(items[ "inline" ], {BackgroundColor3 = bool and themes.preset.accent or rgb(50, 50, 50)}, Enum.EasingStyle.Quad)
            library:tween(items[ "circle" ], {BackgroundColor3 = bool and rgb(255, 255, 255) or rgb(86, 86, 88), Position = bool and dim2(1, -14, 0, 2) or dim2(0, 2, 0, 2)}, Enum.EasingStyle.Quad)
        end

        safe_callback(cfg.callback, bool)

        if cfg.folding and cfg.items.elements then
            cfg.items.elements.Visible = bool
        end

        flags[cfg.flag] = bool
    end 
    
    if cfg.folding then
        items.elements = library:create("Frame", {
            Parent = self.items.elements,
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = cfg.enabled,
        })
        library:create("UIListLayout", {Parent = items.elements, Padding = dim(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
    end
    if library.is_mobile then
        items.name.TextTruncate = Enum.TextTruncate.AtEnd
        items.name.AutomaticSize = Enum.AutomaticSize.Y
        items.name.Size = dim2(1, -140, 0, 20)
    end
    items[ "toggle" ].MouseButton1Click:Connect(function()
        cfg.set(not cfg.enabled)
    end)

    items[ "toggle_button" ].MouseButton1Click:Connect(function()
        cfg.set(not cfg.enabled)
    end)
    
    if cfg.seperator then
        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = self.items[ "elements" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 1, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(36, 36, 37)
        });
    end

    cfg.set(cfg.default)

    config_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, library)
end 

function library:slider(options) 
    local cfg = {
        name = options.name or nil,
        suffix = options.suffix or "",
        flag = options.flag or library:next_flag(),
        callback = options.callback or function() end, 
        info = options.info or nil; 

        min = options.min or options.minimum or 0,
        max = options.max or options.maximum or 100,
        intervals = options.interval or options.decimal or 1,
        default = options.default or 10,
        value = options.default or 10, 
        seperator = separator_option(options, true);

        dragging = false,
        items = {}
    } 

    cfg.min = tonumber(cfg.min) or 0
    cfg.max = tonumber(cfg.max) or 100
    if cfg.min > cfg.max then cfg.min, cfg.max = cfg.max, cfg.min end
    cfg.intervals = tonumber(cfg.intervals) or 1
    if cfg.intervals <= 0 then cfg.intervals = 1 end
    cfg.default = tonumber(cfg.default) or cfg.min
    flags[cfg.flag] = cfg.default

    local items = cfg.items; do
        items[ "slider_object" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "slider_object" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        if cfg.info then 
            items[ "info" ] = library:create( "TextLabel" , {
                FontFace = fonts.small;
                TextColor3 = rgb(130, 130, 130);
                BorderColor3 = rgb(0, 0, 0);
                TextWrapped = true;
                Text = cfg.info;
                Parent = items[ "slider_object" ];
                Name = "\0";
                Position = dim2(0, 5, 0, 37);
                Size = dim2(1, -10, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                TextSize = 16;
                BackgroundColor3 = rgb(255, 255, 255)
            });
        end 

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });
        
        items[ "right_components" ] = library:create( "Frame" , {
            Parent = items[ "slider_object" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 4, 0, 23);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 12);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIListLayout" , {
            Parent = items[ "right_components" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder;
            FillDirection = Enum.FillDirection.Horizontal
        });
        
        items[ "slider" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            AnchorPoint = vec2(1, 0);
            Parent = items[ "right_components" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            Size = dim2(1, -4, 0, 4);
            BorderSizePixel = 0;
            TextSize = 14;
            BackgroundColor3 = rgb(33, 33, 35)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "slider" ];
            CornerRadius = dim(0, 999)
        });
        
        items[ "fill" ] = library:create( "Frame" , {
            Name = "\0";
            Parent = items[ "slider" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0.5, 0, 0, 4);
            BorderSizePixel = 0;
            BackgroundColor3 = themes.preset.accent
        });  library:apply_theme(items[ "fill" ], "accent", "BackgroundColor3");
        
        library:create( "UICorner" , {
            Parent = items[ "fill" ];
            CornerRadius = dim(0, 999)
        });
        
        items[ "circle" ] = library:create( "Frame" , {
            AnchorPoint = vec2(0.5, 0.5);
            Parent = items[ "fill" ];
            Name = "\0";
            Position = dim2(1, 0, 0.5, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 12, 0, 12);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(244, 244, 244)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "circle" ];
            CornerRadius = dim(0, 999)
        });
        
        library:create( "UIPadding" , {
            Parent = items[ "right_components" ];
            PaddingTop = dim(0, 4)
        });
        
        items[ "value" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(72, 72, 73);
            BorderColor3 = rgb(0, 0, 0);
            Text = "50%";
            Parent = items[ "slider_object" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            Position = dim2(0, 6, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Right;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIPadding" , {
            Parent = items[ "value" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });                
    end 

    function cfg.set(value)
        local numeric = tonumber(value)
        if not numeric or numeric ~= numeric or numeric == math.huge or numeric == -math.huge then return end
        local range = cfg.max - cfg.min
        cfg.value = clamp(cfg.min + library:round(numeric - cfg.min, cfg.intervals), cfg.min, cfg.max)
        local fraction = range > 0 and (cfg.value - cfg.min) / range or 0
        items["fill"].Size = dim2(fraction, cfg.value == cfg.min and 0 or -4, 0, 2)
        items[ "value" ].Text = tostring(cfg.value) .. cfg.suffix

        flags[cfg.flag] = cfg.value
        safe_callback(cfg.callback, flags[cfg.flag])
    end

    if library.is_mobile then
        items.slider.Size = dim2(1, -4, 0, 20)
        local touch
        local function update(input)
            local width = max(1, items.slider.AbsoluteSize.X)
            local fraction = clamp((input.Position.X - items.slider.AbsolutePosition.X) / width, 0, 1)
            cfg.set(cfg.min + (cfg.max - cfg.min) * fraction)
        end
        items.slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch and not touch then
                touch = input
                update(input)
                library:tween(items.value, {TextColor3 = rgb(255, 255, 255)}, Enum.EasingStyle.Quad, 0.2)
            end
        end)
        library:connection(uis.InputChanged, function(input)
            if input == touch then update(input) end
        end)
        library:connection(uis.InputEnded, function(input)
            if input == touch then
                touch = nil
                library:tween(items.value, {TextColor3 = rgb(72, 72, 73)}, Enum.EasingStyle.Quad, 0.2)
            end
        end)
    else
        items[ "slider" ].MouseButton1Down:Connect(function()
            cfg.dragging = true
            library:tween(items[ "value" ], {TextColor3 = rgb(255, 255, 255)}, Enum.EasingStyle.Quad, 0.2)
        end)
        library:connection(uis.InputChanged, function(input)
            if cfg.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local size_x = clamp((input.Position.X - items[ "slider" ].AbsolutePosition.X) / max(1, items[ "slider" ].AbsoluteSize.X), 0, 1)
                cfg.set(((cfg.max - cfg.min) * size_x) + cfg.min)
            end
        end)
        library:connection(uis.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                cfg.dragging = false
                library:tween(items[ "value" ], {TextColor3 = rgb(72, 72, 73)}, Enum.EasingStyle.Quad, 0.2)
            end
        end)
    end

    if cfg.seperator then 
        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = self.items[ "elements" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 1, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(36, 36, 37)
        });
    end 

    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, library)
end 

function library:dropdown(options) 
    local cfg = {
        name = options.name or nil;
        info = options.info or nil;
        flag = options.flag or library:next_flag();
        options = options.items or {""};
        callback = options.callback or function() end;
        multi = options.multi or false;
        scrolling = options.scrolling or false;

        width = options.width or 130;

        open = false;
        option_instances = {};
        multi_items = {};
        ignore = options.ignore or false;
        items = {};
        y_size;
        seperator = separator_option(options, true);
    }   

    cfg.default = options.default ~= nil and options.default or (cfg.multi and (cfg.options[1] and {cfg.options[1]} or {}) or cfg.options[1] or "None")
    flags[cfg.flag] = cfg.default

    local items = cfg.items; do 
        items[ "dropdown_object" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = "Dropdown";
            Parent = items[ "dropdown_object" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        if cfg.info then 
            items[ "info" ] = library:create( "TextLabel" , {
                FontFace = fonts.small;
                TextColor3 = rgb(130, 130, 130);
                BorderColor3 = rgb(0, 0, 0);
                TextWrapped = true;
                Text = cfg.info;
                Parent = items[ "dropdown_object" ];
                Name = "\0";
                Position = dim2(0, 5, 0, 17);
                Size = dim2(1, -10, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                TextSize = 16;
                BackgroundColor3 = rgb(255, 255, 255)
            });
        end 

        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });
        
        items[ "right_components" ] = library:create( "Frame" , {
            Parent = items[ "dropdown_object" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIListLayout" , {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            Parent = items[ "right_components" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder
        });
        
        items[ "dropdown" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            AnchorPoint = vec2(1, 0);
            Parent = items[ "right_components" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            Size = dim2(0, cfg.width, 0, 16);
            BorderSizePixel = 0;
            TextSize = 14;
            BackgroundColor3 = rgb(33, 33, 35)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "dropdown" ];
            CornerRadius = dim(0, 4)
        });
        
        items[ "sub_text" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(86, 86, 87);
            BorderColor3 = rgb(0, 0, 0);
            Text = "awdawdawdawdawdawdawdaw";
            Parent = items[ "dropdown" ];
            Name = "\0";
            Size = dim2(1, -12, 0, 0);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextTruncate = Enum.TextTruncate.AtEnd;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIPadding" , {
            Parent = items[ "sub_text" ];
            PaddingTop = dim(0, 1);
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });
        
        items[ "indicator" ] = library:create( "ImageLabel" , {
            ImageColor3 = rgb(86, 86, 87);
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "dropdown" ];
            AnchorPoint = vec2(1, 0.5);
            Image = "rbxassetid://101025591575185";
            BackgroundTransparency = 1;
            Position = dim2(1, -5, 0.5, 0);
            Name = "\0";
            Size = dim2(0, 12, 0, 12);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        items[ "dropdown_holder" ] = library:create( "Frame" , {
            BorderColor3 = rgb(0, 0, 0);
            Parent = library[ "items" ];
            Name = "\0";
            Visible = true;
            BackgroundTransparency = 1;
            Size = dim2(0, 0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
            ZIndex = 10;
        });
        
        items[ "outline" ] = library:create( library.is_mobile and "ScrollingFrame" or "Frame" , {
            Parent = items[ "dropdown_holder" ];
            Size = dim2(1, 0, 1, 0);
            ClipsDescendants = true;
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(33, 33, 35);
            ZIndex = 10;
        });
        
        if library.is_mobile then
            items.outline.AutomaticCanvasSize = Enum.AutomaticSize.Y
            items.outline.CanvasSize = dim_offset(0, 0)
            items.outline.ScrollBarThickness = 3
            items.outline.ScrollingDirection = Enum.ScrollingDirection.Y
            items.outline.Active = true
        end
        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 6);
            PaddingTop = dim(0, 3);
            PaddingLeft = dim(0, 3);
            Parent = items[ "outline" ]
        });
        
        library:create( "UIListLayout" , {
            Parent = items[ "outline" ];
            Padding = dim(0, 5);
            SortOrder = Enum.SortOrder.LayoutOrder
        });
        
        library:create( "UICorner" , {
            Parent = items[ "outline" ];
            CornerRadius = dim(0, 4)
        });
    end 

    function cfg.render_option(text)
        local button = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(72, 72, 73);
            BorderColor3 = rgb(0, 0, 0);
            Text = text;
            Parent = items[ "outline" ];
            Name = "\0";
            Size = dim2(1, -12, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255);
            ZIndex = 10;
        }); library:apply_theme(button, "accent", "TextColor3");
        
        library:create( "UIPadding" , {
            Parent = button;
            PaddingTop = dim(0, 1);
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });
        
        return button
    end
    
    function cfg.set_visible(bool)
        cfg.open = bool == true
        local a = bool and cfg.y_size or 0
        if library.is_mobile then
            a = min(a, max(80, ws.CurrentCamera.ViewportSize.Y * 0.53))
            local width = min(items.dropdown.AbsoluteSize.X, ws.CurrentCamera.ViewportSize.X - 12)
            items.dropdown_holder.Size = dim_offset(width, a)
            items.dropdown_holder.Position = library:mobile_popup_position(items.dropdown, width, a, 6)
        else
            library:tween(items[ "dropdown_holder" ], {Size = dim_offset(items[ "dropdown" ].AbsoluteSize.X, a)})
            local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(800, 600)
            local px = clamp(items.dropdown.AbsolutePosition.X, 6, max(6, viewport.X - items.dropdown.AbsoluteSize.X - 6))
            local py = items.dropdown.AbsolutePosition.Y + 80
            if py + a > viewport.Y - 8 then py = max(6, items.dropdown.AbsolutePosition.Y - a - 8) end
            items.dropdown_holder.Position = dim_offset(px, py)
        end
        if bool then
            library:close_element(cfg)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end
    
    function cfg.set(value)
        local selected = {}
        local isTable = type(value) == "table"

        for _, option in cfg.option_instances do 
            if option.Text == value or (isTable and find(value, option.Text)) then 
                insert(selected, option.Text)
                cfg.multi_items = selected
                option.TextColor3 = themes.preset.accent
            else
                option.TextColor3 = rgb(72, 72, 73)
            end
        end

        items[ "sub_text" ].Text = isTable and concat(selected, ", ") or selected[1] or ""
        cfg.multi_items = isTable and selected or {}
        flags[cfg.flag] = cfg.multi and selected or selected[1]

        safe_callback(cfg.callback, flags[cfg.flag]) 
    end
    
    function cfg.refresh_options(list)
        list = type(list) == "table" and list or {}
        cfg.options = list
        local previous = flags[cfg.flag]
        cfg.y_size = 0

        for _, option in cfg.option_instances do 
            option:Destroy() 
        end
        
        cfg.option_instances = {} 

        for _, option in list do 
            local button = cfg.render_option(option)
            if library.is_mobile then
                button.AutomaticSize = Enum.AutomaticSize.None
                button.Size = dim2(1, -12, 0, 29)
                cfg.y_size += 34
            else
                cfg.y_size += 29 + 6
            end
            insert(cfg.option_instances, button)
            
            button.MouseButton1Down:Connect(function()
                if cfg.multi then 
                    local selected_index = find(cfg.multi_items, button.Text)
                    
                    if selected_index then 
                        remove(cfg.multi_items, selected_index)
                    else
                        insert(cfg.multi_items, button.Text)
                    end
                    
                    cfg.set(cfg.multi_items) 				
                else 
                    cfg.set_visible(false)
                    cfg.open = false 
                    
                    cfg.set(button.Text)
                end
            end)
        end
        if previous ~= nil then cfg.set(previous) end
    end

    items[ "dropdown" ].MouseButton1Click:Connect(function()
        cfg.open = not cfg.open 
        
        cfg.set_visible(cfg.open)
    end)

    if cfg.seperator then 
        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = self.items[ "elements" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 1, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(36, 36, 37)
        });
    end 

    flags[cfg.flag] = nil
    config_flags[cfg.flag] = cfg.set
    
    cfg.refresh_options(cfg.options)
    cfg.set(cfg.default)
        
    return setmetatable(cfg, library)
end

function library:label(options)
    local cfg = {
        enabled = options.enabled or nil,
        name = options.name or "Toggle",
        seperator = options.seperator or options.Seperator or false;
        info = options.info or nil; 

        items = {};
    }

    local items = cfg.items; do 
        items[ "label" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "label" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });

        if cfg.info then 
            items[ "info" ] = library:create( "TextLabel" , {
                FontFace = fonts.small;
                TextColor3 = rgb(130, 130, 130);
                BorderColor3 = rgb(0, 0, 0);
                TextWrapped = true;
                Text = cfg.info;
                Parent = items[ "label" ];
                Name = "\0";
                Position = dim2(0, 5, 0, 17);
                Size = dim2(1, -10, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                TextSize = 16;
                BackgroundColor3 = rgb(255, 255, 255)
            });
        end 
        
        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });
        
        items[ "right_components" ] = library:create( "Frame" , {
            Parent = items[ "label" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIListLayout" , {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            Parent = items[ "right_components" ];
            Padding = dim(0, 9);
            SortOrder = Enum.SortOrder.LayoutOrder
        });                
    end 

    if cfg.seperator then 
        library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = self.items[ "elements" ];
            Position = dim2(0, 0, 1, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 1, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(36, 36, 37)
        });
    end 

    return setmetatable(cfg, library)
end 

function library:colorpicker(options) 
    local cfg = {
        name = options.name or "Color", 
        flag = options.flag or library:next_flag(),

        color = options.color or color(1, 1, 1),
        alpha = options.alpha and 1 - options.alpha or 0,
        
        open = false, 
        callback = options.callback or function() end,
        items = {};

        seperator = options.seperator or options.Seperator or false;
    }

    local dragging_sat = false 
    local dragging_hue = false 
    local dragging_alpha = false 

    local h, s, v = cfg.color:ToHSV() 
    local a = cfg.alpha 

    flags[cfg.flag] = {Color = cfg.color, Transparency = cfg.alpha}

    local label; 
    if not self.items.right_components then 
        label = self:label({name = cfg.name, seperator = cfg.seperator})
    end

    local items = cfg.items; do 
        items[ "colorpicker" ] = library:create( "TextButton" , {
            FontFace = fonts.small;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            AnchorPoint = vec2(1, 0);
            Parent = label and label.items.right_components or self.items[ "right_components" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            Size = dim2(0, 16, 0, 16);
            BorderSizePixel = 0;
            TextSize = 14;
            BackgroundColor3 = rgb(54, 31, 184)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "colorpicker" ];
            CornerRadius = dim(0, 4)
        });
        
        items[ "colorpicker_inline" ] = library:create( "Frame" , {
            Parent = items[ "colorpicker" ];
            Size = dim2(1, -2, 1, -2);
            Name = "\0";
            BorderMode = Enum.BorderMode.Inset;
            BorderColor3 = rgb(0, 0, 0);
            Position = dim2(0, 1, 0, 1);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(54, 31, 184)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "colorpicker_inline" ];
            CornerRadius = dim(0, 4)
        });
        
        library:create( "UIGradient" , {
            Color = rgbseq{rgbkey(0, rgb(211, 211, 211)), rgbkey(1, rgb(211, 211, 211))};
            Parent = items[ "colorpicker_inline" ]
        });         

        items[ "colorpicker_holder" ] = library:create( "Frame" , {
            Parent = library[ "other" ];
            Name = "\0";
            Position = dim2(0.20000000298023224, 20, 0.296999990940094, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 166, 0, 197);
            BorderSizePixel = 0;
            Visible = true;
            BackgroundColor3 = rgb(25, 25, 29)
        });

        items[ "colorpicker_fade" ] = library:create( "Frame" , {
            Parent = items[ "colorpicker_holder" ];
            Name = "\0";
            BackgroundTransparency = 0;
            Position = dim2(0, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 1, 0);
            BorderSizePixel = 0;
            ZIndex = 100;
            BackgroundColor3 = rgb(25, 25, 29)
        });
        
        items[ "colorpicker_components" ] = library:create( "Frame" , {
            Parent = items[ "colorpicker_holder" ];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(22, 22, 24)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "colorpicker_components" ];
            CornerRadius = dim(0, 6)
        });
        
        items[ "saturation_holder" ] = library:create( "Frame" , {
            Parent = items[ "colorpicker_components" ];
            Name = "\0";
            Position = dim2(0, 7, 0, 7);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -14, 1, -80);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 39, 39)
        });
        
        items[ "sat" ] = library:create( "TextButton" , {
            Parent = items[ "saturation_holder" ];
            Name = "\0";
            Size = dim2(1, 0, 1, 0);
            Text = "";
            AutoButtonColor = false;
            BorderColor3 = rgb(0, 0, 0);
            ZIndex = 2;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "sat" ];
            CornerRadius = dim(0, 4)
        });
        
        library:create( "UIGradient" , {
            Rotation = 270;
            Transparency = numseq{numkey(0, 0), numkey(1, 1)};
            Parent = items[ "sat" ];
            Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0))}
        });
        
        items[ "val" ] = library:create( "Frame" , {
            Name = "\0";
            Parent = items[ "saturation_holder" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIGradient" , {
            Parent = items[ "val" ];
            Transparency = numseq{numkey(0, 0), numkey(1, 1)}
        });
        
        library:create( "UICorner" , {
            Parent = items[ "val" ];
            CornerRadius = dim(0, 4)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "saturation_holder" ];
            CornerRadius = dim(0, 4)
        });
        
        items[ "satvalpicker" ] = library:create( "TextButton" , {
            BorderColor3 = rgb(0, 0, 0);
            AutoButtonColor = false;
            Text = "";
            AnchorPoint = vec2(0, 1);
            Parent = items[ "saturation_holder" ];
            Name = "\0";
            Position = dim2(0, 0, 4, 0);
            Size = dim2(0, 8, 0, 8);
            ZIndex = 5;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 0, 0)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "satvalpicker" ];
            CornerRadius = dim(0, 9999)
        });
        
        library:create( "UIStroke" , {
            Color = rgb(255, 255, 255);
            Parent = items[ "satvalpicker" ];
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        });
        
        items[ "hue_gradient" ] = library:create( "TextButton" , {
            Parent = items[ "colorpicker_components" ];
            Name = "\0";
            Position = dim2(0, 10, 1, -64);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -20, 0, 8);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255);
            AutoButtonColor = false;
            Text = "";
        });
        
        library:create( "UIGradient" , {
            Color = rgbseq{rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)), rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)), rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)), rgbkey(1, rgb(255, 0, 0))};
            Parent = items[ "hue_gradient" ]
        });
        
        library:create( "UICorner" , {
            Parent = items[ "hue_gradient" ];
            CornerRadius = dim(0, 6)
        });
        
        items[ "hue_picker" ] = library:create( "TextButton" , {
            BorderColor3 = rgb(0, 0, 0);
            AutoButtonColor = false;
            Text = "";
            AnchorPoint = vec2(0, 0.5);
            Parent = items[ "hue_gradient" ];
            Name = "\0";
            Position = dim2(0, 0, 0.5, 0);
            Size = dim2(0, 8, 0, 8);
            ZIndex = 5;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 0, 0)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "hue_picker" ];
            CornerRadius = dim(0, 9999)
        });
        
        library:create( "UIStroke" , {
            Color = rgb(255, 255, 255);
            Parent = items[ "hue_picker" ];
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        });
        
        items[ "alpha_gradient" ] = library:create( "TextButton" , {
            Parent = items[ "colorpicker_components" ];
            Name = "\0";
            Position = dim2(0, 10, 1, -46);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -20, 0, 8);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(25, 25, 29);
            AutoButtonColor = false;
            Text = "";
        });
        
        library:create( "UICorner" , {
            Parent = items[ "alpha_gradient" ];
            CornerRadius = dim(0, 6)
        });
        
        items[ "alpha_picker" ] = library:create( "TextButton" , {
            BorderColor3 = rgb(0, 0, 0);
            AutoButtonColor = false;
            Text = "";
            AnchorPoint = vec2(0, 0.5);
            Parent = items[ "alpha_gradient" ];
            Name = "\0";
            Position = dim2(1, 0, 0.5, 0);
            Size = dim2(0, 8, 0, 8);
            ZIndex = 5;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 0, 0)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "alpha_picker" ];
            CornerRadius = dim(0, 9999)
        });
        
        library:create( "UIStroke" , {
            Color = rgb(255, 255, 255);
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            Parent = items[ "alpha_picker" ]
        });
        
        library:create( "UIGradient" , {
            Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(255, 255, 255))};
            Parent = items[ "alpha_gradient" ]
        });
        
        items[ "alpha_indicator" ] = library:create( "ImageLabel" , {
            ScaleType = Enum.ScaleType.Tile;
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "alpha_gradient" ];
            Image = "rbxassetid://18274452449";
            BackgroundTransparency = 1;
            Name = "\0";
            Size = dim2(1, 0, 1, 0);
            TileSize = dim2(0, 6, 0, 6);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0)
        });
        
        library:create( "UIGradient" , {
            Color = rgbseq{rgbkey(0, rgb(112, 112, 112)), rgbkey(1, rgb(255, 0, 0))};
            Transparency = numseq{numkey(0, 0.8062499761581421), numkey(1, 0)};
            Parent = items[ "alpha_indicator" ]
        });
        
        library:create( "UICorner" , {
            Parent = items[ "alpha_indicator" ];
            CornerRadius = dim(0, 6)
        });
        
        library:create( "UIGradient" , {
            Rotation = 90;
            Parent = items[ "colorpicker_components" ];
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(66, 66, 66))}
        });

        items[ "input" ] = library:create( "TextBox" , {
            FontFace = fonts.font;
            AnchorPoint = vec2(1, 1);
            Text = "";
            Parent = items[ "colorpicker_components" ];
            Name = "\0";
            TextTruncate = Enum.TextTruncate.AtEnd;
            BorderSizePixel = 0;
            PlaceholderColor3 = rgb(255, 255, 255);
            CursorPosition = -1;
            ClearTextOnFocus = false;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255);
            TextColor3 = rgb(72, 72, 72);
            BorderColor3 = rgb(0, 0, 0);
            Position = dim2(1, -8, 1, -11);
            Size = dim2(1, -16, 0, 18);
            BackgroundColor3 = rgb(33, 33, 35)
        }); 
        
        library:create( "UICorner" , {
            Parent = items[ "input" ];
            CornerRadius = dim(0, 3)
        });
        
        items[ "UICorenr" ] = library:create( "UICorner" , {
            Parent = items[ "colorpicker_holder" ];
            Name = "\0";
            CornerRadius = dim(0, 4)
        });
    end;

    function cfg.set_visible(bool)
        items[ "colorpicker_fade" ].BackgroundTransparency = 0
        items[ "colorpicker_holder" ].Parent = bool and library[ "items" ] or library[ "other" ]
        if library.is_mobile then
            local holder = items.colorpicker_holder
            holder.Position = library:mobile_popup_position(items.colorpicker, holder.AbsoluteSize.X > 0 and holder.AbsoluteSize.X or 166, holder.AbsoluteSize.Y > 0 and holder.AbsoluteSize.Y or 197, 6)
            library:tween(items.colorpicker_fade, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.4)
        else
            items[ "colorpicker_holder" ].Position = dim_offset(items[ "colorpicker" ].AbsolutePosition.X, items[ "colorpicker" ].AbsolutePosition.Y + items[ "colorpicker" ].AbsoluteSize.Y + 45)
            library:tween(items[ "colorpicker_fade" ], {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.4)
            library:tween(items[ "colorpicker_holder" ], {Position = items[ "colorpicker_holder" ].Position + dim_offset(0, 20)})
        end
        
        if bool then
            library:close_element(cfg)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end

    function cfg.set(color, alpha)
        if type(color) == "boolean" then 
            return
        end 

        if color then 
            h, s, v = color:ToHSV()
        end
        
        if alpha ~= nil then
            local number = tonumber(alpha)
            if number and number == number then a = clamp(number, 0, 1) end
        end 
        
        local Color = hsv(h, s, v)

        library:tween(items[ "hue_picker" ], {Position = dim2(0, (items[ "hue_gradient" ].AbsoluteSize.X - items[ "hue_picker" ].AbsoluteSize.X) * h, 0.5, 0)}, Enum.EasingStyle.Linear, 0.05)
        library:tween(items[ "alpha_picker" ], {Position = dim2(0, (items[ "alpha_gradient" ].AbsoluteSize.X - items[ "alpha_picker" ].AbsoluteSize.X) * (1 - a), 0.5, 0)}, Enum.EasingStyle.Linear, 0.05)
        library:tween(items[ "satvalpicker" ], {Position = dim2(0, s * (items[ "saturation_holder" ].AbsoluteSize.X - items[ "satvalpicker" ].AbsoluteSize.X), 1, 1 - v * (items[ "saturation_holder" ].AbsoluteSize.Y - items[ "satvalpicker" ].AbsoluteSize.Y))}, Enum.EasingStyle.Linear, 0.05)

        items[ "alpha_indicator" ]:FindFirstChildOfClass("UIGradient").Color = rgbseq{rgbkey(0, rgb(112, 112, 112)), rgbkey(1, hsv(h, 1, 1))};
        
        items[ "colorpicker" ].BackgroundColor3 = Color
        items[ "colorpicker_inline" ].BackgroundColor3 = Color
        items[ "saturation_holder" ].BackgroundColor3 = hsv(h, 1, 1)

        items[ "hue_picker" ].BackgroundColor3 = hsv(h, 1, 1)
        items[ "alpha_picker" ].BackgroundColor3 = hsv(h, 1, 1 - a)
        items[ "satvalpicker" ].BackgroundColor3 = hsv(h, s, v)

        flags[cfg.flag] = {
            Color = Color;
            Transparency = a 
        }
        
        local color = items[ "colorpicker" ].BackgroundColor3
        items[ "input" ].Text = string.format("%s, %s, %s, ", library:round(color.R * 255), library:round(color.G * 255), library:round(color.B * 255))
        items[ "input" ].Text ..= library:round(1 - a, 0.01)
        
        safe_callback(cfg.callback, Color, a)
    end
    
    function cfg.update_color(input_position)
        local cursor = input_position or uis:GetMouseLocation()
        local offset = cursor 

        if dragging_sat then	
            s = math.clamp((offset - items["sat"].AbsolutePosition).X / items["sat"].AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((offset - items["sat"].AbsolutePosition).Y / items["sat"].AbsoluteSize.Y, 0, 1)
        elseif dragging_hue then
            h = math.clamp((offset - items[ "hue_gradient" ].AbsolutePosition).X / items[ "hue_gradient" ].AbsoluteSize.X, 0, 1)
        elseif dragging_alpha then
            a = 1 - math.clamp((offset - items[ "alpha_gradient" ].AbsolutePosition).X / items[ "alpha_gradient" ].AbsoluteSize.X, 0, 1)
        end

        cfg.set()
    end

    items[ "colorpicker" ].MouseButton1Click:Connect(function()
        cfg.open = not cfg.open 

        cfg.set_visible(cfg.open)            
    end)

    if library.is_mobile then
        local active_touch
        local function attach_drag(object, channel)
            object.Active = true
            object.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Touch or active_touch then return end
                active_touch = input
                dragging_sat = channel == 'sat'
                dragging_hue = channel == 'hue'
                dragging_alpha = channel == 'alpha'
                cfg.update_color(input.Position)
            end)
        end
        attach_drag(items.alpha_gradient, 'alpha')
        attach_drag(items.hue_gradient, 'hue')
        attach_drag(items.sat, 'sat')
        library:connection(uis.InputChanged, function(input)
            if input == active_touch then cfg.update_color(input.Position) end
        end)
        library:connection(uis.InputEnded, function(input)
            if input == active_touch then
                active_touch = nil
                dragging_sat, dragging_hue, dragging_alpha = false, false, false
            end
        end)
    else
        library:connection(uis.InputChanged, function(input)
            if (dragging_sat or dragging_hue or dragging_alpha) and input.UserInputType == Enum.UserInputType.MouseMovement then
                cfg.update_color()
            end
        end)
        library:connection(uis.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging_sat = false
                dragging_hue = false
                dragging_alpha = false
            end
        end)
        items[ "alpha_gradient" ].MouseButton1Down:Connect(function() dragging_alpha = true end)
        items[ "hue_gradient" ].MouseButton1Down:Connect(function() dragging_hue = true end)
        items[ "sat" ].MouseButton1Down:Connect(function() dragging_sat = true end)
    end

    items[ "input" ].FocusLost:Connect(function()
        local text = items[ "input" ].Text
        local r, g, b, a = library:convert(text)
        
        if r and g and b and a then 
            cfg.set(rgb(clamp(r, 0, 255), clamp(g, 0, 255), clamp(b, 0, 255)), 1 - clamp(a, 0, 1))
        end 
    end)

    items[ "input" ].Focused:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(245, 245, 245)})
    end)

    items[ "input" ].FocusLost:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(72, 72, 72)})
    end)
    
    cfg.set(cfg.color, cfg.alpha)
    config_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, library)
end 

function library:textbox(options) 
    local cfg = {
        name = options.name or "TextBox",
        placeholder = options.placeholder or options.placeholdertext or options.holder or options.holdertext or "type here...",
        default = options.default or "",
        flag = options.flag or library:next_flag(),
        callback = options.callback or function() end,
        visible = options.visible ~= false,
        items = {};
    }

    flags[cfg.flag] = cfg.default

    local items = cfg.items; do 
        items[ "textbox" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "textbox" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });
        
        items[ "right_components" ] = library:create( "Frame" , {
            Parent = items[ "textbox" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 4, 0, 19);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, 0, 0, 12);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIListLayout" , {
            Parent = items[ "right_components" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder;
            FillDirection = Enum.FillDirection.Horizontal
        });
        
        items[ "input" ] = library:create( "TextBox" , {
            PlaceholderText = cfg.placeholder;
            FontFace = fonts.font;
            Text = "";
            Parent = items[ "right_components" ];
            Name = "\0";
            TextTruncate = Enum.TextTruncate.AtEnd;
            BorderSizePixel = 0;
            PlaceholderColor3 = rgb(255, 255, 255);
            CursorPosition = -1;
            ClearTextOnFocus = false;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255);
            TextColor3 = rgb(72, 72, 72);
            BorderColor3 = rgb(0, 0, 0);
            Position = dim2(1, 0, 0, 0);
            Size = dim2(1, -4, 0, 30);
            BackgroundColor3 = rgb(33, 33, 35)
        }); 

        library:create( "UICorner" , {
            Parent = items[ "input" ];
            CornerRadius = dim(0, 3)
        });                
        
        library:create( "UIPadding" , {
            Parent = items[ "right_components" ];
            PaddingTop = dim(0, 4);
            PaddingRight = dim(0, 4)
        });
    end 
    
    function cfg.set(text)
        text = tostring(text or "")
        if flags[cfg.flag] == text and items.input.Text == text then return end
        flags[cfg.flag] = text
        if items.input.Text ~= text then items.input.Text = text end
        safe_callback(cfg.callback, text)
    end 
    
    items[ "input" ]:GetPropertyChangedSignal("Text"):Connect(function()
        cfg.set(items[ "input" ].Text) 
    end)

    items[ "input" ].Focused:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(245, 245, 245)})
    end)

    items[ "input" ].FocusLost:Connect(function()
        library:tween(items[ "input" ], {TextColor3 = rgb(72, 72, 72)})
    end)
        
    if cfg.default then 
        cfg.set(cfg.default) 
    end

    items.textbox.Visible = cfg.visible
    config_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, library)
end

function library:keybind(options) 
    local cfg = {
        flag = options.flag or library:next_flag(),
        callback = options.callback or function() end,
        name = options.name or nil, 
        ignore_key = options.ignore or false, 

        key = options.key or nil, 
        mode = options.mode or "Toggle",
        active = options.default or false, 

        open = false,
        binding = nil, 

        hold_instances = {},
        items = {};
    }

    flags[cfg.flag] = {
        mode = cfg.mode,
        key = cfg.key, 
        active = cfg.active
    }

    local items = cfg.items; do 
        items[ "keybind_element" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "keybind_element" ];
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 16;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIPadding" , {
            Parent = items[ "name" ];
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });
        
        items[ "right_components" ] = library:create( "Frame" , {
            Parent = items[ "keybind_element" ];
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 1, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIListLayout" , {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            Parent = items[ "right_components" ];
            Padding = dim(0, 7);
            SortOrder = Enum.SortOrder.LayoutOrder
        });
        
        items[ "keybind_holder" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            Parent = items[ "right_components" ];
            AutoButtonColor = false;
            AnchorPoint = vec2(1, 0);
            Size = dim2(0, 0, 0, 16);
            Name = "\0";
            Position = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
            TextSize = 14;
            BackgroundColor3 = rgb(33, 33, 35)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "keybind_holder" ];
            CornerRadius = dim(0, 4)
        });
        
        items[ "key" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(86, 86, 87);
            BorderColor3 = rgb(0, 0, 0);
            Text = "LSHIFT";
            Parent = items[ "keybind_holder" ];
            Name = "\0";
            Size = dim2(1, -12, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIPadding" , {
            Parent = items[ "key" ];
            PaddingTop = dim(0, 1);
            PaddingRight = dim(0, 5);
            PaddingLeft = dim(0, 5)
        });                                  

        items[ "dropdown" ] = library:create( "Frame" , {
            BorderColor3 = rgb(0, 0, 0);
            Parent = library.items;
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 0, 0, 0);
            Size = dim2(0, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.X;
            BackgroundColor3 = rgb(0, 0, 0)
        });
        
        items[ "inline" ] = library:create( "Frame" , {
            Parent = items[ "dropdown" ];
            Size = dim2(1, 0, 1, 0);
            Name = "\0";
            ClipsDescendants = true;
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(22, 22, 24)
        });
        
        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 6);
            PaddingTop = dim(0, 3);
            PaddingLeft = dim(0, 3);
            Parent = items[ "inline" ]
        });
        
        library:create( "UIListLayout" , {
            Parent = items[ "inline" ];
            Padding = dim(0, 5);
            SortOrder = Enum.SortOrder.LayoutOrder
        });
        
        library:create( "UICorner" , {
            Parent = items[ "inline" ];
            CornerRadius = dim(0, 4)
        });
        
        local options = {"Hold", "Toggle", "Always"}
        
        cfg.y_size = 14
        for _, option in options do                        
            local name = library:create( "TextButton" , {
                FontFace = fonts.font;
                TextColor3 = rgb(72, 72, 73);
                BorderColor3 = rgb(0, 0, 0);
                Text = option;
                Parent = items[ "inline" ];
                Name = "\0";
                Size = dim2(0, 0, 0, 0);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                TextSize = 14;
                BackgroundColor3 = rgb(255, 255, 255)
            }); cfg.hold_instances[option] = name
            library:apply_theme(name, "accent", "TextColor3")
            
            cfg.y_size += 25

            library:create( "UIPadding" , {
                Parent = name;
                PaddingTop = dim(0, 1);
                PaddingRight = dim(0, 5);
                PaddingLeft = dim(0, 5)
            });

            name.MouseButton1Click:Connect(function()
                cfg.set(option)

                cfg.set_visible(false)

                cfg.open = false
            end)
        end
    end 
    
    function cfg.modify_mode_color(path)
        for mode, control in pairs(cfg.hold_instances) do
            control.TextColor3 = mode == path and themes.preset.accent or rgb(72, 72, 72)
        end
    end

    function cfg.set_mode(mode)
        if mode ~= "Toggle" and mode ~= "Hold" and mode ~= "Always" then return end
        cfg.mode = mode
        cfg.active = mode == "Always" and true or (mode == "Hold" and false or cfg.active)
        cfg.modify_mode_color(mode)
        cfg.set(cfg.active)
    end

    function cfg.set(input)
        if type(input) == "boolean" then
            cfg.active = cfg.mode == "Always" or input
        elseif typeof(input) == "EnumItem" then
            cfg.key = input == Enum.KeyCode.Escape and "NONE" or input
        elseif type(input) == "string" then
            if input == "Toggle" or input == "Hold" or input == "Always" then
                cfg.mode = input
                if input == "Always" then cfg.active = true end
                if input == "Hold" then cfg.active = false end
            elseif input == "NONE" then
                cfg.key = "NONE"
            else
                local resolved = library:convert_enum(input)
                if resolved then cfg.key = resolved end
            end
        elseif type(input) == "table" then
            cfg.mode = (input.mode == "Toggle" or input.mode == "Hold" or input.mode == "Always") and input.mode or "Toggle"
            local resolved = type(input.key) == "string" and library:convert_enum(input.key) or input.key
            cfg.key = (input.key == "NONE" and "NONE") or resolved or "NONE"
            if input.active ~= nil then cfg.active = input.active == true end
            if cfg.mode == "Always" then cfg.active = true end
            if cfg.mode == "Hold" then cfg.active = false end
        end
        cfg.modify_mode_color(cfg.mode)
        flags[cfg.flag] = {mode = cfg.mode, key = cfg.key or "NONE", active = cfg.active}
        local key_string = keys[cfg.key] or (typeof(cfg.key) == "EnumItem" and cfg.key.Name) or "NONE"
        items.key.Text = tostring(key_string)
        safe_callback(cfg.callback, cfg.active)
    end

    function cfg.set_visible(bool)
        cfg.open = bool == true
        local size = bool and cfg.y_size or 0
        library:tween(items[ "dropdown" ], {Size = dim_offset(items[ "keybind_holder" ].AbsoluteSize.X, size)})

        if library.is_mobile then
            local width = max(90, items.keybind_holder.AbsoluteSize.X)
            items.dropdown.Position = library:mobile_popup_position(items.keybind_holder, width, max(100, size), 6)
        else
            local viewport = ws.CurrentCamera and ws.CurrentCamera.ViewportSize or vec2(800, 600)
            local x = clamp(items.keybind_holder.AbsolutePosition.X, 6, max(6, viewport.X - items.keybind_holder.AbsoluteSize.X - 6))
            local y = items.keybind_holder.AbsolutePosition.Y + items.keybind_holder.AbsoluteSize.Y + 60
            if y + size > viewport.Y - 8 then y = max(6, items.keybind_holder.AbsolutePosition.Y - size - 8) end
            items.dropdown.Position = dim_offset(x, y)
        end
        if bool then
            library:close_element(cfg)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end

    items[ "keybind_holder" ].MouseButton1Down:Connect(function()
        if library.is_mobile then
            cfg.open = not cfg.open
            cfg.set_visible(cfg.open)
            return
        end
        if cfg.binding then cfg.binding:Disconnect() end
        items.key.Text = "..."
        cfg.binding = library:connection(uis.InputBegan, function(keycode)
            local next_key = keycode.KeyCode ~= Enum.KeyCode.Unknown and keycode.KeyCode or keycode.UserInputType
            cfg.capture_ignored_input = keycode
            if cfg.binding then cfg.binding:Disconnect(); cfg.binding = nil end
            cfg.set(next_key)
        end)
    end)

    items[ "keybind_holder" ].MouseButton2Down:Connect(function()
        cfg.open = not cfg.open 

        cfg.set_visible(cfg.open)
    end)

    library:connection(uis.InputBegan, function(input, game_event) 
        if not game_event and not cfg.binding and input ~= cfg.capture_ignored_input then
            local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType

            if selected_key == cfg.key then 
                if cfg.mode == "Toggle" then 
                    cfg.active = not cfg.active
                    cfg.set(cfg.active)
                elseif cfg.mode == "Hold" then 
                    cfg.set(true)
                end
            end
        end
    end)    

    library:connection(uis.InputEnded, function(input, game_event) 
        if game_event or cfg.binding then
            return
        end 

        local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType

        if selected_key == cfg.key then
            if cfg.mode == "Hold" then 
                cfg.set(false)
            end
        end
    end)
    
    cfg.set({mode = cfg.mode, active = cfg.active, key = cfg.key})           
    config_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, library)
end

function library:button(options) 
    local cfg = {
        name = options.name or "TextBox",
        callback = options.callback or function() end,
        items = {};
    }
    
    local items = cfg.items; do 
        items[ "button_element" ] = library:create( "Frame" , {
            Parent = self.items[ "elements" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        items[ "button" ] = library:create( "TextButton" , {
            FontFace = fonts.font;
            TextColor3 = rgb(0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            Text = "";
            AutoButtonColor = false;
            AnchorPoint = vec2(1, 0);
            Parent = items[ "button_element" ];
            Name = "\0";
            Position = dim2(1, -4, 0, 0);
            Size = dim2(1, -8, 0, 30);
            BorderSizePixel = 0;
            TextSize = 14;
            BackgroundColor3 = rgb(33, 33, 35)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "button" ];
            CornerRadius = dim(0, 3)
        });
        
        items[ "name" ] = library:create( "TextLabel" , {
            FontFace = fonts.small;
            TextColor3 = rgb(245, 245, 245);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "button" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Size = dim2(1, 0, 1, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        }); library:apply_theme(items[ "name" ], "accent", "TextColor3");                            
    end 

    items[ "button" ].MouseButton1Click:Connect(function()
        safe_callback(cfg.callback)

        items[ "name" ].TextColor3 = themes.preset.accent 
        library:tween(items[ "name" ], {TextColor3 = rgb(245, 245, 245)})
    end)
    
    return setmetatable(cfg, library)
end 

function library:settings(options)  
    local cfg = {
        open = false; 
        items = {}; 
        sanity = true;
    }

    local items = cfg.items; do 
        items[ "outline" ] = library:create( "Frame" , {
            Name = "\0";
            Visible = true;
            Parent = library[ "items" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 0, 0);
            ClipsDescendants = true;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(25, 25, 29)
        });
        
        items[ "inline" ] = library:create( "Frame" , {
            Parent = items[ "outline" ];
            Name = "\0";
            Position = dim2(0, 1, 0, 1);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(22, 22, 24)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "inline" ];
            CornerRadius = dim(0, 7)
        });
        
        items[ "elements" ] = library:create( "Frame" , {
            BorderColor3 = rgb(0, 0, 0);
            Parent = items[ "inline" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 10, 0, 10);
            Size = dim2(1, -20, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIListLayout" , {
            Parent = items[ "elements" ];
            Padding = dim(0, 10);
            SortOrder = Enum.SortOrder.LayoutOrder
        });
        
        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 15);
            Parent = items[ "elements" ]
        });
        
        library:create( "UICorner" , {
            Parent = items[ "outline" ];
            CornerRadius = dim(0, 7)
        });
        
        items[ "tick" ] = library:create( "ImageButton" , {
            Image = "rbxassetid://128797200442698";
            Name = "\0";
            AutoButtonColor = false;
            Parent = self.items[ "right_components" ];
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 16, 0, 16);
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(255, 255, 255)
        });                
    end 

    function cfg.set_visible(bool)                 
        library:tween(items[ "outline" ], {Size = dim_offset(bool and 240 or 0, 0)})
        if library.is_mobile then
            items.outline.Position = library:mobile_popup_position(items.tick, 240, max(230, items.outline.AbsoluteSize.Y), 6)
        else
            items[ "outline" ].Position = dim_offset(items[ "tick" ].AbsolutePosition.X, items[ "tick" ].AbsolutePosition.Y + 90)
        end
        if bool then
            library:close_element(cfg)
        elseif library.current_open == cfg then
            library.current_open = nil
        end
    end
    
    items[ "tick" ].MouseButton1Click:Connect(function()
        cfg.open = not cfg.open

        cfg.set_visible(cfg.open)
    end)

    return setmetatable(cfg, library)
end 

function library:list(properties) 
    local cfg = {
        items = {};
        options = properties.options or {"1", "2", "3"};
        flag = properties.flag or library:next_flag();    
        callback = properties.callback or function() end;
        data_store = {};        
        current_element;
    }

    local items = cfg.items; do
        items[ "list" ] = library:create( "Frame" , {
            Parent = self.items[ "elements" ];
            BackgroundTransparency = 1;
            Name = "\0";
            Size = dim2(1, 0, 0, 0);
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIListLayout" , {
            Parent = items[ "list" ];
            Padding = dim(0, 10);
            SortOrder = Enum.SortOrder.LayoutOrder
        });
        
        library:create( "UIPadding" , {
            Parent = items[ "list" ];
            PaddingRight = dim(0, 4);
            PaddingLeft = dim(0, 4)
        });
    end 

    function cfg.set(value)
        local found = false
        for _, button in ipairs(cfg.data_store) do
            local label = button:FindFirstChildOfClass("TextLabel")
            if label then
                local match = label.Text == value
                label.TextColor3 = match and rgb(245, 245, 245) or rgb(72, 72, 73)
                if match then cfg.current_element = label; found = true end
            end
        end
        if not found then cfg.current_element = nil end
        flags[cfg.flag] = found and value or nil
        if found then safe_callback(cfg.callback, value) end
    end

    function cfg.refresh_options(options_to_refresh)
        local previous = flags[cfg.flag]
        for _, button in ipairs(cfg.data_store) do button:Destroy() end
        table.clear(cfg.data_store)
        cfg.current_element = nil
        cfg.options = type(options_to_refresh) == "table" and options_to_refresh or {}
        for _, option_data in ipairs(cfg.options) do
            local button = library:create("TextButton", {
                FontFace = fonts.small, Text = "", AutoButtonColor = false,
                Parent = items.list, Size = dim2(1, 0, 0, 30), BorderSizePixel = 0,
                BackgroundColor3 = rgb(33, 33, 35),
            })
            table.insert(cfg.data_store, button)
            local name = library:create("TextLabel", {
                FontFace = fonts.font, Text = tostring(option_data), Parent = button,
                TextColor3 = rgb(72, 72, 73), BorderSizePixel = 0,
                BackgroundTransparency = 1, Size = dim2(1, 0, 1, 0), TextSize = 14,
            })
            library:create("UICorner", {Parent = button, CornerRadius = dim(0, 3)})
            button.MouseButton1Click:Connect(function() cfg.set(name.Text) end)
            name.MouseEnter:Connect(function()
                if cfg.current_element ~= name then name.TextColor3 = rgb(140, 140, 140) end
            end)
            name.MouseLeave:Connect(function()
                if cfg.current_element ~= name then name.TextColor3 = rgb(72, 72, 73) end
            end)
        end
        if previous then cfg.set(previous) end
    end

    cfg.refresh_options(cfg.options)
    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, library)
end 

function library:init_config(window)
    window:seperator({name = "Settings"})
    local main = window:tab({name = "Configs", tabs = {"Main"}})
    local left = main:column({})
    local list_section = left:section({name = "Configs", size = 1, default = true, icon = "rbxassetid://139628202576511"})
    config_holder = list_section:list({options = {}, flag = "config_name_list"})

    local right = main:column({})
    local section = right:section({name = "Settings", side = "right", size = 1, default = true, icon = "rbxassetid://129380150574313"})
    section:textbox({name = "Config name:", flag = "config_name_text"})

    local function notice(message)
        if not library.unloaded then notifications:create_notification({name = "Configs", info = message}) end
    end
    section:button({name = "Save", callback = function()
        local selected = config_name(flags.config_name_text) or config_name(flags.config_name_list)
        local path = config_path(selected)
        if not path then notice("Enter a configuration name first") return end
        if not ensure_folder(library.directory) or not ensure_folder(library.directory .. "/configs") then
            notice("Cannot create configuration folder") return
        end
        local ok, data = pcall(function() return library:get_config() end)
        if not ok then notice("Cannot encode config: " .. tostring(data)) return end
        local wrote, err = write_file(path, data)
        if not wrote then notice("Save failed: " .. tostring(err)) return end
        library:update_config_list()
        notice("Saved config: " .. selected)
    end})
    section:button({name = "Load", callback = function()
        local selected = config_name(flags.config_name_list) or config_name(flags.config_name_text)
        local path = config_path(selected)
        local content = path and read_file(path)
        if not content then notice("Select an existing configuration") return end
        local ok, err = library:load_config(content)
        notice(ok and ("Loaded config: " .. selected) or ("Load failed: " .. tostring(err)))
    end})
    section:button({name = "Delete", callback = function()
        local selected = config_name(flags.config_name_list) or config_name(flags.config_name_text)
        local path = config_path(selected)
        if not path or not has_file(path) or type(delfile) ~= "function" then
            notice("Select an existing configuration") return
        end
        local ok, err = pcall(delfile, path)
        if not ok then notice("Delete failed: " .. tostring(err)) return end
        library:update_config_list()
        notice("Deleted config: " .. selected)
    end})
    section:colorpicker({name = "Menu Accent", callback = function(accent) library:update_theme("accent", accent) end, color = themes.preset.accent})
    section:keybind({name = "Menu Bind", callback = function(enabled) window.toggle_menu(enabled) end, default = true})
    library:update_config_list()
end

function notifications:refresh_notifs()
    local offset = 50
    for _, frame in ipairs(self.notifs) do
        if frame and frame.Parent then
            library:tween(frame, {Position = dim_offset(20, offset)}, Enum.EasingStyle.Quad, 0.3)
            offset += max(frame.AbsoluteSize.Y, 53) + 10
        end
    end
    return offset
end

function notifications:fade(path, is_fading)
    if library.unloaded or not path or not path.Parent then return end
    local opacity = is_fading and 1 or 0
    library:tween(path, {BackgroundTransparency = opacity}, Enum.EasingStyle.Quad, 0.3)
    for _, instance in ipairs(path:GetDescendants()) do
        if instance:IsA("UIStroke") then
            library:tween(instance, {Transparency = opacity}, Enum.EasingStyle.Quad, 0.3)
        elseif instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            library:tween(instance, {TextTransparency = opacity}, Enum.EasingStyle.Quad, 0.3)
        elseif instance:IsA("Frame") and instance.Name ~= "notification" then
            local desired = instance:GetAttribute("MilleniumBaseTransparency")
            if desired == nil then
                desired = instance.BackgroundTransparency
                instance:SetAttribute("MilleniumBaseTransparency", desired)
            end
            library:tween(instance, {BackgroundTransparency = is_fading and 1 or desired}, Enum.EasingStyle.Quad, 0.3)
        end
    end
end

function notifications:create_notification(options)
    local cfg = {
        name = options.name or "This is a title!";
        info = options.info or "This is extra info!";
        lifetime = options.lifetime or 3;
        items = {};
        outline;
    }

    local items = cfg.items; do 
        items[ "notification" ] = library:create( "Frame" , {
            Parent = library[ "items" ];
            Size = dim2(0, 210, 0, 53);
            Name = "\0";
            BorderColor3 = rgb(0, 0, 0);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            AnchorPoint = vec2(1, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(14, 14, 16)
        });
        
        library:create( "UIStroke" , {
            Color = rgb(23, 23, 29);
            Parent = items[ "notification" ];
            Transparency = 1;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        });
        
        items[ "title" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(255, 255, 255);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.name;
            Parent = items[ "notification" ];
            Name = "\0";
            BackgroundTransparency = 1;
            Position = dim2(0, 7, 0, 6);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UICorner" , {
            Parent = items[ "notification" ];
            CornerRadius = dim(0, 3)
        });
        
        items[ "info" ] = library:create( "TextLabel" , {
            FontFace = fonts.font;
            TextColor3 = rgb(145, 145, 145);
            BorderColor3 = rgb(0, 0, 0);
            Text = cfg.info;
            Parent = items[ "notification" ];
            Name = "\0";
            Position = dim2(0, 9, 0, 22);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = true;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 14;
            BackgroundColor3 = rgb(255, 255, 255)
        });
        
        library:create( "UIPadding" , {
            PaddingBottom = dim(0, 17);
            PaddingRight = dim(0, 8);
            Parent = items[ "info" ]
        });
        
        items[ "bar" ] = library:create( "Frame" , {
            AnchorPoint = vec2(0, 1);
            Parent = items[ "notification" ];
            Name = "\0";
            Position = dim2(0, 8, 1, -6);
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(0, 0, 0, 5);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            BackgroundColor3 = themes.preset.accent
        });
        
        library:create( "UICorner" , {
            Parent = items[ "bar" ];
            CornerRadius = dim(0, 999)
        });
        
        library:create( "UIPadding" , {
            PaddingRight = dim(0, 8);
            Parent = items[ "notification" ]
        });
    end
    
    table.insert(notifications.notifs, items.notification)

    notifications:fade(items[ "notification" ], false)
    
    local offset = notifications:refresh_notifs()

    items[ "notification" ].Position = dim_offset(20, offset)

    library:tween(items[ "notification" ], {AnchorPoint = vec2(0, 0)}, Enum.EasingStyle.Quad, 1)
    library:tween(items[ "bar" ], {Size = dim2(1, -8, 0, 5)}, Enum.EasingStyle.Quad, cfg.lifetime)

    task.spawn(function()
        task.wait(cfg.lifetime)
        
        if library.unloaded or not items.notification.Parent then return end
        local index = table.find(notifications.notifs, items.notification)
        if index then table.remove(notifications.notifs, index) end
        notifications:refresh_notifs()
        notifications:fade(items[ "notification" ], true)
        
        library:tween(items[ "notification" ], {AnchorPoint = vec2(1, 0)}, Enum.EasingStyle.Quad, 1)

        task.wait(1)

        if items.notification.Parent then items.notification:Destroy() end 
    end)
end

return library
