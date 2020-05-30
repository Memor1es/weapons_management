ESX = nil

local nbrDisplaying = 1
local holstered = true
local weaponsTab = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	TriggerServerEvent('weapons_management:getAllLoadout')
	SaveAllWeapons()
end)

RegisterNetEvent('weapons_management:useWeaponItem')
AddEventHandler('weapons_management:useWeaponItem', function(weaponName, weaponAmmo)
	local playerPed = PlayerPedId()
	local pid = GetPlayerFromServerId(source)
	local weaponHash = GetHashKey(weaponName)
	local offset = 1 + (nbrDisplaying * 0.15)

	if HasPedGotWeapon(playerPed, weaponHash, false) then
		ESX.NotifAboveHead(_U('unuse_weapon', ESX.GetWeaponLabel(weaponName)))
		TriggerEvent('esx:removeWeapon', weaponName)
	else
		ESX.NotifAboveHead(_U('use_weapon', ESX.GetWeaponLabel(weaponName)))
		TriggerEvent('esx:addWeapon', weaponName, weaponAmmo)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local ped = PlayerPedId()
		if DoesEntityExist( ped ) and not IsEntityDead( ped ) and not IsPedInAnyVehicle(PlayerPedId(), true) then
			loadAnimDict("reaction@intimidation@1h")
			loadAnimDict("weapons@pistol_1h@gang")
			if CheckLocalWeapon(ped) then
				if holstered then
					TaskPlayAnim(ped, "reaction@intimidation@1h", "intro", 8.0, 2.0, -1, 48, 2, 0, 0, 0 )
					DisablePlayerFiring(GetPlayerPed(-1), true)
					Citizen.Wait(2500)
					DisablePlayerFiring(GetPlayerPed(-1), false)
					ClearPedTasks(ped)
					Citizen.Wait(100)					
					holstered = false
				end
			elseif not CheckLocalWeapon(ped) then
				if not holstered then
					TaskPlayAnim(ped, "reaction@intimidation@1h", "outro", 8.0, 2.0, -1, 48, 2, 0, 0, 0 )
					DisablePlayerFiring(GetPlayerPed(-1), true)
					Citizen.Wait(1500)
					DisablePlayerFiring(GetPlayerPed(-1), false)			
					ClearPedTasks(ped)
					holstered = true
				end
			end
		end
	end
end)

function CheckLocalWeapon(ped)
	for i = 1, #weaponsTab do
		if GetHashKey(weaponsTab[i]) == GetSelectedPedWeapon(ped) then
			return true
		end
	end
	return false
end

function SaveAllWeapons()
	local weapons = ESX.GetConfig()

	for i = 1, #weapons.Weapons do
		weaponsTab[i] = weapons.Weapons[i].name
	end
end

function DisableActions(ped)
	DisableControlAction(1, 140, true)
	DisableControlAction(1, 141, true)
	DisableControlAction(1, 142, true)
	DisableControlAction(1, 37, true) -- Disables INPUT_SELECT_WEAPON (TAB)
	DisablePlayerFiring(ped, true) -- Disable weapon firing
end

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(0)
	end
end