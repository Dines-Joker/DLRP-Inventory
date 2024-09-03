ESX = nil
local enableField = false
local isDead = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)



AddEventHandler('esx:onPlayerDeath', function(data)
    isDead = true
	toggleField(false)
	SetNuiFocus(false, false)
end)

AddEventHandler('esx:onPlayerSpawn', function(spawn) 
	isDead = false 
end)

function toggleField(enable)
    SetNuiFocus(enable, enable)
    enableField = enable
    ESX.TriggerServerCallback('mindv_inventory:loadblackmoney', function(money)
        if enable then
            SendNUIMessage({
                action = 'open',
                money = money
            })
        else
            SendNUIMessage({
                action = 'close'
            })
        end
    end)
end

function ReloadInventory()
    ESX.TriggerServerCallback('mindv_inventory:loadblackmoney', function(money)
        SendNUIMessage({action = 'reset', money = money})
       
        ESX.TriggerServerCallback('mindv_inventory:loadTarget', function(data)
            for key, value in pairs(data) do

                SendNUIMessage({
                    action = "add",
                    identifier = value.identifier,
                    item = value.item,
                    count = value.count,
                    name = value.name,
                    label = value.label,
                    limit = value.limit,
                    rare = value.rare,
                    can_remove = value.can_remove,
                    url = 'https://img.mindv.eu/items/'..value.name..'.png',
                    useable = value.usable
                })
            end
        end, GetPlayerServerId(PlayerId()))

        SendNUIMessage({
            money = money
        })
    end)
end

function Waffen()
    ESX.TriggerServerCallback('mindv_inventory:loadblackmoney', function(money)
        SendNUIMessage({action = 'reset', money = money})
       
        ESX.TriggerServerCallback('mindv_inventory:loadTargetWeapons', function(data)
            for key, value in pairs(data) do
                SendNUIMessage({
                    action = "addw",
                    identifier = value.identifier,
                    item = value.item,
                    count = value.ammo,
                    name = value.name,
                    label = value.label,
                    rare = value.rare,
                    can_remove = value.can_remove,
                    url = 'https://img.mindv.eu/weapons/'..string.upper(value.name)..'.png',
                })
            end
        end, GetPlayerServerId(PlayerId()))

        SendNUIMessage({
            money = money
        })
    end)
end

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

RegisterNUICallback('refresh', function(data, cb)
    ReloadInventory()
	Waffen()
    cb('ok')
end)

RegisterNUICallback('use', function(data, cb)
    for i = 1, tonumber(data.amount), 1 do
        
        
        local token = exports.idk.saveEvent()
        TriggerServerEvent('mindv_inventory:useItem', token, data.item)
        token = nil
		
        toggleField(false)
        SetNuiFocus(false, false)
    end

    cb('ok')
end)

RegisterNUICallback('throw', function(data, cb)
	local playerPed = PlayerPedId()
    loadAnimDict('anim@mp_snowball')

    TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
	ReloadInventory()
	toggleField(false)
	Waffen()
	Citizen.Wait(1300)
	ClearPedTasksImmediately(playerPed) 
    local token = exports.idk.saveEvent()
    TriggerServerEvent('mindv_inventory:throwItem', token, data.item, tonumber(data.amount))
    token = nil
	TriggerEvent('notifications', "error", 'Inventar-System', 'Sie haben '..data.amount..'x '..data.label..' weggeworfen!')
	
    cb('ok')
    DisableControlAction()
end)

--Waffen
RegisterNUICallback('throwweapon', function(data, cb)
	local playerPed = PlayerPedId()
    loadAnimDict('anim@mp_snowball')

    TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
	ReloadInventory()
	toggleField(false)
	Waffen()
	Citizen.Wait(1300)
	ClearPedTasksImmediately(playerPed)
    local token = exports.idk.saveEvent()
    TriggerServerEvent('mindv_inventory:throwWeapon', token, data.item, tonumber(data.amount))
    token = nil
	TriggerEvent('notifications', "error", 'Inventar-System', 'Sie haben eine '..data.label..' mit '..data.amount..' Schuss weggeworfen!')
	
	cb('ok')
	DisableControlAction()
end)

RegisterNUICallback('give', function(data, cb)
	local playerPed = PlayerPedId()
    loadAnimDict('anim@mp_snowball')
    local player, dist = ESX.Game.GetClosestPlayer()

    if player == -1 or dist > 3.0 then
        TriggerEvent('notifications', "error", 'Inventar-System', 'Es konnte keine Person in Ihrem Umkreis gefunden werden!')
    else
        TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
		ReloadInventory()
		Waffen()
        toggleField(false)
        Citizen.Wait(1300)
        ClearPedTasksImmediately(playerPed)
        local token = exports.idk.saveEvent()
        TriggerServerEvent('mindv_inventory:giveItem', token, data.item, tonumber(data.amount), GetPlayerServerId(player), data.label)
        token = nil
    end
    
    cb('ok')
end)

--Waffen
RegisterNUICallback('giveweapon', function(data, cb)	
	local playerPed = PlayerPedId()
    loadAnimDict('anim@mp_snowball')
    local player, dist = ESX.Game.GetClosestPlayer()

    if player == -1 or dist > 3.0 then
		TriggerEvent('notifications', "error", 'Inventar-System', 'Es konnte keine Person in Ihrem Umkreis gefunden werden!')
    else
        TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
		ReloadInventory()
		Waffen()
	    toggleField(false)
        Citizen.Wait(1300)
        ClearPedTasksImmediately(playerPed)
        local token = exports.idk.saveEvent()
        TriggerServerEvent('mindv_inventory:giveWeapon', token, data.item, data.label, data.amount, data.count, GetPlayerServerId(player))
        token = nil
    end
    
    cb('ok')
end)

RegisterNUICallback('throwCash', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)
    local token = exports.idk.saveEvent()
    TriggerServerEvent('mindv_inventory:throwMoney', token, tonumber(data.amount))
    token = nil
	TriggerEvent('notifications', "error", 'Inventar-System', 'Sie haben $'..data.amount..' Bargeld weggeworfen!')
end)

RegisterNUICallback('givecash', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)
    local playerPed = PlayerPedId()
    loadAnimDict('anim@mp_snowball')
    local player, dist = ESX.Game.GetClosestPlayer()

    if player == -1 or dist > 3.0 then
		TriggerEvent('notifications', "error", 'Inventar-System', 'Es konnte keine Person in Ihrem Umkreis gefunden werden!')
    else
        TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
        Wait(1300)
        ClearPedTasksImmediately(playerPed)
        local token = exports.idk.saveEvent()
        TriggerServerEvent('mindv_inventory:giveMoney', token, data.amount, GetPlayerServerId(player))
        token = nil
		TriggerEvent('notifications', "success", 'Inventar-System', 'Sie haben jemanden $'..data.amount..' weitergegeben!')
    end
end)

RegisterNUICallback('throwblackCash', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)
    
    TriggerServerEvent('mindv_inventory:throwBlackmoney', tonumber(data.amount))
    
	TriggerEvent('notifications', "error", 'Inventar-System', 'Sie haben $'..data.amount..' Schwarzgeld weggeworfen!')
end)

RegisterNUICallback('giveblackcash', function(data, cb)
	toggleField(false)
    SetNuiFocus(false, false)
	local playerPed = PlayerPedId()
    loadAnimDict('anim@mp_snowball')
    local player, dist = ESX.Game.GetClosestPlayer()

    if player == -1 or dist > 3.0 then
		TriggerEvent('notifications', "error", 'Inventar-System', 'Es konnte keine Person in Ihrem Umkreis gefunden werden!')
    else
        TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
        Wait(1300)
        ClearPedTasksImmediately(playerPed)
        
        TriggerServerEvent('mindv_inventory:giveBlackmoney', tonumber(data.amount), GetPlayerServerId(player))
        
		TriggerEvent('notifications', "success", 'Inventar-System', 'Sie haben jemanden $'..data.amount..' weitergegeben!')
    end
end)

RegisterNetEvent('mindv_inventory:setMax')
AddEventHandler('mindv_inventory:setMax', function(max)
    SendNUIMessage({
        action = 'updatemax',
        max = max
    })
end)

RegisterNetEvent('mindv_inventory:reloadInv')
AddEventHandler('mindv_inventory:reloadInv', function()
    ReloadInventory()
	Waffen()
end)

AddEventHandler('onResourceStop', function(name)
    if GetCurrentResourceName() ~= name then
        return
    end

    toggleField(false)
end)

RegisterNUICallback('escape', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)

    cb('ok')
end)

local cooldown = false

CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 289) then
            if not cooldown then
                if not isDead then
                    cooldown = true
                    cooldowntimer()
                    ReloadInventory()
                    Waffen()
                    toggleField(true)
                end
            else
               TriggerEvent('notifications', "error", 'Inventar-System', 'Der Cooldown ist noch aktiv, bitte warte!')
            end
        end
    end
end)

function cooldowntimer()
    CreateThread(function()
        while cooldown do
            Wait(0)
            SetTimeout(5 * 1000, function()
                cooldown = false
            end)
        end
    end)
end