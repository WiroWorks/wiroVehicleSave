ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local vehicles = {}
local isVehiclesDataExist = false
local start = true
local isItWorked = false

AddEventHandler('onResourceStart', function(resourceName)
    if ("wiroVehicleSave" == resourceName) then
	local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles')
	for i = 1, #result do
   	 vehicles[i] = {hash = nil, plate = result[i].plate, vehicle = json.decode(result[i].vehicle) , coords = json.decode(result[i].coords), created = false}
	end
	isVehiclesDataExist = true
    end
end)

AddEventHandler('esx:playerLoaded',function(source)
    Citizen.Wait(5000)
    if start and isVehiclesDataExist and not isItWorked then
        TriggerClientEvent('wiroVehicleSave:spawnVehicles', source, vehicles)
        start = false
        Citizen.Wait(#vehicles * 5000 + 10000)
        start = true
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.saveDelay)
        if GetNumPlayerIndices() > 0 then
            for _, playerId in ipairs(GetPlayers()) do
                    TriggerClientEvent('wiroVehicleSave:requestAllVehicles', playerId, vehicles)
                break
            end
        end
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(60000)
    while true do
        Citizen.Wait(30000)
        if GetNumPlayerIndices() > 0 then
            for _, playerId in ipairs(GetPlayers()) do
                    TriggerClientEvent('wiroVehicleSave:tryToSpawnUnSpawnedVehicles', playerId, vehicles)
                    Citizen.Wait(10000)
                
            end
        end
    end
end)

RegisterServerEvent('wiroVehicleSave:setcreated')
AddEventHandler('wiroVehicleSave:setcreated', function(hash, index)
    vehicles[index].hash = hash
    vehicles[index].created = true
end)

RegisterServerEvent('wiroVehicleSave:getUpdatedVehicles')
AddEventHandler('wiroVehicleSave:getUpdatedVehicles', function(rVehicles)
    Citizen.Wait(10000)
    vehicles = rVehicles
    TriggerEvent('wiroVehicleSave:saveToSQL')
end)

RegisterServerEvent('wiroVehicleSave:saveToSQL')
AddEventHandler('wiroVehicleSave:saveToSQL', function()
    for i = 1, #vehicles do
        if vehicles[i].created then
            MySQL.Async.insert("UPDATE owned_vehicles SET vehicle = @vehicle, coords = @coords WHERE plate = @plate", { 
                ['@vehicle'] = json.encode(vehicles[i].vehicle),
                ['@coords'] = json.encode(vehicles[i].coords),
                ['@plate'] = vehicles[i].vehicle.plate
            })
        end
    end
end)

RegisterServerEvent('wiroVehicleSave:addVehicleServer')
AddEventHandler('wiroVehicleSave:addVehicleServer', function(vehicle)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    vehicles[#vehicles+1] = vehicle
    MySQL.Async.fetchAll("INSERT INTO owned_vehicles (owner, plate, vehicle, coords) VALUES(@owner, @plate, @vehicle, @coords)",{
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = vehicle.plate,
        ['@vehicle'] = json.encode(vehicle.vehicle),
        ['@coords'] = json.encode(vehicle.coords)
    })
end)

ESX.RegisterServerCallback('wiroVehicleSave:getVehicles', function(source, cb, target)
    local data = {
        vehicles = vehicles
    }
	cb(data)
end)

if Config.esExtended1_1 then
    TriggerEvent('es:addGroupCommand', Config.saveVehiclesCommand, 'admin' , function(source, args, user)

        TriggerClientEvent('wiroVehicleSave:requestAllVehicles', source, vehicles)

    end, function(source, args, user)
        TriggerClientEvent('chat:addMessage', source, { args = { 'Yetkin yok.' } })
    end)
else
    ESX.RegisterCommand(Config.saveVehiclesCommand, 'admin', function(xPlayer, args, showError)

        if GetNumPlayerIndices() > 0 then
            for _, playerId in ipairs(GetPlayers()) do
                    TriggerClientEvent('wiroVehicleSave:requestAllVehicles', playerId, vehicles)
                break
            end
        end

    end, false, {help = 'save all vehicles', validate = false, arguments = {}})
end
