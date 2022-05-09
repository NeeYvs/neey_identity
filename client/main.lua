local guiEnabled = false
local myIdentity = {}
local myIdentifiers = {}
local hasIdentity = false
local isDead = false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

function EnableGui(state)
	SetNuiFocus(state, state)
	guiEnabled = state

	SendNUIMessage({
		type = "enableui",
		enable = state
	})
end

local id = nil

RegisterNetEvent('esx_identity:showRegisterIdentity')
AddEventHandler('esx_identity:showRegisterIdentity', function(ide)
	id = ide
	EnableGui(true)
end)

RegisterNetEvent('esx_identity:identityCheck')
AddEventHandler('esx_identity:identityCheck', function(identityCheck)
	hasIdentity = identityCheck
end)

RegisterNetEvent('esx_identity:saveID')
AddEventHandler('esx_identity:saveID', function(data)
	myIdentifiers = data
end)

RegisterNUICallback('escape', function(data, cb)
	if hasIdentity then
		EnableGui(false)
	else
		TriggerEvent('chat:addMessage', { args = { '^1[POSTACIE]', '^1Stworz swoja postac aby grac!' } })
	end
end)

RegisterNUICallback('register', function(data, cb)
	local reason = ""
	myIdentity = data
	for theData, value in pairs(myIdentity) do
		if theData == "firstname" or theData == "lastname" then
			reason = verifyName(value)
			
			if reason ~= "" then
				break
			end
		elseif theData == "dateofbirth" then
			if value == "invalid" then
				reason = "Invalid date of birth!"
				break
			end
		elseif theData == "height" then
			local height = tonumber(value)
			if height then
				if height > 210 or height < 140 then
					reason = "Musisz podac prawidlowy wzrost!"
					break
				end
			else
				reason = "Musisz podac prawidlowy wzrost!"
				break
			end
		end
	end
	
	if reason == "" then
		TriggerServerEvent('esx_identity:setIdentity', data, id)
		EnableGui(false)
		ESX.ShowNotification('~r~Ustaw się! ~w~Za ~y~30 sekund ~w~otworzy Ci się menu tworzenia postaci!')
		ESX.SetTimeout(30000, function()
			TriggerEvent('esx_skin:openSaveableMenu', myIdentifiers.id)
		end)
	end
end)

Citizen.CreateThread(function()
	while true do
		if guiEnabled then
			DisableControlAction(0, 1,   true)
			DisableControlAction(0, 2,   true)
			DisableControlAction(0, 106, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 30,  true)
			DisableControlAction(0, 31,  true)
			DisableControlAction(0, 21,  true)
			DisableControlAction(0, 24,  true)
			DisableControlAction(0, 25,  true)
			DisableControlAction(0, 47,  true)
			DisableControlAction(0, 58,  true)
			DisableControlAction(0, 263, true)
			DisableControlAction(0, 264, true)
			DisableControlAction(0, 257, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 141, true)
			DisableControlAction(0, 143, true)
			DisableControlAction(0, 75,  true)
			DisableControlAction(27, 75, true)
		end
		Citizen.Wait(10)
	end
end)

function verifyName(name)
	local nameLength = string.len(name)
	if nameLength > 25 or nameLength < 2 then
		return 'Nieprawidlowe Imie postaci.'
	end
	
	local count = 0
	for i in name:gmatch('[abcdefghijklmnopqrstuvwxyzåäöABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ0123456789 -]') do
		count = count + 1
	end
	if count ~= nameLength then
		return 'Imie zawiera niedozwolone znaki.'
	end
	
	local spacesInName    = 0
	local spacesWithUpper = 0
	for word in string.gmatch(name, '%S+') do

		if string.match(word, '%u') then
			spacesWithUpper = spacesWithUpper + 1
		end

		spacesInName = spacesInName + 1
	end

	if spacesInName > 2 then
		return 'Imie zawiera wiecej niz 2 spacje'
	end
	
	if spacesWithUpper ~= spacesInName then
		return 'Imie musi sie zaczynac duza litera.'
	end

	return ''
end