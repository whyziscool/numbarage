--[[

    Main.lua - Main file for engoware.
    
    written by: @engo#0320

]]

if not game:IsLoaded() then 
    game.Loaded:Wait()
end

local startTick = tick()

local request = (syn and syn.request) or request or http_request or (http and http.request)
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
local setthreadidentityfunc = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity
local getthreadidentityfunc = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local entity, GuiLibrary
local override = {
    [6872265039] = "bedwars_lobby",
    [8444591321] = "bedwars",
    [6872274481] = "bedwars",
    [8560631822] = "bedwars"
}
local funcs = {}; do
    function funcs:require(url, bypass, bypass2)
        if isfile(url) then
            return readfile(url)
        end

        local newUrl = (bypass and "https://raw.githubusercontent.com/joeengo/" or "https://raw.githubusercontent.com/joeengo/engoware/main/") .. url:gsub("engoware/", ""):gsub("engoware\\", "")
        local response = request({
            Url = bypass2 and url or newUrl,
            Method = "GET",
        })
        if response.StatusCode == 200 then
            return response.Body
        end
    end

    function funcs:getPlaceIdentifier() 
        return tostring(override[game.PlaceId] or game.PlaceId)
    end

    function funcs:getPlaceScript() 
        local placeId = funcs:getPlaceIdentifier()
        local scriptName = (placeId .. ".lua")
        if scriptName then
            local path = "engoware/games/" .. scriptName
            return funcs:require(path) or ""
        end
    end

    function funcs:getUniversalScript()
        return funcs:require("engoware/games/universal.lua")
    end

    function funcs:run(code) 
        local func, err = loadstring(code)
        if not typeof(func) == 'function' then
            return warn("Failed to run code, error: " .. tostring(err))
        end
        return func()
    end

    function funcs:connection(...) 
        return GuiLibrary.utils:connection(...)
    end

    local loops = {RenderStepped = {}, Heartbeat = {}, Stepped = {}}
    function funcs:bindToStepped(id, callback)
        if not loops.Stepped[id] then 
            loops.Stepped[id] = game:GetService("RunService").Stepped:Connect(callback)
        else
            warn("[engoware] attempt to bindToStepped to an already bound id: " .. tostring(id))
        end
    end

    function funcs:unbindFromStepped(id)
        if loops.Stepped[id] then
            loops.Stepped[id]:Disconnect()
            loops.Stepped[id] = nil
        end
    end

    function funcs:bindToRenderStepped(id, callback)
        if not loops.RenderStepped[id] then 
            loops.RenderStepped[id] = game:GetService("RunService").RenderStepped:Connect(callback)
        else
            warn("[engoware] attempt to bindToRenderStepped to an already bound id: " .. tostring(id))
        end
    end

    function funcs:unbindFromRenderStepped(id)
        if loops.RenderStepped[id] then
            loops.RenderStepped[id]:Disconnect()
            loops.RenderStepped[id] = nil
        end
    end

    function funcs:bindToHeartbeat(id, callback)
        if not loops.Heartbeat[id] then 
            loops.Heartbeat[id] = game:GetService("RunService").Heartbeat:Connect(callback)
        else
            warn("[engoware] attempt to bindToHeartbeat to an already bound id: " .. tostring(id))
        end
    end

    function funcs:unbindFromHeartbeat(id)
        if loops.Heartbeat[id] then
            loops.Heartbeat[id]:Disconnect()
            loops.Heartbeat[id] = nil
        end
    end

    function funcs:isAlive(plr: Player, stateCheck: boolean) 
        if not plr then 
            return entity.isAlive
        end

        local _, ent = entity.getEntityFromPlayer(plr)
        return ((not stateCheck) or ent and ent.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead) and ent
    end 

    function funcs:isTargetable(plr: Player) 
        return funcs:isAlive(plr, true) and (not plr.Character:FindFirstChildOfClass("ForceField"))
    end

    function funcs:getClosestEntity(maxDist: number, teamCheck: boolean)
        local maxDist, val = maxDist or 9e9, nil
        if funcs:isAlive() then
            for i,v in next, entity.entityList do 
                if (v.Targetable or not teamCheck) and funcs:isTargetable(v.Player) then 
                    local dist = (lplr.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                    if dist < maxDist then
                        maxDist, val = dist, v
                    end
                end
            end
        end
        return val
    end

    function funcs:getSortedEntities(maxDist: number, maxEntities: number, teamCheck: boolean, sortFunction)
        local maxDist, maxEntities, val = maxDist or 9e9, maxEntities or 9e9, {}
        if not funcs:isAlive() then
            return val
        end

        local selfPos = entity.character.HumanoidRootPart.Position
        for i,v in next, entity.entityList do 
            if (v.Targetable or not teamCheck) and funcs:isTargetable(v.Player) then 
                local dist = (selfPos - v.HumanoidRootPart.Position).Magnitude
                if dist < maxDist then
                    table.insert(val, v)
                end
            end
        end

        local sortFunction = sortFunction or function(ent1, ent2)
            return (selfPos - ent1.HumanoidRootPart.Position).Magnitude < (selfPos - ent2.HumanoidRootPart.Position).Magnitude
        end
        table.sort(val, sortFunction)

        if #val > maxEntities then
            return table.move(val, 1, maxEntities, 1, {})
        end

        return val
    end

    function funcs:getEnemyColor(isEnemy) 
        if isEnemy then
            return Color3.new(1, 0.427450, 0.427450)
        end
        return Color3.new(0.470588, 1, 0.470588)
    end

    function funcs:getColorFromEntity(ent, useTeamColor, useColorTheme) 
        if ent.Team and ent.Team.TeamColor.Color and useTeamColor then
            return ent.Team.TeamColor.Color
        end

        if useColorTheme then 
            return GuiLibrary.utils:getColor()
        end

        return funcs:getEnemyColor(ent.Targetable)
    end
end

if not getgenv or (identifyexecutor and identifyexecutor():find("Arceus")) then
    return warn("[engoware] unsupported executor.")
end

if engoware then 
    return warn("[engoware] already loaded.")
end

entity = funcs:run(funcs:require("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/Libraries/entityHandler.lua", true, true))
entity.fullEntityRefresh()
GuiLibrary = funcs:run(funcs:require("engoware/GuiLibrary.lua"))

getgenv().engoware = {}
engoware.entity = entity
engoware.GuiLibrary = GuiLibrary
engoware.funcs = funcs

local windows = {
    combat = GuiLibrary.CreateWindow({Name = "combat"}),
    exploit = GuiLibrary.CreateWindow({Name = "exploits"}),
    movement = GuiLibrary.CreateWindow({Name = "movement"}),
    utilities = GuiLibrary.CreateWindow({Name = "utilities"}),
    render = GuiLibrary.CreateWindow({Name = "render"}),
    misc = GuiLibrary.CreateWindow({Name = "misc"}),
    other = GuiLibrary.CreateWindow({Name = "other"}),
}

local guiButton = windows.other.CreateOptionsButton({
    Name = "gui",
    Function = function(callback) 
        GuiLibrary.ClickGUI.Visible = callback
    end,
    Bind = "RightShift",
})
GuiLibrary.ClickGUI.Visible = false

local colorButton; colorButton = windows.other.CreateOptionsButton({
    Name = "colors",
    Function = function(callback)
        if not callback then
            colorButton.Toggle()
        end
    end,
})
if not colorButton.Enabled then
    colorButton.Toggle()
end

local hueSlider
local satSlider
local valSlider
local rainbowSmoothSlider
local rainbowToggle = colorButton.CreateToggle({
    Name = "rainbow",
    Function = function(callback)
        GuiLibrary.Rainbow = callback
        if not callback then
            GuiLibrary.utils:setColorTheme({H = hueSlider.Value / 360, S = satSlider.Value / 100, V = valSlider.Value / 100})
        end
    end,
})

rainbowSmoothSlider = colorButton.CreateSlider({
    Name = "rainbow smoothness",
    Function = function(value)
        GuiLibrary.RainbowSmoothness = value * 75
    end,
    Min = 10,
    Max = 100,
    Default = 23,
})

hueSlider = colorButton.CreateSlider({
    Name = "hue",
    Function = function(value)
        if GuiLibrary.Rainbow then 
            return
        end
        local old = GuiLibrary.utils:getColorTheme(true)
        GuiLibrary.utils:setColorTheme({
            H = value / 360,
            S = old.S,
            V = old.V,
        })
    end,
    Min = 0,
    Max = 360,
    Round = 0,
    Default = 150,
})

satSlider = colorButton.CreateSlider({
    Name = "sat",
    Function = function(value)
        local old = GuiLibrary.utils:getColorTheme(true)
        GuiLibrary.utils:setColorTheme({
            H = old.H,
            S = value / 100,
            V = old.V,
        })
    end,
    Min = 0,
    Max = 100,
    Round = 0,
    Default = 100,
})

valSlider = colorButton.CreateSlider({
    Name = "val",
    Function = function(value)
        local old = GuiLibrary.utils:getColorTheme(true)
        GuiLibrary.utils:setColorTheme({
            H = old.H,
            S = old.S,
            V = value / 100,
        })
    end,
    Min = 0,
    Max = 100,
    Round = 0,
    Default = 100,
})

local universal = funcs:run(funcs:getUniversalScript())
local gameScript = funcs:run(funcs:getPlaceScript())

local teleportConnection = lplr.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
		local stringtp = [[
            if engoware_developer then 
                loadstring(readfile("engoware/Main.lua"))()
            else 
                loadstring(game:HttpGet("https://raw.githubusercontent.com/joeengo/engoware/main/Main.lua", true))() 
            end
        ]]
		queueteleport(stringtp)
    end
end)


if engoware_developer then
    print("[engoware] loaded in " .. tostring(tick() - startTick) .. "s.")
end