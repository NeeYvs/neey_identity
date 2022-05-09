ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function getIdentity(source, callback)
	MySQL.Async.fetchAll('SELECT firstname, lastname FROM `characters` WHERE `identifier` = @identifier', {
		['@identifier'] = GetPlayerIdentifiers(source)[1]
	}, function(result)
		if result[1] ~= nil then
			if result[1].firstname ~= '' or result[1].lastname ~= '' then
				callback(false)
			else
				callback(true)
			end
		else
			callback(false)
		end
	end)
end

function setIdentity(identifier, data, callback)
	MySQL.Async.execute('UPDATE `characters` SET `firstname` = @firstname, `lastname` = @lastname, `dateofbirth` = @dateofbirth, `sex` = @sex, `height` = @height, `tattoos` = @tattoos WHERE identifier = @identifier', {
		['@identifier']		= identifier,
		['@firstname']		= data.firstname,
		['@lastname']		= data.lastname,
		['@dateofbirth']	= data.dateofbirth,
		['@sex']			= data.sex,
		['@height']			= data.height,
		['@tattoos']		= '[]'
	}, function(rowsChanged)
		if callback then
			callback(true)
		end
	end)
end

function GetIdentifierWithoutSteam(identifier)
    return string.gsub(identifier, "steam:", "")
end

RegisterServerEvent('esx_identity:setIdentity')
AddEventHandler('esx_identity:setIdentity', function(data, id)
	local _source = source
	local identifier = GetIdentifierWithoutSteam(GetPlayerIdentifiers(source)[1])
	local hex = "Char".. id ..":" .. identifier
	setIdentity(hex, data, function(callback)
		if callback then
			--TriggerClientEvent('esx_identity:identityCheck', source, true)
			TriggerEvent('esx:loadPlayer', hex, _source)
		else
			TriggerClientEvent('chat:addMessage', source, { args = { '^[IDENTITY]', 'Failed to set character, try again later or contact the server admin!' } })
		end
	end)
end)

AddEventHandler('esx:playerLoaded', function(source, xPlayer)
	local myID = {
		steamid = xPlayer.identifier,
		playerid = source
	}

	TriggerClientEvent('esx_identity:saveID', source, myID)
	getIdentity(source, function(cb)
		if cb then
			TriggerClientEvent('esx_identity:identityCheck', source, false)
		else
			TriggerClientEvent('esx_identity:identityCheck', source, true)
		end
	end)
end)