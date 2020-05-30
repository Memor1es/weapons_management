ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('weapons_management:getAllLoadout')
AddEventHandler('weapons_management:getAllLoadout', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local loadouts = xPlayer.getLoadout(true)

    for name,weapons in pairs(loadouts) do
        ESX.RegisterUsableItem(name, function(source)
            TriggerClientEvent('weapons_management:useWeaponItem', source, name, weapons.ammo)
        end)
    end
end)