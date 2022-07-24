local request = (syn and syn.request) or request or http_request or (http and http.request)
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
local setthreadidentityfunc = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity
local getthreadidentityfunc = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local entity, GuiLibrary, funcs = engoware.entity, engoware.GuiLibrary, engoware.funcs
local mouse = lplr:GetMouse()

function funcs:getRemote(list) 
    for i,v in next, list do if v == 'Client' then return list[i+1]; end end
end

local Flamework = require(game:GetService("ReplicatedStorage").rbxts_include.node_modules["@flamework"].core.out).Flamework
repeat task.wait() until Flamework.isInitialized
local Client, KnitClient = 
require(game:GetService("ReplicatedStorage").TS.remotes).default.Client, 
debug.getupvalue(require(lplr.PlayerScripts.TS.controllers.game["block-break-controller"]).BlockBreakController.onEnable, 1)

local Client_Get, Client_WaitFor = getmetatable(Client).Get, getmetatable(Client).WaitFor

local modules = {
    BedwarsArmor = require(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-armor-set"]).BedWarsArmor,
    BedwarsArmorSet = require(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-armor-set"]).BedwarsArmorSet,

    SwordController = KnitClient.Controllers.SwordController,
    BedwarsSwords = require(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-swords"]).BedwarsSwords,

    IntentoryUtil = require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil,
    GetInventory = function(plr) 
        if not plr then 
            return {items = {}, armor = {}}
        end

        local suc, ret = pcall(function() 
            return require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil.getInventory(plr)
        end)

        if not suc then 
            return {items = {}, armor = {}}
        end

        return ret
    end,

    HashVector = function(vec) 
        return {value = vec}
    end
}
local remotes = {
    SwordRemote = Client:Get(funcs:getRemote(debug.getconstants(modules.SwordController.attackEntity))),
    FallRemote = game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.GroundHit,
}
engoware.modules = modules
engoware.remotes = remotes

function funcs:getSword() 
    local highest, returning = -9e9, nil
    for i,v in next, modules.GetInventory(lplr).items do 
        local power = table.find(modules.BedwarsSwords, v.itemType)
        if not power then continue end
        if power > highest then 
            returning = v
            highest = power
        end
    end
    return returning
end

do 
    local function power(inv) 
        local power = 0
        for i,v in next, inv do 
            if v == 'empty' then continue end
            if table.find(modules.BedwarsSwords, v.itemType) then 
                power = power + table.find(modules.BedwarsSwords, v.itemType)
            end
            if table.find(modules.BedwarsArmor, v.itemType) then 
                power = power + table.find(modules.BedwarsArmor, v.itemType)
            end
        end
        return power
    end

    local KillauraSortFunctions = {
        health = function(ent1, ent2) 
            return ent1.Humanoid.Health < ent2.Humanoid.Health
        end,
        smart = function(ent1, ent2) 
            local Inventory1, Inventory2 = modules.GetInventory(ent1.Player), modules.GetInventory(ent2.Player)
            local ent1Power, ent2Power = power(Inventory1), power(Inventory2)
            ent1Power = ent1Power + (ent1.Humanoid.Health / 50)
            ent2Power = ent2Power + (ent2.Humanoid.Health / 50)
            
            return ent1Power < ent2Power
        end,
        power = function(ent1, ent2) 
            local Inventory1, Inventory2 = modules.GetInventory(ent1.Player), modules.GetInventory(ent2.Player)
            return power(Inventory1) > power(Inventory2)
        end
    }

    local TargetPart
    local KillauraMaxTargets = {}
    local KillauraMaxDistance = {}
    local KillauraSort = {}
    local Killaura = {}; Killaura = GuiLibrary.Objects.combatWindow.API.CreateOptionsButton({
        Name = "killaura",
        Function = function(callback) 
            if callback then 
                TargetPart = TargetPart or Instance.new("Part")
                TargetPart.Color = Color3.new(0.8, 0, 0)
                TargetPart.Anchored = true
                TargetPart.CanCollide = false
                TargetPart.Size = Vector3.new(3, 5, 3)
                TargetPart.Transparency = 0.6
                coroutine.wrap(function() 
                    repeat task.wait()
                        local Targets = funcs:getSortedEntities(KillauraMaxDistance.Value, KillauraMaxTargets.Value, true, KillauraSortFunctions[KillauraSort.Value])
                        for _, Target in next, Targets do 
                            if not Target then continue end
                            local success = remotes.SwordRemote:CallServer({
                                weapon = funcs:getSword().tool,
                                entityInstance = Target.Character,
                                validate = {
                                    raycast = {
                                        cameraPosition = modules.HashVector(workspace.CurrentCamera.CFrame.Position), 
                                        cursorDirection = modules.HashVector(Ray.new(workspace.CurrentCamera.CFrame.Position, Target.Character.HumanoidRootPart.Position).Unit.Direction)
                                    },
                                    targetPosition = modules.HashVector(Target.Character.HumanoidRootPart.Position),
                                    selfPosition = modules.HashVector(entity.character.HumanoidRootPart.Position + ((entity.character.HumanoidRootPart.Position - Target.Character.HumanoidRootPart.Position).magnitude > 14 and (CFrame.lookAt(entity.character.HumanoidRootPart.Position, Target.Character.HumanoidRootPart.Position).LookVector * 4) or Vector3.new(0, 0, 0))),
                                }, 
                                chargedAttack = {chargeRatio = 1},
                            })
                            
                            TargetPart.Parent = workspace
                            TargetPart.CFrame = Target.HumanoidRootPart.CFrame

                            if success then 
                                task.wait(1 / 3)
                            else
                                task.wait(1 / 2)
                            end
                        end


                    until not Killaura.Enabled
                end)()
            else
                TargetPart.Parent = nil
            end
        end
    })
    KillauraSort = Killaura.CreateDropdown({
        Name = "sort",
        List = {"distance", "health", "smart", "power",},
        Default = "smart",
        Function = function() end,
    })
    KillauraMaxTargets = Killaura.CreateSlider({
        Name = "max targets",
        Min = 1,
        Default = 1,
        Max = 5,
        Round = 0,
        Function = function() end,
    })
    KillauraMaxDistance = Killaura.CreateSlider({
        Name = "max distance",
        Min = 1,
        Max = 18,
        Default = 18,
        Round = 1,
        Function = function() end,
    })
end

do 
    local NoFall = {}; NoFall = GuiLibrary.Objects.utilitiesWindow.API.CreateOptionsButton({
        Name = "nofall",
        Function = function(callback) 
            if callback then 
                coroutine.wrap(function() 
                    repeat 
                        remotes.FallRemote:FireServer()
                        task.wait(5)
                    until not NoFall.Enabled
                end)()
            end
        end,
    })
end