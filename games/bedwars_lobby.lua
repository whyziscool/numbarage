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