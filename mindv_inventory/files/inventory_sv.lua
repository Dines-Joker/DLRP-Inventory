ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local itemmax = {}

MySQL.ready(function()
	MySQL.Async.fetchAll("SELECT * FROM items",{},function(res)
		for x,y in pairs(res) do
			table.insert(itemmax,{y.name,y.limit})
		end
	end)
end)

function sendInventoryLog(color, name, title, message, footer)
	local embed = {
		  {
			  ["color"] = color,
			  ["title"] = "**".. title .."**",
			  ["description"] = message,
			  ["footer"] = {
				  ["text"] = footer,
			  },
		  }
	  }  
	PerformHttpRequest('https://discord.com/api/webhooks/995757645854150786/XTGPKBKppAR3594mgufjK0BY1rPissTmFYrQyKTn_6q952EW6_VFbF0BexrdpCpNR-39', function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function sendGiveLog(color, name, title, message, footer)
	local embed = {
		  {
			  ["color"] = color,
			  ["title"] = "**".. title .."**",
			  ["description"] = message,
			  ["footer"] = {
				  ["text"] = footer,
			  },
		  }
	  }  
	PerformHttpRequest('https://discord.com/api/webhooks/995757645854150786/XTGPKBKppAR3594mgufjK0BY1rPissTmFYrQyKTn_6q952EW6_VFbF0BexrdpCpNR-39', function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

ESX.RegisterServerCallback("mindv_inventory:loadTarget", function(source, cb)
	local s = source
	local x = ESX.GetPlayerFromId(s)
	cb(x.getInventory())
end)

ESX.RegisterServerCallback("mindv_inventory:loadTargetWeapons", function(source, cb)
	local s = source
	local x = ESX.GetPlayerFromId(s)
	cb(x.getLoadout())
end)


ESX.RegisterServerCallback("mindv_inventory:loadblackmoney", function(source, cb)
	local s = source
	local x = ESX.GetPlayerFromId(s)
	cb(x.getAccount('black_money').money)
end)

ESX.RegisterServerCallback("mindv_inventory:loadmoney", function(source, cb)
	local s = source
	local x = ESX.GetPlayerFromId(s)
	cb(x.getMoney())
end)

RegisterNetEvent('mindv_inventory:useItem')
AddEventHandler('mindv_inventory:useItem', function(token, name)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if token then 
		if name ~= nil then
			if ESX.CanUseItem(name) then
				ESX.UseItem(source, name)
			else
				TriggerClientEvent('notifications', xPlayer, "error", 'Inventar-System', 'Dieses Item kann nicht benutzt werden!')
			end
		end
	end
end)

RegisterNetEvent('mindv_inventory:throwItem')
AddEventHandler('mindv_inventory:throwItem', function(token, name, count)
	local playerPed = GetPlayerPed(-1)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if token then 

		xPlayer.removeInventoryItem(name, count)
		sendInventoryLog("12745742", "Inventarlogs", GetPlayerName(xPlayer.source) .." | ID: ".. xPlayer.source.. " | Item weggeworfen", "Der Spieler mit dem Namen "..GetPlayerName(xPlayer.source).. " hat  **x"..count.." "..name.."** weggeworfen.", "Made with ❤️ by mindv")
	end

end)

RegisterNetEvent('mindv_inventory:throwWeapon')
AddEventHandler('mindv_inventory:throwWeapon', function(token, name, count)
	local playerPed = GetPlayerPed(-1)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if token then 
		xPlayer.removeWeapon(name)
		sendInventoryLog("12745742", "Inventarlogs", GetPlayerName(xPlayer.source) .." | ID: ".. xPlayer.source.." | Waffe weggeworfen", "Der Spieler mit dem Namen "..GetPlayerName(xPlayer.source).. " hat  **x"..count.." Schuss | "..name.."** weggeworfen.", "Made with ❤️ by mindv")
	end

end)

RegisterNetEvent('mindv_inventory:throwMoney')
AddEventHandler('mindv_inventory:throwMoney', function(token, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

		if token then
			
		if xPlayer.getMoney() >= count then
			xPlayer.removeMoney(count)
			sendGiveLog("12745742", "Inventarlogs", GetPlayerName(xPlayer.source) .." | ID: ".. xPlayer.source.." | Gruengeld weggeworfen", "Der Spieler mit dem Namen "..GetPlayerName(xPlayer.source).. " hat  **$"..count.."** Gruengeld weggeworfen.", "Made with ❤️ by mindv")
		else
			TriggerClientEvent('notifications', xPlayer, "error", 'Inventar-System', 'Das ist ein ungueltiger Betrag!')
		end
	end

end)

RegisterNetEvent('mindv_inventory:throwBlackmoney')
AddEventHandler('mindv_inventory:throwBlackmoney', function(count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)


		if xPlayer.getAccount('black_money').money >= count then
			xPlayer.removeAccountMoney('black_money', count)
			sendGiveLog("12745742", "Inventarlogs", GetPlayerName(xPlayer.source) .." | ID: ".. xPlayer.source.." | Schwarzgeld weggeworfen", "Der Spieler mit dem Namen "..GetPlayerName(xPlayer.source).. " hat  **$"..count.."** Schwarzgeld weggeworfen.", "Made with ❤️ by mindv")
		else
			TriggerClientEvent('notifications', xPlayer, "error", 'Inventar-System', 'Das ist ein ungueltiger Betrag!')
		end

end)

RegisterNetEvent('mindv_inventory:giveItem')
AddEventHandler('mindv_inventory:giveItem', function(token, name, amount, target, label)
	local xPlayer = ESX.GetPlayerFromId(source)


		local xTarget = ESX.GetPlayerFromId(target)

		if token then 
		
		if xPlayer.getInventoryItem(name).count >= amount then
			if xTarget.canCarryItem(name, amount) then
				xPlayer.removeInventoryItem(name, amount)
				xTarget.addInventoryItem(name, amount)
				TriggerClientEvent('notifications', xTarget.source, "success", 'Inventar-System', 'Sie haben '..amount..'x '..name..' erhalten!')
				TriggerClientEvent('notifications', xPlayer.source, "error", 'Inventar-System', 'Sie haben jemanden '..amount..'x '..label..' weitergegeben!')
				TriggerClientEvent('mindv_inventory:setMax', xPlayer, amount)
				sendInventoryLog("12745742", "Inventarlogs", GetPlayerName(xPlayer.source) .." | ID: ".. xPlayer.source.." | Item weitergeben", "Der Spieler mit dem Namen "..GetPlayerName(xPlayer.source).. " hat  **x"..amount.." "..name.."** an "..GetPlayerName(xTarget.source).. " weitergegeben.", "Made with ❤️ by mindv")
			else
				TriggerClientEvent('notifications', xPlayer.source, "error", 'Inventar-System', 'Das ist ein ungueltiger Betrag!')
			end
		end
	end
end)

--Waffen
RegisterNetEvent('mindv_inventory:giveWeapon')
AddEventHandler('mindv_inventory:giveWeapon', function(token, name, label, amount, count, target)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	

		local xTarget = ESX.GetPlayerFromId(target)
		local amount = tonumber(amount)
		local count = tonumber(count)

		if token then 

		if  xPlayer.hasWeapon(name) then	
			if not xTarget.hasWeapon(name) then
				xPlayer.removeWeapon(name)
				xTarget.addWeapon(name, 300)
				TriggerClientEvent('notifications', xTarget.source, "success", 'Inventar-System', 'Sie haben eine '..label..' erhalten!')
				TriggerClientEvent('notifications', xPlayer.source, "success", 'Inventar-System', 'Sie haben eine '..label..' weitergegeben!')
				sendInventoryLog("12745742", "Inventarlogs", GetPlayerName(xPlayer.source) .." | ID: ".. xPlayer.source.." | Waffe weitergeben", "Der Spieler mit dem Namen "..GetPlayerName(xPlayer.source).. " hat  **x1 "..label.."** an "..GetPlayerName(xTarget.source).. " weitergegeben.", "Made with ?? by mindv")
			else
				TriggerClientEvent('notifications', xPlayer.source, "error", 'Inventar-System', 'Diese Person besitzt bereits diese Waffe!')
				TriggerClientEvent('notifications', xTarget.source, "error", 'Inventar-System', 'Sie besitzen bereits diese Waffe!')
			end

		else
			TriggerClientEvent('notifications', xPlayer.source, "success", 'Inventar-System', 'Sie haben keine '..label..' im Inventar!')
		end
	end
end)

RegisterNetEvent('mindv_inventory:giveMoney')
AddEventHandler('mindv_inventory:giveMoney', function(token, amount, target)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if token then
		local xTarget = ESX.GetPlayerFromId(target)
	
		local count = tonumber(amount)
		if xPlayer.getMoney() >= count then
			xPlayer.removeMoney(count)
			xTarget.addMoney(count)
			TriggerClientEvent('notifications', xTarget.source, "success", 'Inventar-System', 'Sie haben '..count..'$ Bargeld erhalten!')
			sendGiveLog("12745742", "Inventarlogs", GetPlayerName(xPlayer.source) .." | ID: ".. xPlayer.source.." | Gruengeld an "..GetPlayerName(xTarget.source) .." | ID: ".. xTarget.source, "Der Spieler mit dem Namen "..GetPlayerName(xPlayer.source).. " hat  **$"..count.."** an "..GetPlayerName(xTarget.source).. " weitergegeben.", "Made with ❤️ by mindv")
		else
			TriggerClientEvent('notifications', xPlayer.source, "error", 'Inventar-System', 'Das ist ein ungueltiger Betrag!')
		end
	end

end)

RegisterNetEvent('mindv_inventory:giveBlackmoney')
AddEventHandler('mindv_inventory:giveBlackmoney', function(count, target)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)


		local xTarget = ESX.GetPlayerFromId(target)

		if xPlayer.getAccount('black_money').money >= count then
			xPlayer.removeAccountMoney('black_money', count)
			xTarget.addAccountMoney('black_money', count)
			TriggerClientEvent('notifications', xTarget.source, "success", 'Inventar-System', 'Sie haben '..count..'$ Schwarzgeld erhalten!')
			sendGiveLog("12745742", "Inventarlogs", GetPlayerName(xPlayer.source) .." | ID: ".. xPlayer.source.." Schwarzgeld an "..GetPlayerName(xTarget.source) .." | ID: ".. xTarget.source, "Der Spieler mit dem Namen "..GetPlayerName(xPlayer.source).. " hat  **$"..count.."** an "..GetPlayerName(xTarget.source).. " weitergegeben.", "Made with ❤️ by mindv")
		else
			TriggerClientEvent('notifications', xPlayer.source, "error", 'Inventar-System', 'Das ist ein ungueltiger Betrag!')
		end

end)