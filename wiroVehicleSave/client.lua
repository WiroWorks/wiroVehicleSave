local ESX				= nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('wiroVehicleSave:spawnVehicles')
AddEventHandler('wiroVehicleSave:spawnVehicles', function(vehicles)
    local cVehicle = nil
    for i = 1, #vehicles do
        Citizen.Wait(5000) -- eğer araçlar awating scripts kısmında oluşturulmaya başlanırsa araçlar oluşturulmuyor
        cVehicle = nil
        if not vehicles[i].created or not DoesEntityExist(vehicles[i].hash) then
        RequestModel(vehicles[i].vehicle.model)
        while not HasModelLoaded(vehicles[i].vehicle.model) do
            RequestModel(vehicles[i].vehicle.model)
            Citizen.Wait(20)
        end
        cVehicle = CreateVehicle(vehicles[i].vehicle.model, vehicles[i].coords.x, vehicles[i].coords.y, vehicles[i].coords.z, vehicles[i].coords.r, 1, 1)
        Citizen.Wait(300)
            if DoesEntityExist(cVehicle) then
                SetVehicleProperties(cVehicle, vehicles[i].vehicle)
                TriggerServerEvent('wiroVehicleSave:setcreated', cVehicle,i)
            end
        end
    end
end)

RegisterNetEvent('wiroVehicleSave:requestAllVehicles')
AddEventHandler('wiroVehicleSave:requestAllVehicles', function(vehicless)
    local rVehicles = vehicless
    for i = 1, #rVehicles do
        if DoesEntityExist(rVehicles[i].hash) then
            rVehicles[i].vehicle = GetVehicleProperties(rVehicles[i].hash)
            local xx, yy, zz = table.unpack(GetEntityCoords(rVehicles[i].hash))
            rVehicles[i].coords = json.decode('{"x": ' .. tostring(xx) .. ', "y": ' .. tostring(yy) .. ', "z": ' .. tostring(zz) .. ', "r": ' .. tostring(GetEntityHeading(rVehicles[i].hash)) .. '}')
        end
    end
    TriggerServerEvent('wiroVehicleSave:getUpdatedVehicles', rVehicles)
end)

RegisterNetEvent('wiroVehicleSave:addVehicleClient')
AddEventHandler('wiroVehicleSave:addVehicleClient', function(vehicle)
    Citizen.Wait(10000)
    vehicleProps = GetVehicleProperties(vehicle)
    local mVehicle = {hash = vehicle, plate = vehicleProps.plate, vehicle = vehicleProps, coords = nil}
    local xx, yy, zz = table.unpack(GetEntityCoords(vehicle))
    mVehicle.coords = json.decode('{"x": ' .. tostring(xx) .. ', "y": ' .. tostring(yy) .. ', "z": ' .. tostring(zz) .. ', "r": ' .. tostring(GetEntityHeading(vehicle)) .. '}')
    TriggerServerEvent('wiroVehicleSave:addVehicleServer', mVehicle)
end)

RegisterNetEvent('wiroVehicleSave:tryToSpawnUnSpawnedVehicles')
AddEventHandler('wiroVehicleSave:tryToSpawnUnSpawnedVehicles', function(vehicless)
    vehicles = vehicless
    for i = 1, #vehicles do
        Citizen.Wait(1000) -- eğer araçlar awating scripts kısmında oluşturulmaya başlanırsa araçlar oluşturulmuyor
        cVehicle = nil
        if not DoesEntityExist(vehicles[i].hash) then
            RequestModel(vehicles[i].vehicle.model)
            while not HasModelLoaded(vehicles[i].vehicle.model) do
                RequestModel(vehicles[i].vehicle.model)
                Citizen.Wait(20)
            end
            cVehicle = CreateVehicle(vehicles[i].vehicle.model, vehicles[i].coords.x, vehicles[i].coords.y, vehicles[i].coords.z, vehicles[i].coords.r, 1, 1)
            Citizen.Wait(300)
            if DoesEntityExist(cVehicle) then
                SetVehicleProperties(cVehicle, vehicles[i].vehicle)
                TriggerServerEvent('wiroVehicleSave:setcreated', cVehicle,i)
            end
        end
    end
end)

--
SetVehicleProperties = function(vehicle, vehicleProps)
    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)

    SetVehicleEngineHealth(vehicle, vehicleProps["engineHealth"] and vehicleProps["engineHealth"] + 0.0 or 1000.0)
    SetVehicleBodyHealth(vehicle, vehicleProps["bodyHealth"] and vehicleProps["bodyHealth"] + 0.0 or 1000.0)
    SetVehicleFuelLevel(vehicle, vehicleProps["fuelLevel"] and vehicleProps["fuelLevel"] + 0.0 or 1000.0)
    SetEntityAsMissionEntity(vehicle, true, true)

    if vehicleProps["windows"] then
        for windowId = 1, 13, 1 do
            if vehicleProps["windows"][windowId] == false then
                SmashVehicleWindow(vehicle, windowId)
            end
        end
    end

    if vehicleProps["tyres"] then
        for tyreId = 1, 7, 1 do
            if vehicleProps["tyres"][tyreId] ~= false then
                SetVehicleTyreBurst(vehicle, tyreId, true, 1000)
            end
        end
    end

    if vehicleProps["doors"] then
        for doorId = 0, 5, 1 do
            if vehicleProps["doors"][doorId] ~= false then
                SetVehicleDoorBroken(vehicle, doorId - 1, true)
            end
        end
    end

    SetVehicleDoorsLocked(vehicle, vehicleProps.doorLock)

end

GetVehicleProperties = function(vehicle)
    if DoesEntityExist(vehicle) then
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

        vehicleProps["tyres"] = {}
        vehicleProps["windows"] = {}
        vehicleProps["doors"] = {}
        vehicleProps["doorLock"] = GetVehicleDoorLockStatus(vehicle)

        for id = 1, 7 do
            local tyreId = IsVehicleTyreBurst(vehicle, id, false)
        
            if tyreId then
                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = tyreId
        
                if tyreId == false then
                    tyreId = IsVehicleTyreBurst(vehicle, id, true)
                    vehicleProps["tyres"][ #vehicleProps["tyres"]] = tyreId
                end
            else
                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = false
            end
        end

        for id = 1, 13 do
            local windowId = IsVehicleWindowIntact(vehicle, id)

            if windowId ~= nil then
                vehicleProps["windows"][#vehicleProps["windows"] + 1] = windowId
            else
                vehicleProps["windows"][#vehicleProps["windows"] + 1] = true
            end
        end
        
        for id = 0, 5 do
            local doorId = IsVehicleDoorDamaged(vehicle, id)
        
            if doorId then
                vehicleProps["doors"][#vehicleProps["doors"] + 1] = doorId
            else
                vehicleProps["doors"][#vehicleProps["doors"] + 1] = false
            end
        end

        vehicleProps["engineHealth"] = GetVehicleEngineHealth(vehicle)
        vehicleProps["bodyHealth"] = GetVehicleBodyHealth(vehicle)
        vehicleProps["fuelLevel"] = GetVehicleFuelLevel(vehicle)

        return vehicleProps
    end
end
--